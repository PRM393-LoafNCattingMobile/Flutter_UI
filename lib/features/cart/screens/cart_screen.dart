import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/cart/widgets/cart_widgets.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
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
                    (item) => CartItemTile(
                      item: item,
                      isSyncing: cart.isSyncing,
                      onQuantityChanged: (quantity) => cart.updateSynced(
                        item.product,
                        quantity,
                        userId,
                      ),
                    ),
                  ),
                  CartSummaryCard(total: cart.total),
                ],
              ),
      ),
    );
  }
}
