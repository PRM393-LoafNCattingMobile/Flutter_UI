import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/checkout_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final userId =
        context.select<AuthProvider, int?>((auth) => auth.user?.userId);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.cartTitle(cart.count))),
      body: CafeSurface(
        child: cart.items.isEmpty
            ? const EmptyView(AppStrings.cartEmptyMessage)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  const CafeHeroHeader(
                    title: AppStrings.cartHeroTitle,
                    subtitle: AppStrings.cartHeroSubtitle,
                    icon: Icons.shopping_bag,
                  ),
                  ...cart.items.map(
                    (item) => Padding(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(
                                    money(item.product.displayPrice),
                                    style: moneyTextStyle(
                                      Theme.of(context).textTheme.bodySmall,
                                      color: loafMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                                onPressed: cart.isSyncing
                                    ? null
                                    : () => cart.updateSynced(
                                          item.product,
                                          item.quantity - 1,
                                          userId,
                                        ),
                                icon: const Icon(Icons.remove)),
                            Text('${item.quantity}',
                                style: Theme.of(context).textTheme.titleMedium),
                            IconButton(
                                onPressed:
                                    item.quantity < item.product.unitInStock &&
                                            !cart.isSyncing
                                        ? () => cart.updateSynced(
                                              item.product,
                                              item.quantity + 1,
                                              userId,
                                            )
                                        : null,
                                icon: const Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CafeCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(AppStrings.totalLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: loafMuted)),
                            const Spacer(),
                            Text(
                              money(cart.total),
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
                              MaterialPageRoute(
                                  builder: (_) => const CheckoutScreen())),
                          icon: const Icon(Icons.payment),
                          label: const Text(AppStrings.checkoutButton),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
