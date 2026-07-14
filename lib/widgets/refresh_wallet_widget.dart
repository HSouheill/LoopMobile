import 'package:flutter/material.dart';
import '../services/refresh_service.dart';

/// Compact dashboard section for the refresh wallet.
///
/// A "refresh" bumps one of the user's listings back to the top of the queue by
/// resetting its date to now. Users buy refreshes in packages (configured in the
/// admin dashboard) and spend them from the Refresh button on any of their
/// listings — one refresh per bump, reusable on the same listing as often as
/// they like.
///
/// Deliberately small: it renders as a single collapsed row (title + balance)
/// and only expands to show the paginated package list when tapped.
class RefreshWalletWidget extends StatefulWidget {
  const RefreshWalletWidget({super.key});

  @override
  State<RefreshWalletWidget> createState() => _RefreshWalletWidgetState();
}

class _RefreshWalletWidgetState extends State<RefreshWalletWidget> {
  static const _primary = Color(0xFF0048FF);
  static const _pageSize = 3;

  int _balance = 0;
  List<dynamic> _packages = [];
  bool _loading = true;
  bool _expanded = false;
  String? _buyingId;

  // Server-side pagination over the packages list.
  int _page = 1;
  int _pages = 1;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final wallet = await RefreshService.getWallet();
    if (!mounted) return;
    setState(() {
      _balance = (wallet?['balance'] as num?)?.toInt() ?? 0;
      _loading = false;
    });
  }

  Future<void> _loadPackages({int page = 1}) async {
    setState(() => _loading = true);
    final res = await RefreshService.getPackages(page: page, limit: _pageSize);
    if (!mounted) return;
    setState(() {
      _packages = (res?['packages'] as List<dynamic>?) ?? [];
      final p = res?['pagination'] as Map<String, dynamic>?;
      _page = (p?['page'] as num?)?.toInt() ?? 1;
      _pages = (p?['pages'] as num?)?.toInt() ?? 1;
      _loading = false;
    });
  }

  Future<void> _toggle() async {
    final next = !_expanded;
    setState(() => _expanded = next);
    if (next && _packages.isEmpty) {
      await _loadPackages(page: 1);
    }
  }

  Future<void> _buy(Map<String, dynamic> pkg) async {
    final id = pkg['_id']?.toString();
    if (id == null || _buyingId != null) return;

    setState(() => _buyingId = id);
    try {
      // v1: credits the wallet immediately, no payment.
      final res = await RefreshService.purchase(id);
      if (!mounted) return;
      setState(() {
        _balance = (res['balance'] as num?)?.toInt() ?? _balance;
        _buyingId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Refreshes added'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _buyingId = null);
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsed row: icon + title + balance + chevron.
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.refresh, color: _primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Refreshes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_balance left',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const SizedBox(height: 6),
            Text(
              'A refresh bumps one of your listings back to the top of the '
              'queue. Buy a pack, then tap “Refresh” on any of your listings — '
              'reuse it on the same listing as often as you like.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.35),
            ),
            const SizedBox(height: 10),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_packages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No refresh packages available right now.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              )
            else
              ..._packages.map(_packageTile),

            // Pager — only when there's more than one page.
            if (!_loading && _pages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _page > 1 ? () => _loadPackages(page: _page - 1) : null,
                    icon: const Icon(Icons.chevron_left, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    '$_page / $_pages',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  IconButton(
                    onPressed: _page < _pages ? () => _loadPackages(page: _page + 1) : null,
                    icon: const Icon(Icons.chevron_right, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _packageTile(dynamic raw) {
    final pkg = raw as Map<String, dynamic>;
    final id = pkg['_id']?.toString();
    final name = pkg['name']?.toString() ?? 'Package';
    final count = (pkg['refreshes'] as num?)?.toInt() ?? 0;
    final price = pkg['price'];
    final currency = pkg['currency']?.toString() ?? 'USD';
    final busy = _buyingId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  '$count refresh${count == 1 ? '' : 'es'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$currency $price',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.green,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: (_buyingId == null) ? () => _buy(pkg) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Buy',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
