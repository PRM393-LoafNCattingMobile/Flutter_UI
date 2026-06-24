import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final canOrder = product.canOrder;
    final maxQuantity = canOrder ? product.unitInStock : 0;
    final displayedQuantity = canOrder ? quantity : 0;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: CafeImageFrame(
                imageUrl: product.picture,
                icon: Icons.local_cafe,
                label: product.name,
                borderRadius: 20,
              ),
            ),
            const SizedBox(height: 16),
            CafeCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CafeInfoChip(
                      label: product.categoryName, icon: Icons.restaurant_menu),
                  const SizedBox(height: 12),
                  Text(product.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    money(product.displayPrice),
                    style: moneyTextStyle(
                      Theme.of(context).textTheme.titleLarge,
                      color: loafOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description ?? AppStrings.productNoDescription,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: loafMuted, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CafeCard(
              child: Row(
                children: [
                  IconButton(
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$displayedQuantity',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                      onPressed: canOrder && quantity < maxQuantity
                          ? () => setState(() => quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline)),
                  const Spacer(),
                  CafeInfoChip(
                    label: canOrder
                        ? AppStrings.stockCountLabel(product.unitInStock)
                        : AppStrings.outOfStockLabel,
                    icon: canOrder
                        ? Icons.inventory_2_outlined
                        : Icons.block,
                    color: canOrder
                        ? loafSuccess
                        : Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
            if (canOrder && quantity >= maxQuantity) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.maxStockReachedMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: loafMuted),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: canOrder
                  ? () async {
                      final userId = context.read<AuthProvider>().user?.userId;
                      final result = await context
                          .read<CartProvider>()
                          .addWithSyncResult(product, quantity, userId);
                      if (!context.mounted) return;
                      final message = switch (result.status) {
                        CartAddStatus.added =>
                          AppStrings.addedItemsToCartMessage(
                              result.addedQuantity),
                        CartAddStatus.stockLimit =>
                          AppStrings.cartStockLimitReachedMessage,
                        CartAddStatus.authRequired =>
                          AppStrings.cartSessionExpiredMessage,
                        CartAddStatus.syncFailed =>
                          AppStrings.cartSyncFailedMessage,
                      };
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(AppStrings.addToCartButton),
            ),
          ],
        ),
      ),
    );
  }
}
