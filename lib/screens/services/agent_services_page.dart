import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/my_service.dart';
import '../../services/service_service.dart';

class AgentServicesPage extends StatefulWidget {
  final String agentId;
  final String? agentName;

  const AgentServicesPage({super.key, required this.agentId, this.agentName});

  @override
  State<AgentServicesPage> createState() => _AgentServicesPageState();
}

class _AgentServicesPageState extends State<AgentServicesPage> {
  int _page = 1;
  final int _limit = 20;
  bool _isLoading = false;
  String? _error;
  List<MyService> _services = [];
  MyServicesMeta? _meta;

  @override
  void initState() {
    super.initState();
    _fetchServices(page: _page);
  }

  Future<void> _fetchServices({required int page}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await ServiceService.getServicesByAgentId(
        agentId: widget.agentId,
        page: page,
        limit: _limit,
        sort: 'date_desc',
      );
      if (!mounted) return;
      setState(() {
        _services = resp.services;
        _meta = resp.meta;
        _page = resp.meta.page;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchServices(page: 1);
  }

  void _goToPage(int newPage) {
    if (newPage < 1) return;
    if (_meta != null && newPage > _meta!.pages) return;
    _fetchServices(page: newPage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.agentName != null && widget.agentName!.isNotEmpty
        ? (l10n?.agentServicesTitle(widget.agentName!) ?? "${widget.agentName}'s Services")
        : (l10n?.services ?? 'Services');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '${l10n?.failedToLoadServices ?? 'Failed to load services'}: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: _isLoading && _services.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _services.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Center(child: Text(l10n?.noServicesFound ?? 'No services found')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final s = _services[index];
                            return _ServiceListTile(service: s);
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemCount: _services.length,
                        ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: (_meta == null || _page <= 1) ? null : () => _goToPage(_page - 1),
                    child: Text(l10n?.previous ?? 'Previous'),
                  ),
                  Text('${l10n?.page ?? 'Page'} ${_meta?.page ?? _page} ${l10n?.ofText ?? 'of'} ${_meta?.pages ?? '?'}'),
                  ElevatedButton(
                    onPressed: (_meta == null || (_meta!.pages != 0 && _page >= _meta!.pages))
                        ? null
                        : () => _goToPage(_page + 1),
                    child: Text(l10n?.next ?? 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final MyService service;
  const _ServiceListTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              service.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: Colors.grey[300],
                child: const Icon(Icons.work, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  service.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      service.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


