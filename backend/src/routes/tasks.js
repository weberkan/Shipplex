const express = require('express');
const pool = require('../config/database');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

const router = express.Router();

// Get all active tasks
router.get('/', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM tasks WHERE is_active = true ORDER BY coin_reward ASC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Get all tasks (admin)
router.get('/all', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Get all tasks error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Create task (admin)
router.post('/', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { title, description, coin_reward, icon } = req.body;

    if (!title || !coin_reward) {
      return res.status(400).json({ error: 'Başlık ve coin ödülü gerekli' });
    }

    const result = await pool.query(
      'INSERT INTO tasks (title, description, coin_reward, icon) VALUES ($1, $2, $3, $4) RETURNING *',
      [title, description || '', coin_reward, icon || 'task']
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Create task error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Update task (admin)
router.put('/:id', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, coin_reward, icon, is_active } = req.body;

    const result = await pool.query(
      `UPDATE tasks SET 
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        coin_reward = COALESCE($3, coin_reward),
        icon = COALESCE($4, icon),
        is_active = COALESCE($5, is_active),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $6 RETURNING *`,
      [title, description, coin_reward, icon, is_active, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Görev bulunamadı' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update task error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Delete task (admin)
router.delete('/:id', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM tasks WHERE id = $1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Görev bulunamadı' });
    }

    res.json({ message: 'Görev silindi' });
  } catch (error) {
    console.error('Delete task error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Complete a task (earn coins)
router.post('/:id/complete', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const { id } = req.params;
    const userId = req.user.id;

    // Get task
    const taskResult = await client.query('SELECT * FROM tasks WHERE id = $1 AND is_active = true', [id]);
    if (taskResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Görev bulunamadı' });
    }

    const task = taskResult.rows[0];

    // Add coins to user
    const userResult = await client.query(
      'UPDATE users SET coins = coins + $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING coins',
      [task.coin_reward, userId]
    );

    // Record task completion
    await client.query(
      'INSERT INTO user_tasks (user_id, task_id, coins_earned) VALUES ($1, $2, $3)',
      [userId, id, task.coin_reward]
    );

    await client.query('COMMIT');

    res.json({
      message: `${task.title} tamamlandı! +${task.coin_reward} coin`,
      coins_earned: task.coin_reward,
      total_coins: userResult.rows[0].coins
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Complete task error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  } finally {
    client.release();
  }
});

module.exports = router;
