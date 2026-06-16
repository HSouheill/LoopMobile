import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Result of the Whish WebView.
class WhishResult {
  final bool success; // Whish redirected to the success URL
  final bool cancelled; // user closed before finishing

  const WhishResult.success() : success = true, cancelled = false;
  const WhishResult.failure() : success = false, cancelled = false;
  const WhishResult.cancelled() : success = false, cancelled = true;
}

/// Loads the Whish hosted payment page (collectUrl) in a WebView and detects
/// completion by watching for the redirect URL Whish sends us
/// (.../subscriptions/whish/redirect?...&result=success|failure).
///
/// Pops with a [WhishResult]. The backend remains the source of truth — the
/// caller still calls confirmWhish() to verify via Whish "Get Status".
class WhishWebViewPage extends StatefulWidget {
  final String collectUrl;
  final String planName;
  final num amount;

  const WhishWebViewPage({
    super.key,
    required this.collectUrl,
    required this.planName,
    required this.amount,
  });

  @override
  State<WhishWebViewPage> createState() => _WhishWebViewPageState();
}

class _WhishWebViewPageState extends State<WhishWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (nav) {
            final r = _resultForUrl(nav.url);
            if (r != null) {
              _finish(r);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _loading = false);
            // Some flows land on the redirect via a full load rather than a nav request.
            final r = _resultForUrl(url);
            if (r != null) _finish(r);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.collectUrl));
  }

  // Detect our redirect landing URL and its result flag.
  WhishResult? _resultForUrl(String url) {
    if (!url.contains('/subscriptions/whish/redirect')) return null;
    final uri = Uri.tryParse(url);
    final result = uri?.queryParameters['result'];
    return result == 'success'
        ? const WhishResult.success()
        : const WhishResult.failure();
  }

  void _finish(WhishResult r) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(r);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _done) return;
        _done = true;
        Navigator.of(context).pop(const WhishResult.cancelled());
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
