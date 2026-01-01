class Reward {
  final int id;
  final String title;
  final String description;
  final int coinCost;
  final String icon;
  final bool isActive;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.coinCost,
    required this.icon,
    required this.isActive,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      coinCost: json['coin_cost'],
      icon: json['icon'] ?? 'gift',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'coin_cost': coinCost,
      'icon': icon,
      'is_active': isActive,
    };
  }
}
