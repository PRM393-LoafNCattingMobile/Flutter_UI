import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
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
  String paymentMethod = 'Tiền mặt';
  bool placing = false;
  String? error;
  bool didSeedUser = false;

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
    }
    didSeedUser = true;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
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
                      const EmptyView('Giỏ hàng trống, chưa thể thanh toán.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Quay lại giỏ hàng'),
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
                      const ErrorView('Bạn cần đăng nhập trước khi đặt đơn.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (_) => false),
                        child: const Text('Đi tới đăng nhập'),
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
                    title: 'Sắp xong rồi',
                    subtitle: 'Xác nhận thông tin trước khi gửi đơn cho quán.',
                    icon: Icons.receipt_long,
                  ),
                  CafeCard(
                    child: Column(
                      children: [
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(item.product.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall)),
                                Text('x${item.quantity}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: loafMuted)),
                                const SizedBox(width: 12),
                                Text(money(item.subtotal),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: loafOrange)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Text('Tổng cộng',
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text(money(cart.total),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: loafOrange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  CafeCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CafeTextFormField(
                          controller: nameController,
                          labelText: 'Receiver name',
                          prefixIcon: const Icon(Icons.person_outline),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) => CafeValidators.name(
                            value,
                            fieldName: 'receiver name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        CafeTextFormField(
                          controller: phoneController,
                          labelText: 'Phone number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          validator: CafeValidators.phone,
                        ),
                        const SizedBox(height: 12),
                        CafeTextFormField(
                          controller: noteController,
                          labelText: 'Order note',
                          hintText: 'Ghi chú cho đơn hàng',
                          prefixIcon: const Icon(Icons.edit_note),
                          textInputAction: TextInputAction.newline,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: paymentMethod,
                          decoration: const InputDecoration(
                              labelText: 'Phương thức thanh toán',
                              prefixIcon: Icon(Icons.payments_outlined)),
                          items: const [
                            'Tiền mặt',
                            'Thẻ tín dụng',
                            'Ví điện tử',
                            'Chuyển khoản ngân hàng',
                          ]
                              .map((item) =>
                                  DropdownMenuItem(value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => paymentMethod = value);
                            }
                          },
                        ),
                      ],
                    ),
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
                    onPressed: placing ? null : () => _submitOrder(auth, cart),
                    icon: placing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Đặt đơn'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitOrder(AuthProvider auth, CartProvider cart) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    if (auth.user == null || cart.items.isEmpty) return;

    setState(() {
      placing = true;
      error = null;
    });

    try {
      await auth.api.createOrder({
        'userId': auth.user!.userId,
        'tableId': null,
        'reservationId': null,
        'orderType': 'Mang đi',
        'note': noteController.text.trim(),
        'paymentMethod': paymentMethod,
        'items': cart.items
            .map((item) => {
                  'productId': item.product.productId,
                  'quantity': item.quantity
                })
            .toList(),
      });
      cart.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Đặt đơn thành công'),
          content: Text(
            'Đơn của ${nameController.text.trim()} đã được gửi tới quán.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) {
        setState(() => placing = false);
      }
    }
  }
}
