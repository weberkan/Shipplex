import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reward_model.dart';
import '../../providers/reward_provider.dart';
import '../../utils/icon_helper.dart';
import 'reward_form_dialog.dart';

class AdminRewardsTab extends StatefulWidget {
  const AdminRewardsTab({super.key});

  @override
  State<AdminRewardsTab> createState() => _AdminRewardsTabState();
}

class _AdminRewardsTabState extends State<AdminRewardsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RewardProvider>().fetchAllRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();

    return Scaffold(
      body: rewardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rewardProvider.rewards.isEmpty
              ? const Center(child: Text('Henüz ödül yok'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rewardProvider.rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewardProvider.rewards[index];
                    return _RewardCard(reward: reward);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRewardForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Ödül Ekle'),
      ),
    );
  }

  void _showRewardForm(BuildContext context, [Reward? reward]) {
    showDialog(
      context: context,
      builder: (_) => RewardFormDialog(reward: reward),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;

  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: reward.isActive
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            IconHelper.getIcon(reward.icon),
            color: reward.isActive
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                reward.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: reward.isActive ? null : Colors.grey,
                ),
              ),
            ),
            if (!reward.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pasif',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        subtitle: Text('${reward.coinCost} coin'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(reward.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(reward.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleAction(context, value),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) async {
    final rewardProvider = context.read<RewardProvider>();

    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (_) => RewardFormDialog(reward: reward),
        );
        break;
      case 'toggle':
        final updatedReward = Reward(
          id: reward.id,
          title: reward.title,
          description: reward.description,
          coinCost: reward.coinCost,
          icon: reward.icon,
          isActive: !reward.isActive,
        );
        await rewardProvider.updateReward(reward.id, updatedReward);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ödülü Sil'),
            content: Text('${reward.title} ödülünü silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await rewardProvider.deleteReward(reward.id);
        }
        break;
    }
  }
}
