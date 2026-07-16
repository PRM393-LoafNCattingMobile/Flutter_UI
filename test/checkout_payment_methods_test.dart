import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/checkout/screens/checkout_screen.dart';

void main() {
  test('checkout only exposes supported payment methods', () {
    expect(
      supportedCheckoutPaymentMethods,
      containsAll([
        AppStrings.cashPaymentMethod,
        AppStrings.bankTransferPaymentMethod,
      ]),
    );
    expect(
      supportedCheckoutPaymentMethods,
      isNot(contains(AppStrings.creditCardPaymentMethod)),
    );
    expect(
      supportedCheckoutPaymentMethods,
      isNot(contains(AppStrings.eWalletPaymentMethod)),
    );
  });
}
