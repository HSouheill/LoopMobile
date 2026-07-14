import 'package:flutter/material.dart';
import '../services/refresh_service.dart';

/// Confirm sheet for spending 1 refresh on a listing.
///
/// A refresh resets the listing's date to now, pushing it back to the top of the
/// newest-first queue. It costs exactly 1 refresh and can be reused on the same
/// listing as often as the user has refreshes. Returns the spend response on
/// success (or null if cancelled) via [show].
class RefreshListingSheet extends StatefulWidget {
  final String listingId;
  final String listingLabel;

  const RefreshListingSheet({
    super.key,
    required this.listingId,
    required this.listingLabel,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String listingId,
    required String listingLabel,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RefreshListingSheet(
        listingId: listingId,
        listingLabel: listingLabel,
      ),
    );
  }

  @override
  State<RefreshListingSheet> createState() => _RefreshListingSheetState();
}

class _RefreshListingSheetState extends State<RefreshListingSheet> {
  static const _primary = Color(0xFF0048FF);

  int _balance = 0;
  bool _loadingBalance = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final wallet = await RefreshService.getWallet();
    if (!mounted) return;
    setState(() {
      _balance = (wallet?['balance'] as num?)?.toInt() ?? 0;
      _loadingBalance = false;
    });
  }

  bool get _canAfford => _balance >= 1;

  Future<void> _submit() async {
    if (!_canAfford || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await RefreshService.spend(widget.listingId);
      if (!mounted) return;
      Navigator.of(context).pop(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing moved to the top of the queue.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: const [
              Icon(Icons.refresh, color: _primary),
              SizedBox(width: 8),
              Text(
                'Refresh listing',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This moves ${widget.listingLabel} back to the top of the queue by '
            'updating its date to now. It costs 1 refresh, and you can refresh '
            'the same listing again whenever you like.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.35),
          ),
          const SizedBox(height: 16),

          // Wallet balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: _primary),
                const SizedBox(width: 8),
                _loadingBalance
                    ? const Text('Loading balance…')
                    : Text(
                        '$_balance refresh${_balance == 1 ? '' : 'es'} available',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ],
            ),
          ),

          if (!_loadingBalance && !_canAfford) ...[
            const SizedBox(height: 8),
            Text(
              'You have no refreshes left. Buy more from your dashboard.',
              style: TextStyle(fontSize: 12, color: Colors.red[600]),
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_canAfford && !_submitting && !_loadingBalance)
                  ? _submit
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Use 1 refresh',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
