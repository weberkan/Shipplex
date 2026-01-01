import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'book':
        return Icons.menu_book;
      case 'calculate':
        return Icons.calculate;
      case 'language':
        return Icons.language;
      case 'assignment':
        return Icons.assignment;
      case 'quiz':
        return Icons.quiz;
      case 'games':
        return Icons.sports_esports;
      case 'movie':
        return Icons.movie;
      case 'outdoor':
        return Icons.park;
      case 'fastfood':
        return Icons.fastfood;
      case 'money':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      case 'task':
        return Icons.task_alt;
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports_soccer;
      case 'art':
        return Icons.palette;
      case 'science':
        return Icons.science;
      case 'computer':
        return Icons.computer;
      case 'phone':
        return Icons.phone_android;
      case 'shopping':
        return Icons.shopping_bag;
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'star':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }

  static List<String> get availableIcons => [
        'book',
        'calculate',
        'language',
        'assignment',
        'quiz',
        'games',
        'movie',
        'outdoor',
        'fastfood',
        'money',
        'gift',
        'task',
        'music',
        'sports',
        'art',
        'science',
        'computer',
        'phone',
        'shopping',
        'food',
        'travel',
        'star',
      ];
}
