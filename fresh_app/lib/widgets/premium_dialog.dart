import 'package:flutter/material.dart';
import '../services/subscription_manager.dart';

class PremiumDialog extends StatelessWidget {
  const PremiumDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upgrade to Premium'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unlock premium features:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFeature('✓ Remove all ads'),
            _buildFeature('✓ Unlimited PDF exports'),
            _buildFeature('✓ Priority support'),
            const SizedBox(height: 16),
            const Text(
              '\$2.99/month',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cancel anytime',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Maybe Later'),
        ),
        TextButton(
          onPressed: () async {
            final subscriptionManager = SubscriptionManager();
            await subscriptionManager.restorePurchases();
            if (context.mounted) {
              Navigator.of(context).pop(false);
            }
          },
          child: const Text('Restore Purchase'),
        ),
        ElevatedButton(
          onPressed: () async {
            final subscriptionManager = SubscriptionManager();
            final success = await subscriptionManager.purchaseSubscription();
            if (context.mounted) {
              Navigator.of(context).pop(success);
            }
          },
          child: const Text('Subscribe'),
        ),
      ],
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const PremiumDialog(),
    );
    return result ?? false;
  }
}
