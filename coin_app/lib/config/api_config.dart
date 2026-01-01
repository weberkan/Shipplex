class ApiConfig {
  // Backend sunucu adresi - kendi sunucunuzun IP/domain'ini yazın
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator için
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator için
  // static const String baseUrl = 'http://YOUR_SERVER_IP:3000/api'; // Gerçek cihaz için
  
  static const Duration timeout = Duration(seconds: 30);
}
