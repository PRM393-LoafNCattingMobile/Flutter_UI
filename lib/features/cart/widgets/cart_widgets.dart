import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/checkout/screens/checkout_screen.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.isSyncing,
    required this.onQuantityChanged,
  });

  final CartItem item;
  final bool isSyncing;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CafeCard(
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: CafeImageFrame(
                imageUrl: item.product.picture,
                icon: Icons.local_cafe,
                borderRadius: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: CartItemInfo(item: item)),
            CartQuantityControls(
              quantity: item.quantity,
              maxQuantity: item.product.unitInStock,
              isSyncing: isSyncing,
              onQuantityChanged: onQuantityChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemInfo extends StatelessWidget {
  const CartItemInfo({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.product.name, style: Theme.of(context).textTheme.titleMedium),
        Text(
          money(item.product.displayPrice),
          style: moneyTextStyle(
            Theme.of(context).textTheme.bodySmall,
            color: loafMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CartQuantityControls extends StatelessWidget {
  const CartQuantityControls({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.isSyncing,
    required this.onQuantityChanged,
  });

  final int quantity;
  final int maxQuantity;
  final bool isSyncing;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: isSyncing ? null : () => onQuantityChanged(quantity - 1),
          icon: const Icon(Icons.remove),
        ),
        Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          onPressed: quantity < maxQuantity && !isSyncing
              ? () => onQuantityChanged(quantity + 1)
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                AppStrings.totalLabel,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: loafMuted),
              ),
              const Spacer(),
              Text(
                money(total),
                style: moneyTextStyle(
                  Theme.of(context).textTheme.titleLarge,
                  color: loafOrange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            ),
            icon: const Icon(Icons.payment),
            label: const Text(AppStrings.checkoutButton),
          ),
        ],
      ),
    );
  }
}
