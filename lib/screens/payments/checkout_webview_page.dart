import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../environment.dart';

/// Result of the checkout WebView.
class CheckoutResult {
  final String? transientToken; // non-null on success
  final bool cancelled; // true when the user closed/cancelled
  final String? error; // non-null when payment init/UI failed

  const CheckoutResult.success(this.transientToken)
      : cancelled = false,
        error = null;
  const CheckoutResult.cancelled()
      : transientToken = null,
        cancelled = true,
        error = null;
  const CheckoutResult.failed(this.error)
      : transientToken = null,
        cancelled = false;

  bool get isSuccess => transientToken != null;
}

/// Hosts the CyberSource Unified Checkout page in a WebView. The backend serves
/// /pay/checkout.html which renders the card UI and posts the transient token
/// back via the "PaymentChannel" JS channel.
///
/// Pops with a [CheckoutResult]: success(token), cancelled(), or failed(message).
class CheckoutWebViewPage extends StatefulWidget {
  final String captureContext;
  final String planName;
  final num amount;

  const CheckoutWebViewPage({
    super.key,
    required this.captureContext,
    required this.planName,
    required this.amount,
  });

  @override
  State<CheckoutWebViewPage> createState() => _CheckoutWebViewPageState();
}

class _CheckoutWebViewPageState extends State<CheckoutWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false; // guard against double-pop

  // The checkout page is served under /api so it rides the existing nginx
  // proxy rule (apiUrl already ends with ".../api/").
  String get _checkoutUrl {
    final cc = Uri.encodeComponent(widget.captureContext);
    return '${Environment.apiUrl}pay/checkout.html#cc=$cc';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: _onChannelMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_checkoutUrl));
  }

  void _onChannelMessage(JavaScriptMessage message) {
    if (_done) return;
    Map<String, dynamic> data;
    try {
      data = json.decode(message.message) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = data['type'];
    if (type == 'token' && data['transientToken'] != null) {
      _done = true;
      Navigator.of(context).pop(CheckoutResult.success(data['transientToken'] as String));
    } else if (type == 'cancelled') {
      _done = true;
      Navigator.of(context).pop(const CheckoutResult.cancelled());
    } else if (type == 'error') {
      _done = true;
      Navigator.of(context).pop(
        CheckoutResult.failed(data['message']?.toString() ?? 'Payment failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _done) return;
        _done = true;
        Navigator.of(context).pop(const CheckoutResult.cancelled());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pay \$${widget.amount} — ${widget.planName}'),
          backgroundColor: const Color(0xFF0048FF),
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
