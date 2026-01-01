const express = require('express');
const pool = require('../config/database');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Get current user profile
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, name, coins, is_admin, created_at FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Get user task history
router.get('/tasks/history', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT ut.*, t.title, t.icon 
       FROM user_tasks ut 
       JOIN tasks t ON ut.task_id = t.id 
       WHERE ut.user_id = $1 
       ORDER BY ut.completed_at DESC 
       LIMIT 50`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get task history error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Get user reward history
router.get('/rewards/history', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT ur.*, r.title, r.icon 
       FROM user_rewards ur 
       JOIN rewards r ON ur.reward_id = r.id 
       WHERE ur.user_id = $1 
       ORDER BY ur.redeemed_at DESC 
       LIMIT 50`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get reward history error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// Get user stats
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const [tasksCompleted, totalEarned, rewardsRedeemed, totalSpent] = await Promise.all([
      pool.query('SELECT COUNT(*) as count FROM user_tasks WHERE user_id = $1', [userId]),
      pool.query('SELECT COALESCE(SUM(coins_earned), 0) as total FROM user_tasks WHERE user_id = $1', [userId]),
      pool.query('SELECT COUNT(*) as count FROM user_rewards WHERE user_id = $1', [userId]),
      pool.query('SELECT COALESCE(SUM(coins_spent), 0) as total FROM user_rewards WHERE user_id = $1', [userId])
    ]);

    res.json({
      tasks_completed: parseInt(tasksCompleted.rows[0].count),
      total_coins_earned: parseInt(totalEarned.rows[0].total),
      rewards_redeemed: parseInt(rewardsRedeemed.rows[0].count),
      total_coins_spent: parseInt(totalSpent.rows[0].total)
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

module.exports = router;
