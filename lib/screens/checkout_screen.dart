import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/payment_webview_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

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
            if (cart.items.isEmpty) {
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
                  _CheckoutSummaryCard(cart: cart),
                  if (loadingPendingPayment) ...[
                    const SizedBox(height: 14),
                    const CafeCard(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else if (pendingPaymentOrder != null) ...[
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
                  ],
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
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: placing || pendingPaymentOrder != null
                        ? null
                        : () => _submitOrder(auth, cart),
                    icon: placing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text(AppStrings.placeOrderButton),
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
    try {
      final pending = await api.getPendingPaymentOrder(userId);
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
          setState(() {
            pendingPaymentOrder = Order.fromJson(order);
            error =
                'Chưa hoàn tất thanh toán. Đơn đang chờ thanh toán, bạn có thể thanh toán tiếp bên trên.';
          });
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
      Navigator.pop(context);
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
        title: const Text('Bạn còn đơn chờ thanh toán'),
        content: Text(
          'Đơn #${pending.orderId} đang chờ thanh toán. '
          'Vui lòng thanh toán hoặc nhờ staff hủy đơn này trước khi tạo đơn mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Thanh toán tiếp'),
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
            content: Text('Đơn #${order.orderId} đã được thanh toán.'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(AppStrings.okButton),
              ),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        setState(() {
          error = 'Đơn #${order.orderId} vẫn đang chờ thanh toán.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = friendlyErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => placing = false);
      }
    }
  }
}

class _CheckoutSummaryCard extends StatelessWidget {
  const _CheckoutSummaryCard({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      child: Column(
        children: [
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: loafMuted),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    money(item.subtotal),
                    style: moneyTextStyle(
                      Theme.of(context).textTheme.titleSmall,
                      color: loafOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            children: [
              Text(
                AppStrings.totalLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
        ],
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  const _PendingPaymentCard({
    required this.order,
    required this.onResume,
    required this.onRefresh,
  });

  final Order order;
  final VoidCallback? onResume;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CafeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CafeIconBadge(icon: Icons.pending_actions_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đơn #${order.orderId} đang chờ thanh toán',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn cần hoàn tất đơn này trước khi tạo đơn mới.',
            style: theme.textTheme.bodySmall?.copyWith(color: loafMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CafeInfoChip(label: order.paymentStatus),
              CafeInfoChip(label: money(order.totalPrice)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.payment_outlined),
                label: const Text('Thanh toán tiếp'),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Kiểm tra lại'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutFormCard extends StatelessWidget {
  const _CheckoutFormCard({
    required this.nameController,
    required this.phoneController,
    required this.noteController,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final String paymentMethod;
  final ValueChanged<String?> onPaymentMethodChanged;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CafeTextFormField(
            controller: nameController,
            labelText: AppStrings.receiverNameLabel,
            prefixIcon: const Icon(Icons.person_outline),
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: (value) => CafeValidators.name(
              value,
              fieldName: AppStrings.receiverNameFieldName,
            ),
          ),
          const SizedBox(height: 12),
          CafeTextFormField(
            controller: phoneController,
            labelText: AppStrings.phoneNumberLabel,
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: CafeValidators.phone,
          ),
          const SizedBox(height: 12),
          CafeTextFormField(
            controller: noteController,
            labelText: AppStrings.orderNoteLabel,
            hintText: AppStrings.orderNoteHint,
            prefixIcon: const Icon(Icons.edit_note),
            textInputAction: TextInputAction.newline,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: paymentMethod,
            decoration: const InputDecoration(
              labelText: AppStrings.paymentMethodLabel,
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: const [
              AppStrings.cashPaymentMethod,
              AppStrings.creditCardPaymentMethod,
              AppStrings.eWalletPaymentMethod,
              AppStrings.bankTransferPaymentMethod,
            ]
                .map(
                  (item) => DropdownMenuItem(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: onPaymentMethodChanged,
          ),
        ],
      ),
    );
  }
}
