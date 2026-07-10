import 'package:flutter/material.dart';
import '../services/boost_service.dart';
import '../screens/payments/checkout_webview_page.dart';
import '../screens/payments/whish_webview_page.dart';
import 'profile_widgets/dynamic_gradient_button.dart';

/// Payment modal for buying a boost-day package. Mirrors the plan subscribe
/// modal exactly (same two gateways, same WebViews, same confirm flow) but hits
/// the /boosts payment endpoints and credits the wallet on success.
class BoostPaymentModal {
  /// Shows the pay dialog. Resolves to true when days were credited.
  static Future<bool?> show(
    BuildContext context, {
    required String packageId,
    required String packageName,
    required int days,
    required String priceLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _BoostPaymentDialog(
        packageId: packageId,
        packageName: packageName,
        days: days,
        priceLabel: priceLabel,
      ),
    );
  }
}

class _BoostPaymentDialog extends StatefulWidget {
  final String packageId;
  final String packageName;
  final int days;
  final String priceLabel;

  const _BoostPaymentDialog({
    required this.packageId,
    required this.packageName,
    required this.days,
    required this.priceLabel,
  });

  @override
  State<_BoostPaymentDialog> createState() => _BoostPaymentDialogState();
}

class _BoostPaymentDialogState extends State<_BoostPaymentDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  void _success() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.days} boost day${widget.days == 1 ? '' : 's'} to your wallet!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Pay with a card via CyberSource Unified Checkout.
  Future<void> _payWithCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final checkout = await BoostService.createCheckout(widget.packageId);
      if (checkout['free'] == true) {
        _success();
        return;
      }

      final captureContext = checkout['captureContext'] as String;
      final sessionId = checkout['paymentSessionId'] as String;
      final amount = checkout['amount'] ?? 0;
      final name = (checkout['packageName'] ?? widget.packageName).toString();

      if (!mounted) return;
      final result = await Navigator.of(context).push<CheckoutResult>(
        MaterialPageRoute(
          builder: (_) => CheckoutWebViewPage(
            captureContext: captureContext,
            planName: name,
            amount: amount is num ? amount : num.tryParse('$amount') ?? 0,
          ),
        ),
      );

      if (result == null || result.cancelled) {
        setState(() {
          _errorMessage = 'Payment cancelled.';
          _isLoading = false;
        });
        return;
      }
      if (!result.isSuccess) {
        setState(() {
          _errorMessage = result.error ?? 'Payment could not be completed.';
          _isLoading = false;
        });
        return;
      }

      await BoostService.confirmCheckout(sessionId, result.transientToken!);
      _success();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Pay with Whish (balance, phone + OTP) via the Whish hosted page.
  Future<void> _payWithWhish() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final checkout = await BoostService.createWhishCheckout(widget.packageId);
      if (checkout['free'] == true) {
        _success();
        return;
      }

      final collectUrl = checkout['collectUrl'] as String;
      final sessionId = checkout['paymentSessionId'] as String;
      final amount = checkout['amount'] ?? 0;
      final name = (checkout['packageName'] ?? widget.packageName).toString();

      if (!mounted) return;
      final result = await Navigator.of(context).push<WhishResult>(
        MaterialPageRoute(
          builder: (_) => WhishWebViewPage(
            collectUrl: collectUrl,
            planName: name,
            amount: amount is num ? amount : num.tryParse('$amount') ?? 0,
          ),
        ),
      );

      if (result == null || result.cancelled) {
        setState(() {
          _errorMessage = 'Payment cancelled.';
          _isLoading = false;
        });
        return;
      }

      final confirm = await BoostService.confirmWhish(sessionId);
      if (confirm['pending'] == true) {
        setState(() {
          _errorMessage = 'Payment is still processing. Please check again shortly.';
          _isLoading = false;
        });
        return;
      }
      _success();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Buy Boost Days',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You are about to buy:', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 12),
          Text(
            '${widget.packageName} · ${widget.days} boost day${widget.days == 1 ? '' : 's'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 69, 100, 201),
            ),
          ),
          const SizedBox(height: 8),
          Text('Price: ${widget.priceLabel}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DynamicGradientButton(
              buttonText: _isLoading ? 'Processing...' : 'Pay with Card',
              onTap: _isLoading ? null : _payWithCard,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textSize: 14,
            ),
            const SizedBox(height: 8),
            DynamicGradientButton(
              buttonText: _isLoading ? 'Processing...' : 'Pay with Whish',
              onTap: _isLoading ? null : _payWithWhish,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textSize: 14,
              useGradient: false,
              backgroundColor: const Color(0xFFE5006E),
              textColor: Colors.white,
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
