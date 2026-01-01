const express = require('express');
const pool = require('../config/database');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

const router = express.Router();

// Get all active rewards
router.get('/', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM rewards WHERE is_active = true ORDER BY coin_cost ASC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get rewards error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Get all rewards (admin)
router.get('/all', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM rewards ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Get all rewards error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Create reward (admin)
router.post('/', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { title, description, coin_cost, icon } = req.body;

    if (!title || !coin_cost) {
      return res.status(400).json({ error: 'Başlık ve coin maliyeti gerekli' });
    }

    const result = await pool.query(
      'INSERT INTO rewards (title, description, coin_cost, icon) VALUES ($1, $2, $3, $4) RETURNING *',
      [title, description || '', coin_cost, icon || 'gift']
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Create reward error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Update reward (admin)
router.put('/:id', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, coin_cost, icon, is_active } = req.body;

    const result = await pool.query(
      `UPDATE rewards SET 
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        coin_cost = COALESCE($3, coin_cost),
        icon = COALESCE($4, icon),
        is_active = COALESCE($5, is_active),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $6 RETURNING *`,
      [title, description, coin_cost, icon, is_active, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Ödül bulunamadı' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update reward error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Delete reward (admin)
router.delete('/:id', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM rewards WHERE id = $1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Ödül bulunamadı' });
    }

    res.json({ message: 'Ödül silindi' });
  } catch (error) {
    console.error('Delete reward error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Redeem a reward (spend coins)
router.post('/:id/redeem', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const { id } = req.params;
    const userId = req.user.id;

    // Get reward
    const rewardResult = await client.query('SELECT * FROM rewards WHERE id = $1 AND is_active = true', [id]);
    if (rewardResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Ödül bulunamadı' });
    }

    const reward = rewardResult.rows[0];

    // Check user coins
    const userCheck = await client.query('SELECT coins FROM users WHERE id = $1', [userId]);
    if (userCheck.rows[0].coins < reward.coin_cost) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Yetersiz coin' });
    }

    // Deduct coins from user
    const userResult = await client.query(
      'UPDATE users SET coins = coins - $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING coins',
      [reward.coin_cost, userId]
    );

    // Record reward redemption
    await client.query(
      'INSERT INTO user_rewards (user_id, reward_id, coins_spent) VALUES ($1, $2, $3)',
      [userId, id, reward.coin_cost]
    );

    await client.query('COMMIT');

    res.json({
      message: `${reward.title} alındı! -${reward.coin_cost} coin`,
      coins_spent: reward.coin_cost,
      total_coins: userResult.rows[0].coins
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Redeem reward error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  } finally {
    client.release();
  }
});

module.exports = router;
