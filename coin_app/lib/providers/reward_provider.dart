import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../services/api_service.dart';

class RewardProvider with ChangeNotifier {
  List<Reward> _rewards = [];
  bool _isLoading = false;

  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;

  Future<void> fetchRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/rewards');
      _rewards = (response['data'] as List)
          .map((json) => Reward.fromJson(json))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/rewards/all');
      _rewards = (response['data'] as List)
          .map((json) => Reward.fromJson(json))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> redeemReward(int rewardId) async {
    final response = await ApiService.post('/rewards/$rewardId/redeem', {});
    return response;
  }

  Future<void> createReward(Reward reward) async {
    final response = await ApiService.post('/rewards', reward.toJson());
    _rewards.insert(0, Reward.fromJson(response));
    notifyListeners();
  }

  Future<void> updateReward(int id, Reward reward) async {
    final response = await ApiService.put('/rewards/$id', reward.toJson());
    final index = _rewards.indexWhere((r) => r.id == id);
    if (index != -1) {
      _rewards[index] = Reward.fromJson(response);
      notifyListeners();
    }
  }

  Future<void> deleteReward(int id) async {
    await ApiService.delete('/rewards/$id');
    _rewards.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
