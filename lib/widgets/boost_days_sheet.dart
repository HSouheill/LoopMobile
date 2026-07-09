import 'package:flutter/material.dart';
import '../services/boost_service.dart';

/// Bottom sheet to spend boost days on a target (profile / listing / job).
/// Shows the current wallet balance and a 1–30 day picker, then calls the spend
/// API. Returns the spend response map (or null if cancelled) via [show].
class BoostDaysSheet extends StatefulWidget {
  final String targetType; // 'user' | 'listing' | 'job'
  final String targetId;
  final String targetLabel; // e.g. the listing title / "your profile"

  const BoostDaysSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetLabel,
  });

  /// Opens the sheet. Resolves to the spend response on success, else null.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String targetType,
    required String targetId,
    required String targetLabel,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BoostDaysSheet(
        targetType: targetType,
        targetId: targetId,
        targetLabel: targetLabel,
      ),
    );
  }

  @override
  State<BoostDaysSheet> createState() => _BoostDaysSheetState();
}

class _BoostDaysSheetState extends State<BoostDaysSheet> {
  static const _primary = Color(0xFF0048FF);
  int _days = 1;
  int _balance = 0;
  bool _loadingBalance = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final wallet = await BoostService.getWallet();
    if (!mounted) return;
    setState(() {
      _balance = (wallet?['balanceDays'] as num?)?.toInt() ?? 0;
      _loadingBalance = false;
    });
  }

  bool get _canAfford => _days <= _balance;

  Future<void> _submit() async {
    if (!_canAfford || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await BoostService.spend(
        targetType: widget.targetType,
        targetId: widget.targetId,
        days: _days,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Boosted for $_days day${_days == 1 ? '' : 's'}.')),
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
            children: [
              const Icon(Icons.bolt, color: _primary),
              const SizedBox(width: 8),
              const Text(
                'Boost',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Feature ${widget.targetLabel} for the days you choose.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                        '$_balance boost day${_balance == 1 ? '' : 's'} available',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Day picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Days', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '$_days / 30',
                style: const TextStyle(fontWeight: FontWeight.w700, color: _primary),
              ),
            ],
          ),
          Row(
            children: [
              _stepButton(Icons.remove, () {
                if (_days > 1) setState(() => _days--);
              }),
              Expanded(
                child: Slider(
                  value: _days.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: _primary,
                  label: '$_days',
                  onChanged: (v) => setState(() => _days = v.round()),
                ),
              ),
              _stepButton(Icons.add, () {
                if (_days < 30) setState(() => _days++);
              }),
            ],
          ),

          if (!_loadingBalance && !_canAfford) ...[
            const SizedBox(height: 4),
            Text(
              'Not enough boost days. Buy more from your dashboard wallet.',
              style: TextStyle(fontSize: 12, color: Colors.red[600]),
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_canAfford && !_submitting) ? _submit : null,
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
                  : Text(
                      'Boost for $_days day${_days == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: _primary),
      ),
    );
  }
}
