import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/features/checkout/screens/payment_webview_screen.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';
part '../widgets/checkout_widgets.dart';

const supportedCheckoutPaymentMethods = [
  AppStrings.cashPaymentMethod,
  AppStrings.bankTransferPaymentMethod,
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  String paymentMethod = AppStrings.cashPaymentMethod;
  bool placing = false;
  bool loadingPendingPayment = false;
  String? error;
  bool didSeedUser = false;
  bool didLoadPendingPayment = false;
  Order? pendingPaymentOrder;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (didSeedUser) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phoneNumber;
      if (!didLoadPendingPayment) {
        didLoadPendingPayment = true;
        unawaited(_loadPendingPaymentOrder(user.userId));
      }
    }
    didSeedUser = true;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.checkoutTitle)),
      body: CafeSurface(
        child: Builder(
          builder: (context) {
            final hasPendingPayment = pendingPaymentOrder != null;
            if (cart.items.isEmpty && !hasPendingPayment) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const EmptyView(AppStrings.checkoutEmptyCartMessage),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.backToCartButton),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (auth.user == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ErrorView(AppStrings.checkoutLoginRequiredMessage),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.login, (_) => false),
                        child: const Text(AppStrings.goToLoginButton),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Form(
              key: formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  const CafeHeroHeader(
                    title: AppStrings.checkoutHeroTitle,
                    subtitle: AppStrings.checkoutHeroSubtitle,
                    icon: Icons.receipt_long,
                  ),
                  if (loadingPendingPayment) ...[
                    const SizedBox(height: 14),
                    const CafeCard(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else if (hasPendingPayment) ...[
                    const SizedBox(height: 14),
                    _PendingPaymentCard(
                      order: pendingPaymentOrder!,
                      onResume: placing
                          ? null
                          : () => _resumePendingPayment(
                                auth,
                                cart,
                                pendingPaymentOrder!,
                              ),
                      onRefresh: placing || auth.user == null
                          ? null
                          : () => _loadPendingPaymentOrder(auth.user!.userId),
                    ),
                  ] else ...[
                    _CheckoutSummaryCard(cart: cart),
                    const SizedBox(height: 14),
                    _CheckoutFormCard(
                      nameController: nameController,
                      phoneController: phoneController,
                      noteController: noteController,
                      paymentMethod: paymentMethod,
                      onPaymentMethodChanged: (value) {
                        if (value != null) {
                          setState(() => paymentMethod = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed:
                          placing ? null : () => _submitOrder(auth, cart),
                      icon: placing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: const Text(AppStrings.placeOrderButton),
                    ),
                  ],
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadPendingPaymentOrder(int userId) async {
    if (!mounted) return;
    setState(() {
      loadingPendingPayment = true;
    });

    final api = context.read<AuthProvider>().api;
    final cart = context.read<CartProvider>();
    final hadPendingPayment = pendingPaymentOrder != null;
    try {
      final pending = await api.getPendingPaymentOrder(userId);
      if ((pending != null || hadPendingPayment) && cart.items.isNotEmpty) {
        await cart.clearSynced(userId);
      }

      if (!mounted) return;
      setState(() {
        pendingPaymentOrder = pending;
      });
    } catch (_) {
      // Checkout can still fall back to server-side validation on submit.
    } finally {
      if (mounted) {
        setState(() {
          loadingPendingPayment = false;
        });
      }
    }
  }

  Future<void> _submitOrder(AuthProvider auth, CartProvider cart) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    if (auth.user == null || cart.items.isEmpty) return;

    setState(() {
      placing = true;
      error = null;
    });

    final api = auth.api;
    try {
      final pending = await api.getPendingPaymentOrder(auth.user!.userId);
      if (pending != null) {
        if (!mounted) return;
        setState(() {
          pendingPaymentOrder = pending;
        });
        final shouldResume = await _showPendingPaymentDialog(pending);
        if (shouldResume == true && mounted) {
          await _resumePendingPayment(auth, cart, pending);
        }
        return;
      }

      final order = await api.createOrder({
        'userId': auth.user!.userId,
        'tableId': null,
        'reservationId': null,
        'orderType': AppStrings.takeAwayOrderType,
        'note': noteController.text.trim(),
        'paymentMethod': paymentMethod,
        'items': cart.items
            .map((item) => {
                  'productId': item.product.productId,
                  'quantity': item.quantity
                })
            .toList(),
      });

      // Chuyển khoản -> đi qua PayOS (QR MB Bank), poll tới khi trả xong.
      if (paymentMethod == AppStrings.bankTransferPaymentMethod) {
        final orderId = order['orderId'] as int;
        final createdOrder = Order.fromJson(order);
        await cart.clearSynced(auth.user!.userId);
        if (!mounted) return;
        setState(() {
          pendingPaymentOrder = createdOrder;
        });

        final link = await api.createPaymentLink(orderId);
        if (!mounted) return;
        final paid = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(
              api: api,
              orderId: orderId,
              checkoutUrl: link['checkoutUrl'] as String,
            ),
          ),
        );
        if (!mounted) return;
        if (paid != true) {
          await _refreshPendingAfterUnfinishedPayment(
            api: api,
            cart: cart,
            userId: auth.user!.userId,
            orderId: orderId,
            fallbackPendingOrder: createdOrder,
            pendingMessage:
                'Chưa hoàn tất thanh toán. Đơn đang chờ thanh toán, bạn có thể thanh toán tiếp bên trên.',
          );
          return;
        }
      }

      await cart.clearSynced(auth.user!.userId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text(AppStrings.orderPlacedSuccessTitle),
          content: Text(
            AppStrings.orderPlacedSuccessMessage(nameController.text.trim()),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.okButton),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).popUntil(
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
      );
    } catch (e) {
      setState(() => error = friendlyErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => placing = false);
      }
    }
  }

  Future<bool?> _showPendingPaymentDialog(Order pending) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.pendingPaymentTitle),
        content: Text(
          'Đơn #${pending.orderId} đang chờ thanh toán. '
          'Vui lòng thanh toán hoặc nhờ staff hủy đơn này trước khi tạo đơn mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.closeButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.continuePaymentButton),
          ),
        ],
      ),
    );
  }

  Future<void> _resumePendingPayment(
    AuthProvider auth,
    CartProvider cart,
    Order order,
  ) async {
    if (auth.user == null) return;
    setState(() {
      placing = true;
      error = null;
    });

    try {
      final link = await auth.api.createPaymentLink(order.orderId);
      if (!mounted) return;
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            api: auth.api,
            orderId: order.orderId,
            checkoutUrl: link['checkoutUrl'] as String,
          ),
        ),
      );
      if (!mounted) return;
      if (paid == true) {
        await cart.clearSynced(auth.user!.userId);
        if (!mounted) return;
        setState(() {
          pendingPaymentOrder = null;
        });
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text(AppStrings.orderPlacedSuccessTitle),
            content: Text(AppStrings.orderPaidMessage(order.orderId)),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(AppStrings.okButton),
              ),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.of(context).popUntil(
          (route) => route.settings.name == AppRoutes.home || route.isFirst,
        );
      } else {
        await _refreshPendingAfterUnfinishedPayment(
          api: auth.api,
          cart: cart,
          userId: auth.user!.userId,
          orderId: order.orderId,
          fallbackPendingOrder: order,
        );
      }
    } catch (e) {
      if (mounted) {
        await _refreshPendingAfterUnfinishedPayment(
          api: auth.api,
          cart: cart,
          userId: auth.user!.userId,
          orderId: order.orderId,
          fallbackPendingOrder: order,
          pendingMessage: friendlyErrorMessage(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() => placing = false);
      }
    }
  }

  Future<void> _refreshPendingAfterUnfinishedPayment({
    required ApiService api,
    required CartProvider cart,
    required int userId,
    required int orderId,
    required Order? fallbackPendingOrder,
    String? pendingMessage,
  }) async {
    Order? pending;
    try {
      pending = await api.getPendingPaymentOrder(userId);
    } catch (_) {
      pending = fallbackPendingOrder;
    }

    if ((pending != null || fallbackPendingOrder != null) &&
        cart.items.isNotEmpty) {
      await cart.clearSynced(userId);
    }

    if (!mounted) return;
    setState(() {
      pendingPaymentOrder = pending;
      error = pending == null
          ? 'Thanh toán cho đơn #$orderId đã bị hủy hoặc hết hạn.'
          : pendingMessage ?? 'Đơn #$orderId vẫn đang chờ thanh toán.';
    });
  }
}
