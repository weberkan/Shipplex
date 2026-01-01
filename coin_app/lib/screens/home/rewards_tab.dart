import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reward_provider.dart';
import '../../services/api_service.dart';
import '../../utils/icon_helper.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userCoins = authProvider.user?.coins ?? 0;

    if (rewardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rewardProvider.rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz ödül yok',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => rewardProvider.fetchRewards(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rewardProvider.rewards.length,
        itemBuilder: (context, index) {
          final reward = rewardProvider.rewards[index];
          final canAfford = userCoins >= reward.coinCost;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: canAfford
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconHelper.getIcon(reward.icon),
                  color: canAfford
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey,
                  size: 28,
                ),
              ),
              title: Text(
                reward.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: canAfford ? null : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reward.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: canAfford ? Colors.orange : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.coinCost} coin',
                          style: TextStyle(
                            color: canAfford ? Colors.orange : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: FilledButton(
                onPressed: canAfford
                    ? () => _redeemReward(context, reward.id, authProvider)
                    : null,
                child: Text(canAfford ? 'Al' : 'Yetersiz'),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _redeemReward(
    BuildContext context,
    int rewardId,
    AuthProvider authProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödülü Al'),
        content: const Text('Bu ödülü almak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Al'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result =
          await context.read<RewardProvider>().redeemReward(rewardId);
      
      authProvider.updateCoins(result['total_coins']);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
