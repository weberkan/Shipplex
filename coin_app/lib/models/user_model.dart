class User {
  final int id;
  final String email;
  final String name;
  final int coins;
  final bool isAdmin;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.coins,
    required this.isAdmin,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      coins: json['coins'] ?? 0,
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  User copyWith({int? coins}) {
    return User(
      id: id,
      email: email,
      name: name,
      coins: coins ?? this.coins,
      isAdmin: isAdmin,
      createdAt: createdAt,
    );
  }
}
