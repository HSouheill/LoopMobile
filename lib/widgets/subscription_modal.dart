import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../screens/payments/checkout_webview_page.dart';
import 'profile_widgets/dynamic_gradient_button.dart';

/// Modal dialog for subscribing/unsubscribing to plans
class SubscriptionModal {
  /// Show subscribe modal for a specific plan
  static Future<bool?> showSubscribeModal(
    BuildContext context, {
    required String planId,
    required String planName,
    required String planPrice,
    required VoidCallback onSuccess,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _SubscribeDialog(
          planId: planId,
          planName: planName,
          planPrice: planPrice,
          onSuccess: onSuccess,
        );
      },
    );
  }

  /// Show unsubscribe modal for current plan
  static Future<bool?> showUnsubscribeModal(
    BuildContext context, {
    required String planName,
    required VoidCallback onSuccess,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _UnsubscribeDialog(
          planName: planName,
          onSuccess: onSuccess,
        );
      },
    );
  }
}

/// Subscribe dialog widget
class _SubscribeDialog extends StatefulWidget {
  final String planId;
  final String planName;
  final String planPrice;
  final VoidCallback onSuccess;

  const _SubscribeDialog({
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.onSuccess,
  });

  @override
  State<_SubscribeDialog> createState() => _SubscribeDialogState();
}

class _SubscribeDialogState extends State<_SubscribeDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  void _success() {
    widget.onSuccess();
    if (!mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully subscribed to ${widget.planName}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: create the checkout (or get free-plan activation).
      final checkout = await SubscriptionService.createCheckout(widget.planId);

      // Free plan -> already activated by the backend.
      if (checkout['free'] == true) {
        _success();
        return;
      }

      final captureContext = checkout['captureContext'] as String;
      final sessionId = checkout['paymentSessionId'] as String;
      final amount = checkout['amount'] ?? 0;
      final planName = (checkout['planName'] ?? widget.planName).toString();

      if (!mounted) return;

      // Step 2: open the Unified Checkout WebView, get the transient token.
      final result = await Navigator.of(context).push<CheckoutResult>(
        MaterialPageRoute(
          builder: (_) => CheckoutWebViewPage(
            captureContext: captureContext,
            planName: planName,
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
        // The payment UI failed to load/run (e.g. origin not allowed, network).
        setState(() {
          _errorMessage = result.error ?? 'Payment could not be completed.';
          _isLoading = false;
        });
        return;
      }

      // Step 3: confirm + capture on the server, which activates the plan.
      await SubscriptionService.confirmCheckout(sessionId, result.transientToken!);
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Subscribe to Plan',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to subscribe to:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.planName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 69, 100, 201),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Price: ${widget.planPrice}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        DynamicGradientButton(
          buttonText: _isLoading ? 'Processing...' : 'Continue to payment',
          onTap: _isLoading ? null : _handleSubscribe,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textSize: 14,
        ),
      ],
    );
  }
}

/// Unsubscribe dialog widget
class _UnsubscribeDialog extends StatefulWidget {
  final String planName;
  final VoidCallback onSuccess;

  const _UnsubscribeDialog({
    required this.planName,
    required this.onSuccess,
  });

  @override
  State<_UnsubscribeDialog> createState() => _UnsubscribeDialogState();
}

class _UnsubscribeDialogState extends State<_UnsubscribeDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleUnsubscribe() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SubscriptionService.unsubscribe();

      if (result != null) {
        // Success
        widget.onSuccess();
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully unsubscribed from plan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to unsubscribe. Please try again.';
          _isLoading = false;
        });
      }
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Unsubscribe from Plan',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to unsubscribe from:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.planName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 69, 100, 201),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action will cancel your subscription immediately.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        DynamicGradientButton(
          buttonText: _isLoading ? 'Unsubscribing...' : 'Unsubscribe',
          onTap: _isLoading ? null : _handleUnsubscribe,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textSize: 14,
          backgroundColor: Colors.red,
          useGradient: false,
        ),
      ],
    );
  }
}
