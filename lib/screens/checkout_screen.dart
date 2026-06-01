import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final noteController = TextEditingController();
  String paymentMethod = 'Tiền mặt';
  bool placing = false;
  String? error;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const CafeHeroHeader(
              title: 'Sắp xong rồi',
              subtitle: 'Xác nhận thanh toán và gửi đơn cho quán.',
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
                                  style:
                                      Theme.of(context).textTheme.titleSmall)),
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
            TextField(
                controller: noteController,
                decoration: const InputDecoration(
                    labelText: 'Order note',
                    hintText: 'Ghi chú cho đơn hàng',
                    prefixIcon: Icon(Icons.edit_note))),
            const SizedBox(height: 12),
            DropdownButtonFormField(
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
              onChanged: (value) => setState(() => paymentMethod = value!),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: placing
                  ? null
                  : () async {
                      setState(() {
                        placing = true;
                        error = null;
                      });
                      try {
                        await context.read<AuthProvider>().api.createOrder({
                          'userId': auth.user!.userId,
                          'tableId': null,
                          'reservationId': null,
                          'orderType': 'Mang đi',
                          'note': noteController.text,
                          'paymentMethod': paymentMethod,
                          'items': cart.items
                              .map((item) => {
                                    'productId': item.product.productId,
                                    'quantity': item.quantity
                                  })
                              .toList(),
                        });
                        cart.clear();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã đặt đơn')));
                      } catch (e) {
                        setState(() => error = e.toString());
                      } finally {
                        if (mounted) setState(() => placing = false);
                      }
                    },
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
      ),
    );
  }
}
