part of '../screens/checkout_screen.dart';

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
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: loafMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      money(item.subtotal),
                      style: moneyTextStyle(
                        theme.textTheme.titleSmall,
                        color: loafOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.payment_outlined),
                label: const Text(AppStrings.continuePaymentButton),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.reviewAgainButton),
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
