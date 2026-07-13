import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mở trang thanh toán PayOS trong WebView và poll trạng thái đơn.
/// Trả về `true` khi đã thanh toán, `false` khi hủy/đóng.
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.api,
    required this.orderId,
    required this.checkoutUrl,
  });

  final ApiService api;
  final int orderId;
  final String checkoutUrl;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  Timer? _poller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.checkoutUrl));
    // Trạng thái thật do server xác nhận với PayOS, không tin vào URL redirect.
    _poller = Timer.periodic(const Duration(seconds: 3), (_) => _check());
  }

  Future<void> _check() async {
    if (_finished) return;
    try {
      final status = await widget.api.getPaymentStatus(widget.orderId);
      if (!mounted) return;
      if (status['isPaid'] == true) {
        _finish(true);
      } else if (status['paymentStatus'] == 'Đã hủy') {
        _finish(false);
      }
    } catch (_) {
      // Bỏ qua lỗi tạm thời, lần poll sau thử lại.
    }
  }

  void _finish(bool paid) {
    if (_finished) return;
    _finished = true;
    _poller?.cancel();
    if (mounted) Navigator.pop(context, paid);
  }

  Future<void> _closeAfterStatusCheck() async {
    await _check();
    if (!_finished) {
      _finish(false);
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_closeAfterStatusCheck());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán PayOS'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => unawaited(_closeAfterStatusCheck()),
          ),
        ),
        body: Column(
          children: [
            const LinearProgressIndicator(minHeight: 2),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
