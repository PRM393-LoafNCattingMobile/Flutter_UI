import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';

class ProductHeroImage extends StatelessWidget {
  const ProductHeroImage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: CafeImageFrame(
        imageUrl: product.picture,
        icon: Icons.local_cafe,
        label: product.name,
        borderRadius: 20,
      ),
    );
  }
}

class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CafeInfoChip(
            label: product.categoryName,
            icon: Icons.restaurant_menu,
          ),
          const SizedBox(height: 12),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ProductPriceRow(product: product),
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
    );
  }
}

class ProductPriceRow extends StatelessWidget {
  const ProductPriceRow({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          money(product.displayPrice),
          style: moneyTextStyle(
            Theme.of(context).textTheme.titleLarge,
            color: loafOrange,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (product.discountPrice != null) ...[
          const SizedBox(width: 10),
          Text(
            money(product.price),
            style: moneyTextStyle(
              Theme.of(context).textTheme.bodyMedium,
              color: loafMuted,
              fontWeight: FontWeight.w600,
            )?.copyWith(decoration: TextDecoration.lineThrough),
          ),
        ],
      ],
    );
  }
}

class ProductQuantitySelector extends StatelessWidget {
  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.canOrder,
    required this.maxQuantity,
    required this.stockCount,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool canOrder;
  final int maxQuantity;
  final int stockCount;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final displayedQuantity = canOrder ? quantity : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CafeCard(
          child: Row(
            children: [
              IconButton(
                onPressed: quantity > 1 ? onDecrease : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$displayedQuantity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: canOrder && quantity < maxQuantity
                    ? onIncrease
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const Spacer(),
              CafeInfoChip(
                label: canOrder
                    ? AppStrings.stockCountLabel(stockCount)
                    : AppStrings.outOfStockLabel,
                icon: canOrder ? Icons.inventory_2_outlined : Icons.block,
                color:
                    canOrder ? loafSuccess : Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
        if (canOrder && quantity >= maxQuantity) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.maxStockReachedMessage,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: loafMuted),
          ),
        ],
      ],
    );
  }
}

class ProductAddToCartButton extends StatelessWidget {
  const ProductAddToCartButton({
    super.key,
    required this.canOrder,
    required this.onPressed,
  });

  final bool canOrder;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: canOrder ? onPressed : null,
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text(AppStrings.addToCartButton),
    );
  }
}
