# Coin App

Görev tamamla, coin kazan ve ödüllere harca! Eğitim odaklı motivasyon uygulaması.

## Özellikler

- **Kullanıcı Sistemi**: Kayıt/Giriş
- **Görevler**: Ders çalışma görevlerini tamamlayarak coin kazan
- **Ödüller**: Kazanılan coinleri ödüllere harca
- **Admin Paneli**: Görev ve ödülleri dinamik olarak ekle/düzenle/sil
- **İstatistikler**: Tamamlanan görevler, kazanılan/harcanan coinler

## Proje Yapısı

```
Shipplex/
├── backend/           # Node.js + Express API
│   ├── src/
│   │   ├── config/    # Veritabanı bağlantısı
│   │   ├── database/  # SQL şeması
│   │   ├── middleware/# Auth middleware
│   │   ├── routes/    # API endpoints
│   │   └── index.js   # Ana dosya
│   └── package.json
│
└── coin_app/          # Flutter mobil uygulama
    └── lib/
        ├── config/    # API ayarları
        ├── models/    # Veri modelleri
        ├── providers/ # State management
        ├── screens/   # UI ekranları
        ├── services/  # API servisi
        └── utils/     # Yardımcı fonksiyonlar
```

## Kurulum

### 1. PostgreSQL Veritabanı

```sql
-- Yeni veritabanı oluştur
CREATE DATABASE coin_app;

-- Şemayı çalıştır
-- backend/src/database/schema.sql dosyasını çalıştırın
```

### 2. Backend

```bash
cd backend

# .env dosyasını oluştur
cp .env.example .env

# .env dosyasını düzenle:
# DATABASE_URL=postgresql://username:password@localhost:5432/coin_app
# JWT_SECRET=guclu-bir-secret-key

# Bağımlılıkları yükle
npm install

# Sunucuyu başlat
npm run dev
```

### 3. Flutter Uygulaması

```bash
cd coin_app

# Bağımlılıkları yükle
flutter pub get

# API adresini güncelle (lib/config/api_config.dart)
# Emulator için: http://10.0.2.2:3000/api
# Gerçek cihaz için: http://SUNUCU_IP:3000/api

# Uygulamayı çalıştır
flutter run
```

## Admin Kullanıcısı Oluşturma

Veritabanında bir kullanıcıyı admin yapmak için:

```sql
UPDATE users SET is_admin = true WHERE email = 'admin@example.com';
```

## API Endpoints

### Auth
- `POST /api/auth/register` - Kayıt
- `POST /api/auth/login` - Giriş

### Tasks (Görevler)
- `GET /api/tasks` - Aktif görevleri listele
- `GET /api/tasks/all` - Tüm görevleri listele (Admin)
- `POST /api/tasks` - Görev ekle (Admin)
- `PUT /api/tasks/:id` - Görev güncelle (Admin)
- `DELETE /api/tasks/:id` - Görev sil (Admin)
- `POST /api/tasks/:id/complete` - Görevi tamamla (Coin kazan)

### Rewards (Ödüller)
- `GET /api/rewards` - Aktif ödülleri listele
- `GET /api/rewards/all` - Tüm ödülleri listele (Admin)
- `POST /api/rewards` - Ödül ekle (Admin)
- `PUT /api/rewards/:id` - Ödül güncelle (Admin)
- `DELETE /api/rewards/:id` - Ödül sil (Admin)
- `POST /api/rewards/:id/redeem` - Ödülü al (Coin harca)

### User
- `GET /api/user/profile` - Profil bilgisi
- `GET /api/user/stats` - İstatistikler
- `GET /api/user/tasks/history` - Görev geçmişi
- `GET /api/user/rewards/history` - Ödül geçmişi

## Teknolojiler

**Backend:**
- Node.js + Express
- PostgreSQL
- JWT Authentication
- bcryptjs

**Mobile:**
- Flutter 3.x
- Provider (State Management)
- HTTP package
- Shared Preferences
