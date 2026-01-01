-- Coin App Database Schema

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    coins INTEGER DEFAULT 0,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks (Görevler) - Coin kazandıran aktiviteler
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    coin_reward INTEGER NOT NULL,
    icon VARCHAR(50) DEFAULT 'task',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rewards (Ödüller/Harcamalar) - Coin harcanan alanlar
CREATE TABLE IF NOT EXISTS rewards (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    coin_cost INTEGER NOT NULL,
    icon VARCHAR(50) DEFAULT 'gift',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User completed tasks history
CREATE TABLE IF NOT EXISTS user_tasks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
    coins_earned INTEGER NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User redeemed rewards history
CREATE TABLE IF NOT EXISTS user_rewards (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    reward_id INTEGER REFERENCES rewards(id) ON DELETE CASCADE,
    coins_spent INTEGER NOT NULL,
    redeemed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data
INSERT INTO tasks (title, description, coin_reward, icon) VALUES
('Kitap Oku', '30 dakika kitap oku', 50, 'book'),
('Matematik Çalış', '1 saat matematik çalış', 100, 'calculate'),
('İngilizce Pratik', '20 kelime ezberle', 40, 'language'),
('Ödev Tamamla', 'Günlük ödevleri bitir', 80, 'assignment'),
('Test Çöz', 'Deneme testi çöz', 120, 'quiz');

INSERT INTO rewards (title, description, coin_cost, icon) VALUES
('30 dk Oyun', '30 dakika oyun oynama hakkı', 100, 'games'),
('Film İzle', '1 film izleme hakkı', 150, 'movie'),
('Dışarı Çık', 'Arkadaşlarla dışarı çıkma', 200, 'outdoor'),
('Atıştırmalık', 'Sevdiğin atıştırmalık', 80, 'fastfood'),
('Ekstra Cep Harçlığı', '10 TL ekstra harçlık', 300, 'money');
