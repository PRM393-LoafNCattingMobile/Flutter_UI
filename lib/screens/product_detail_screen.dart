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
    final catalog = context.watch<CatalogProvider>();
    final perfectWithProducts =
        _perfectWithProducts(product, catalog.allProducts);
    final similarProducts = _similarProducts(product, catalog.allProducts);
    final maxQuantity = product.unitInStock < 1 ? 1 : product.unitInStock;
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
                  Row(
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
                  Text('$quantity',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                      onPressed: product.isAvailable && quantity < maxQuantity
                          ? () => setState(() => quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline)),
                  const Spacer(),
                  CafeInfoChip(
                    label: product.isAvailable
                        ? AppStrings.stockCountLabel(product.unitInStock)
                        : AppStrings.outOfStockLabel,
                    icon: product.isAvailable
                        ? Icons.inventory_2_outlined
                        : Icons.block,
                    color: product.isAvailable
                        ? loafSuccess
                        : Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
            if (product.isAvailable && quantity >= maxQuantity) ...[
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
              onPressed: product.isAvailable
                  ? () {
                      final added =
                          context.read<CartProvider>().add(product, quantity);
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            added > 0
                                ? AppStrings.addedItemsToCartMessage(added)
                                : AppStrings.cartStockLimitReachedMessage,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(AppStrings.addToCartButton),
            ),
            if (perfectWithProducts.isNotEmpty) ...[
              const SizedBox(height: 22),
              _ProductRecommendationShelf(
                title: AppStrings.perfectWithTitle,
                products: perfectWithProducts,
              ),
            ],
            if (similarProducts.isNotEmpty) ...[
              const SizedBox(height: 22),
              _ProductRecommendationShelf(
                title: AppStrings.similarItemsTitle,
                products: similarProducts,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductRecommendationShelf extends StatelessWidget {
  const _ProductRecommendationShelf({
    required this.title,
    required this.products,
  });

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SizedBox(
          height: 198,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _RecommendationProductCard(
              product: products[index],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationProductCard extends StatelessWidget {
  const _RecommendationProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: CafeCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 86,
                child: CafeImageFrame(
                  imageUrl: product.picture,
                  icon: Icons.local_cafe,
                  label: product.name,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                money(product.displayPrice),
                style: moneyTextStyle(
                  Theme.of(context).textTheme.bodyMedium,
                  color: loafOrange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Product> _similarProducts(Product current, List<Product> products) {
  return _candidateProducts(current, products)
      .where((product) => product.categoryId == current.categoryId)
      .take(8)
      .toList();
}

List<Product> _perfectWithProducts(Product current, List<Product> products) {
  final currentCategory = current.categoryName.toLowerCase();
  final candidates = _candidateProducts(current, products);
  final paired = candidates
      .where((product) =>
          _isPerfectWithCategory(currentCategory, product.categoryName))
      .take(8)
      .toList();

  if (paired.isNotEmpty) {
    return paired;
  }

  return candidates
      .where((product) => product.categoryId != current.categoryId)
      .take(8)
      .toList();
}

List<Product> _candidateProducts(Product current, List<Product> products) {
  final seen = <int>{};
  return products.where((product) {
    if (product.productId == current.productId ||
        !product.isAvailable ||
        product.unitInStock <= 0 ||
        !seen.add(product.productId)) {
      return false;
    }
    return true;
  }).toList();
}

bool _isPerfectWithCategory(String currentCategory, String categoryName) {
  final target = categoryName.toLowerCase();

  if (_containsAny(currentCategory, ['coffee', 'cafe', 'cà phê'])) {
    return _containsAny(target, ['cake', 'pastry', 'bread', 'bánh', 'cookie']);
  }
  if (_containsAny(
      currentCategory, ['tea', 'matcha', 'soda', 'drink', 'trà'])) {
    return _containsAny(target, ['cake', 'pastry', 'bread', 'bánh', 'snack']);
  }
  if (_containsAny(currentCategory, ['cake', 'pastry', 'bread', 'bánh'])) {
    return _containsAny(
      target,
      ['coffee', 'cafe', 'cà phê', 'tea', 'matcha', 'trà'],
    );
  }
  if (_containsAny(currentCategory, ['cat', 'mèo'])) {
    return _containsAny(target, ['cat', 'mèo']);
  }

  return false;
}

bool _containsAny(String value, List<String> needles) {
  return needles.any(value.contains);
}
