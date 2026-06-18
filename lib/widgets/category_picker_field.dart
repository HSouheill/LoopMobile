import 'package:flutter/material.dart';
import '../services/category_service.dart';

/// The outcome of picking a category: either an existing catalog slug, or a
/// custom ("Other") free-text value. [displayLabel] is what we show in the UI.
class CategorySelection {
  final String? categoryKey; // slug of an existing/base category
  final String? customCategory; // free-text when "Other" is chosen
  final String displayLabel;

  const CategorySelection({
    this.categoryKey,
    this.customCategory,
    required this.displayLabel,
  });

  bool get isCustom => customCategory != null;
}

/// A tap-to-open form field that lets a service provider choose a category.
/// Opens [CategorySelectionPage] (searchable + paginated + "Other").
class CategoryPickerField extends StatelessWidget {
  final CategorySelection? value;
  final ValueChanged<CategorySelection> onChanged;
  final String hintText;
  final bool isRequired;
  // Optional validation hook: signup forms wrap this field with a Form, so we
  // surface an error line when required and empty after a submit attempt.
  final String? errorText;
  // Filter use-cases set this false to hide the "Other" custom path (you can't
  // filter the catalog by a not-yet-existing custom category).
  final bool allowCustom;
  // When true, shows a "clear" affordance — used by the filter page where the
  // category is optional.
  final VoidCallback? onClear;

  const CategoryPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Select category',
    this.isRequired = false,
    this.errorText,
    this.allowCustom = true,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[200]!,
            ),
          ),
          child: ListTile(
            leading: Icon(Icons.category_outlined, color: Colors.grey[400]),
            title: Text(
              value?.displayLabel ?? hintText,
              style: TextStyle(
                fontSize: 16,
                color: value == null ? Colors.grey[400] : Colors.black87,
              ),
            ),
            trailing: (value != null && onClear != null)
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                    onPressed: onClear,
                  )
                : Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
            onTap: () async {
              final result = await Navigator.push<CategorySelection>(
                context,
                MaterialPageRoute(
                  builder: (_) => CategorySelectionPage(
                    initial: value,
                    allowCustom: allowCustom,
                  ),
                ),
              );
              if (result != null) onChanged(result);
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Full-screen searchable, paginated category picker. Returns a
/// [CategorySelection] via Navigator.pop, or null if dismissed.
class CategorySelectionPage extends StatefulWidget {
  final CategorySelection? initial;
  final bool allowCustom;
  const CategorySelectionPage({
    super.key,
    this.initial,
    this.allowCustom = true,
  });

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<CategoryOption> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_loadingMore && _hasMore && !_loading) _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 1;
        _items.clear();
        _hasMore = true;
      }
    });
    try {
      final result = await CategoryService.fetchServiceCategories(
        query: _query,
        page: _page,
        limit: 20,
      );
      setState(() {
        _items.addAll(result.categories);
        _hasMore = _page < result.pages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      _page += 1;
      final result = await CategoryService.fetchServiceCategories(
        query: _query,
        page: _page,
        limit: 20,
      );
      setState(() {
        _items.addAll(result.categories);
        _hasMore = _page < result.pages;
        _loadingMore = false;
      });
    } catch (_) {
      setState(() {
        _page -= 1;
        _loadingMore = false;
      });
    }
  }

  void _onSearchChanged(String q) {
    _query = q.trim();
    // Simple debounce via microtask-free reset; reload from page 1.
    _load(reset: true);
  }

  void _pickOption(CategoryOption opt) {
    Navigator.pop(
      context,
      CategorySelection(categoryKey: opt.slug, displayLabel: opt.displayLabel),
    );
  }

  Future<void> _pickCustom() async {
    final controller = TextEditingController(
      text: widget.initial?.isCustom == true
          ? widget.initial!.customCategory
          : '',
    );
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Other category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Type your category',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (text != null && text.isNotEmpty && mounted) {
      Navigator.pop(
        context,
        CategorySelection(customCategory: text, displayLabel: text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildList()),
          // "Other" entry pinned at the bottom so it's always reachable.
          // Hidden in filter mode where custom categories aren't selectable.
          if (widget.allowCustom)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: _pickCustom,
                  icon: const Icon(Icons.add),
                  label: const Text('Other (add custom category)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _load(reset: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No categories found'));
    }

    return ListView.separated(
      controller: _scrollCtrl,
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final opt = _items[index];
        final selected = widget.initial?.categoryKey == opt.slug;
        return ListTile(
          title: Text(opt.displayLabel),
          trailing: selected
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () => _pickOption(opt),
        );
      },
    );
  }
}
