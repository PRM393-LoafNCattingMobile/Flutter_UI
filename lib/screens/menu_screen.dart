import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/cart_screen.dart';
import 'package:loafncatting_mobile/screens/product_detail_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CatalogProvider>().load();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return Scaffold(
      body: CafeSurface(
        child: Column(
          children: [
            const _MenuHeader(),
            _MenuSearchBar(
              searchController: searchController,
              onApplyFilter: (value) => catalog.applyFilter(keyword: value),
            ),
            SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.pets, size: 17),
                    label: const Text(AppStrings.allCategoryLabel),
                    selected: catalog.selectedCategoryId == null,
                    onSelected: (_) => catalog.applyFilter(categoryId: null),
                  ),
                  const SizedBox(width: 8),
                  ...catalog.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(_categoryIcon(category.name), size: 17),
                        label: Text(category.name),
                        selected:
                            catalog.selectedCategoryId == category.categoryId,
                        onSelected: (_) => catalog.applyFilter(
                            categoryId: category.categoryId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CafeSectionTitle(
              title: AppStrings.popularPicksTitle,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              subtitle: catalog.products.isEmpty
                  ? null
                  : AppStrings.menuItemsToday(catalog.products.length),
            ),
            Expanded(
              child: catalog.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : catalog.error != null
                      ? ErrorView(catalog.error!, onRetry: catalog.load)
                      : catalog.products.isEmpty
                          ? const EmptyView(AppStrings.menuEmptyMessage)
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              itemCount: catalog.products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, index) => _MenuProductCard(
                                product: catalog.products[index],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSearchBar extends StatelessWidget {
  const _MenuSearchBar({
    required this.searchController,
    required this.onApplyFilter,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onApplyFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: AppStrings.menuSearchHint,
              ),
              onSubmitted: onApplyFilter,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: loafBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14D2691E),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => onApplyFilter(searchController.text),
              icon: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [loafSoftOrange, loafOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: .18),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const CafeIconBadge(icon: Icons.pets, inverted: true, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.menuGreeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.menuWelcomeBack,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: .88),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
                icon: const Icon(Icons.shopping_bag_outlined),
                color: Colors.white,
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
                  top: 3,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Text('$cartCount',
                        style: const TextStyle(
                            color: loafOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuProductCard extends StatelessWidget {
  const _MenuProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final availableColor =
        product.isAvailable ? loafSuccess : Theme.of(context).colorScheme.error;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product))),
      child: CafeCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 96,
              child: CafeImageFrame(
                imageUrl: product.picture,
                icon: _categoryIcon(product.categoryName),
                label: product.name,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? product.categoryName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: loafMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(money(product.displayPrice),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: loafOrange)),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: product.isAvailable
                      ? () {
                          final added =
                              context.read<CartProvider>().add(product, 1);
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.hideCurrentSnackBar();
                          messenger.showSnackBar(SnackBar(
                              content: Text(added > 0
                                  ? AppStrings.productAddedToCart(product.name)
                                  : AppStrings.productStockLimitReached(
                                      product.name))));
                        }
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(AppStrings.addButton),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(74, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                  ),
                ),
                const SizedBox(height: 8),
                CafeInfoChip(
                  label: product.isAvailable
                      ? AppStrings.inStockLabel
                      : AppStrings.outOfStockLabel,
                  color: availableColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('drink') ||
      lower.contains('coffee') ||
      lower.contains('latte') ||
      lower.contains('uống')) {
    return Icons.local_cafe;
  }
  if (lower.contains('pastr') ||
      lower.contains('cake') ||
      lower.contains('dessert')) {
    return Icons.bakery_dining;
  }
  if (lower.contains('main') ||
      lower.contains('food') ||
      lower.contains('panini') ||
      lower.contains('ăn') ||
      lower.contains('mèo')) {
    return Icons.restaurant;
  }
  return Icons.local_cafe;
}
