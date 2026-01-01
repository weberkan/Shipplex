import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reward_model.dart';
import '../../providers/reward_provider.dart';
import '../../utils/icon_helper.dart';

class RewardFormDialog extends StatefulWidget {
  final Reward? reward;

  const RewardFormDialog({super.key, this.reward});

  @override
  State<RewardFormDialog> createState() => _RewardFormDialogState();
}

class _RewardFormDialogState extends State<RewardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _coinController;
  String _selectedIcon = 'gift';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reward?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.reward?.description ?? '');
    _coinController =
        TextEditingController(text: widget.reward?.coinCost.toString() ?? '');
    _selectedIcon = widget.reward?.icon ?? 'gift';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rewardProvider = context.read<RewardProvider>();
      final reward = Reward(
        id: widget.reward?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        coinCost: int.parse(_coinController.text),
        icon: _selectedIcon,
        isActive: widget.reward?.isActive ?? true,
      );

      if (widget.reward != null) {
        await rewardProvider.updateReward(widget.reward!.id, reward);
      } else {
        await rewardProvider.createReward(reward);
      }

      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.reward != null ? 'Ödül güncellendi' : 'Ödül eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reward != null ? 'Ödülü Düzenle' : 'Yeni Ödül'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coinController,
                decoration: const InputDecoration(
                  labelText: 'Coin Maliyeti',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Coin miktarı gerekli';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
                decoration: const InputDecoration(
                  labelText: 'İkon',
                  border: OutlineInputBorder(),
                ),
                items: IconHelper.availableIcons.map((icon) {
                  return DropdownMenuItem(
                    value: icon,
                    child: Row(
                      children: [
                        Icon(IconHelper.getIcon(icon), size: 20),
                        const SizedBox(width: 8),
                        Text(icon),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedIcon = value!);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.reward != null ? 'Güncelle' : 'Ekle'),
        ),
      ],
    );
  }
}
