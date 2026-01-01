class Task {
  final int id;
  final String title;
  final String description;
  final int coinReward;
  final String icon;
  final bool isActive;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.coinReward,
    required this.icon,
    required this.isActive,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      coinReward: json['coin_reward'],
      icon: json['icon'] ?? 'task',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'coin_reward': coinReward,
      'icon': icon,
      'is_active': isActive,
    };
  }
}
