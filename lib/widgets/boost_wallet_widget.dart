import 'package:flutter/material.dart';
import '../services/boost_service.dart';

/// Dashboard section for the boost-days wallet: explains what boost days are,
/// shows the current balance, and lists purchasable packages (configured from
/// the admin dashboard). v1 purchases credit the wallet instantly (no payment).
class BoostWalletWidget extends StatefulWidget {
  const BoostWalletWidget({super.key});

  @override
  State<BoostWalletWidget> createState() => _BoostWalletWidgetState();
}

class _BoostWalletWidgetState extends State<BoostWalletWidget> {
  static const _primary = Color(0xFF0048FF);

  int _balance = 0;
  List<dynamic> _packages = [];
  bool _loading = true;
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      BoostService.getWallet(),
      BoostService.getPackages(),
    ]);
    if (!mounted) return;
    final wallet = results[0] as Map<String, dynamic>?;
    final packages = results[1] as List<dynamic>?;
    setState(() {
      _balance = (wallet?['balanceDays'] as num?)?.toInt() ?? 0;
      _packages = packages ?? [];
      _loading = false;
    });
  }

  Future<void> _buy(Map<String, dynamic> pkg) async {
    final id = pkg['_id']?.toString();
    if (id == null || _purchasingId != null) return;
    setState(() => _purchasingId = id);
    try {
      final res = await BoostService.purchase(id);
      if (!mounted) return;
      setState(() {
        _balance = (res['balanceDays'] as num?)?.toInt() ?? _balance;
        _purchasingId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Boost days added.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchasingId = null);
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
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + balance chip
          Row(
            children: [
              const Icon(Icons.bolt, color: _primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Boost Days Wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_balance day${_balance == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Explainer
          Text(
            'Boost days let you feature your profile, listings or jobs so they '
            'appear first. Buy a package below, then tap “Boost” on any of your '
            'items and choose how many days (1–30) to spend.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_packages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No boost packages available right now.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ..._packages.map(_packageTile),
        ],
      ),
    );
  }

  Widget _packageTile(dynamic raw) {
    final pkg = raw as Map<String, dynamic>;
    final id = pkg['_id']?.toString();
    final name = pkg['name']?.toString() ?? 'Package';
    final days = (pkg['days'] as num?)?.toInt() ?? 0;
    final price = pkg['price'];
    final currency = pkg['currency']?.toString() ?? 'USD';
    final description = pkg['description']?.toString() ?? '';
    final isBuying = _purchasingId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '$days boost day${days == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currency $price',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: (_purchasingId == null) ? () => _buy(pkg) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isBuying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Buy',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
