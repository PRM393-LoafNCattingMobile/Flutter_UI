import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:flutter/services.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/features/cart/screens/cart_screen.dart';
import 'package:loafncatting_mobile/features/orders/screens/order_history_screen.dart';
import 'package:loafncatting_mobile/features/product/screens/product_detail_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';
part '../widgets/menu_filter_sheet.dart';

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
              hasMenuFilters: catalog.hasMenuFilters,
              onApplyFilter: (value) =>
                  catalog.applyFilter(keyword: value.trim()),
              onOpenFilters: () => _showMenuFilters(context, catalog),
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
            if (catalog.hasMenuFilters) _ActiveMenuFilters(catalog: catalog),
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

String? _telexToneKeyFor(LogicalKeyboardKey key) {
  return switch (key) {
    LogicalKeyboardKey.keyS => 's',
    LogicalKeyboardKey.keyF => 'f',
    LogicalKeyboardKey.keyR => 'r',
    LogicalKeyboardKey.keyX => 'x',
    LogicalKeyboardKey.keyJ => 'j',
    _ => null,
  };
}

String? _repairBrokenUniKeyTelexTone({
  required String previousText,
  required String incomingText,
  required String? toneKey,
}) {
  if (toneKey == null || previousText.isEmpty || incomingText.isEmpty) {
    return null;
  }

  final tone = _telexToneIndexes[toneKey];
  if (tone == null) return null;

  final targetIndex = _findToneTargetIndex(previousText);
  if (targetIndex == null) return null;

  final target = previousText[targetIndex];
  final tonedTarget = _withTone(target, tone);
  if (tonedTarget == target) return null;

  final deletedTargetText = previousText.substring(0, targetIndex) +
      previousText.substring(targetIndex + 1);
  if (incomingText != deletedTargetText) return null;

  return previousText.substring(0, targetIndex) +
      tonedTarget +
      previousText.substring(targetIndex + 1);
}

const _telexToneIndexes = {
  's': 1,
  'f': 2,
  'r': 3,
  'x': 4,
  'j': 5,
};

const _vowelToneVariants = <String, List<String>>{
  'a': ['a', '\u00e1', '\u00e0', '\u1ea3', '\u00e3', '\u1ea1'],
  '\u0103': ['\u0103', '\u1eaf', '\u1eb1', '\u1eb3', '\u1eb5', '\u1eb7'],
  '\u00e2': ['\u00e2', '\u1ea5', '\u1ea7', '\u1ea9', '\u1eab', '\u1ead'],
  'e': ['e', '\u00e9', '\u00e8', '\u1ebb', '\u1ebd', '\u1eb9'],
  '\u00ea': ['\u00ea', '\u1ebf', '\u1ec1', '\u1ec3', '\u1ec5', '\u1ec7'],
  'i': ['i', '\u00ed', '\u00ec', '\u1ec9', '\u0129', '\u1ecb'],
  'o': ['o', '\u00f3', '\u00f2', '\u1ecf', '\u00f5', '\u1ecd'],
  '\u00f4': ['\u00f4', '\u1ed1', '\u1ed3', '\u1ed5', '\u1ed7', '\u1ed9'],
  '\u01a1': ['\u01a1', '\u1edb', '\u1edd', '\u1edf', '\u1ee1', '\u1ee3'],
  'u': ['u', '\u00fa', '\u00f9', '\u1ee7', '\u0169', '\u1ee5'],
  '\u01b0': ['\u01b0', '\u1ee9', '\u1eeb', '\u1eed', '\u1eef', '\u1ef1'],
  'y': ['y', '\u00fd', '\u1ef3', '\u1ef7', '\u1ef9', '\u1ef5'],
};

final _asciiLetterPattern = RegExp(r'[A-Za-z]');

int? _findToneTargetIndex(String text) {
  var end = text.length - 1;
  while (end >= 0 && !_isVietnameseWordCharacter(text[end])) {
    end--;
  }
  if (end < 0) return null;

  var start = end;
  while (start >= 0 && _isVietnameseWordCharacter(text[start])) {
    start--;
  }
  start++;

  final vowelIndexes = <int>[];
  for (var index = start; index <= end; index++) {
    if (_baseVowelKey(text[index]) != null) {
      vowelIndexes.add(index);
    }
  }
  if (vowelIndexes.isEmpty) return null;

  for (final index in vowelIndexes.reversed) {
    final key = _baseVowelKey(text[index]);
    if (key == '\u0103' ||
        key == '\u00e2' ||
        key == '\u00ea' ||
        key == '\u00f4' ||
        key == '\u01a1' ||
        key == '\u01b0') {
      return index;
    }
  }

  if (end > start && text.substring(end - 1, end + 1).toLowerCase() == 'ao') {
    return end - 1;
  }

  return vowelIndexes.last;
}

bool _isVietnameseWordCharacter(String value) {
  return _asciiLetterPattern.hasMatch(value) ||
      _baseVowelKey(value) != null ||
      value == '\u0111' ||
      value == '\u0110';
}

String? _baseVowelKey(String value) {
  final lower = value.toLowerCase();
  for (final entry in _vowelToneVariants.entries) {
    if (entry.value.contains(lower)) {
      return entry.key;
    }
  }
  return null;
}

String _withTone(String value, int tone) {
  final lower = value.toLowerCase();
  for (final variants in _vowelToneVariants.values) {
    if (variants.contains(lower)) {
      final toned = variants[tone];
      return value == lower ? toned : toned.toUpperCase();
    }
  }
  return value;
}


class _MenuSearchTelexRepairFormatter extends TextInputFormatter {
  String? _pendingToneKey;

  void registerToneKey(LogicalKeyboardKey key) {
    final toneKey = _telexToneKeyFor(key);
    if (toneKey != null) {
      _pendingToneKey = toneKey;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final toneKey = _pendingToneKey;
    _pendingToneKey = null;

    if (toneKey == null || !newValue.composing.isCollapsed) {
      return newValue;
    }

    final repairedText = _repairBrokenUniKeyTelexTone(
      previousText: oldValue.text,
      incomingText: newValue.text,
      toneKey: toneKey,
    );
    if (repairedText == null || repairedText == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: repairedText,
      selection: TextSelection.collapsed(offset: repairedText.length),
    );
  }
}

class _MenuSearchBar extends StatefulWidget {
  const _MenuSearchBar({
    required this.searchController,
    required this.hasMenuFilters,
    required this.onApplyFilter,
    required this.onOpenFilters,
  });

  final TextEditingController searchController;
  final bool hasMenuFilters;
  final ValueChanged<String> onApplyFilter;
  final VoidCallback onOpenFilters;

  @override
  State<_MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<_MenuSearchBar> {
  late final _MenuSearchTelexRepairFormatter _telexRepairFormatter =
      _MenuSearchTelexRepairFormatter();
  late final FocusNode _searchFocusNode = FocusNode(
    onKeyEvent: _handleKeyEvent,
  );

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleHardwareKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKeyEvent);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: widget.searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              hintLocales: const [Locale('vi', 'VN')],
              inputFormatters: [_telexRepairFormatter],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: AppStrings.menuSearchHint,
              ),
              onSubmitted: (value) => widget.onApplyFilter(value.trim()),
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: IconButton(
                    onPressed: widget.onOpenFilters,
                    icon: const Icon(Icons.tune),
                  ),
                ),
                if (widget.hasMenuFilters)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: loafOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _telexRepairFormatter.registerToneKey(event.logicalKey);
    }
    return KeyEventResult.ignored;
  }

  bool _handleHardwareKeyEvent(KeyEvent event) {
    if (_searchFocusNode.hasFocus && event is KeyDownEvent) {
      _telexRepairFormatter.registerToneKey(event.logicalKey);
    }
    return false;
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    final username = context.watch<AuthProvider>().user?.name.trim();
    final greetingName =
        username == null || username.isEmpty ? 'bạn' : username;
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
          const CafeIconBadge(icon: Icons.pets, inverted: true, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.menuGreeting(greetingName),
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
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
            icon: const Icon(Icons.receipt_long_outlined),
            color: Colors.white,
            tooltip: AppStrings.orderHistoryTitle,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
                icon: const Icon(Icons.shopping_cart_outlined),
                color: Colors.white,
                tooltip: AppStrings.cartTitlePrefix,
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
    final canOrder = product.canOrder;
    final availableColor =
        canOrder ? loafSuccess : Theme.of(context).colorScheme.error;
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
                Text(
                  money(product.displayPrice),
                  style: moneyTextStyle(
                    Theme.of(context).textTheme.titleMedium,
                    color: loafOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: canOrder
                      ? () async {
                          final userId =
                              context.read<AuthProvider>().user?.userId;
                          final result = await context
                              .read<CartProvider>()
                              .addWithSyncResult(product, 1, userId);
                          if (!context.mounted) return;
                          final message = switch (result.status) {
                            CartAddStatus.added =>
                              AppStrings.productAddedToCart(product.name),
                            CartAddStatus.stockLimit =>
                              AppStrings.productStockLimitReached(product.name),
                            CartAddStatus.authRequired =>
                              AppStrings.cartSessionExpiredMessage,
                            CartAddStatus.syncFailed =>
                              AppStrings.cartSyncFailedMessage,
                          };
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.hideCurrentSnackBar();
                          messenger.showSnackBar(
                            SnackBar(content: Text(message)),
                          );
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
                  label: canOrder
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

String _priceRangeLabel(double min, double max) =>
    '${_formatPriceSliderLabel(min)} - ${_formatPriceSliderLabel(max)}';

String _formatPriceSliderLabel(double price) {
  final rounded = price.round();
  if (rounded % 1000 == 0) {
    return '${rounded ~/ 1000}k';
  }
  return money(price);
}

int _priceSliderDivisions(double min, double max) {
  final divisions = ((max - min) / 10000).round();
  return divisions < 1 ? 1 : divisions;
}

String _sortOptionLabel(ProductSortOption option) {
  return switch (option) {
    ProductSortOption.defaultOrder => 'M\u1eb7c \u0111\u1ecbnh',
    ProductSortOption.nameAZ => 'T\u00ean A-Z',
    ProductSortOption.priceLowHigh => 'Giá Thấp - Cao',
    ProductSortOption.priceHighLow => 'Giá Cao - Thấp',
  };
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
