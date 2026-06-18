import 'dart:async';
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
  // Visual style. true (default) = grey-filled, matching the signup form fields.
  // false = white outlined, matching the District/City/Sort dropdowns on the
  // advanced-filters page.
  final bool filled;

  const CategoryPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Select category',
    this.isRequired = false,
    this.errorText,
    this.allowCustom = true,
    this.onClear,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Outlined variant matches the District/City/Sort dropdowns on the filter
    // page; filled variant matches the grey signup form fields.
    final Color borderColor = errorText != null
        ? Colors.red
        : (filled ? Colors.grey[200]! : Colors.grey.shade400);
    final Color iconColor = filled ? Colors.grey[400]! : Colors.grey.shade600;
    final Color hintColor = filled ? Colors.grey[400]! : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: filled ? Colors.grey[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(filled ? 12 : 4),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            leading: Icon(Icons.category_outlined, color: iconColor),
            title: Text(
              value?.displayLabel ?? hintText,
              style: TextStyle(
                fontSize: 16,
                color: value == null ? hintColor : Colors.black87,
              ),
            ),
            trailing: (value != null && onClear != null)
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                    onPressed: onClear,
                  )
                : Icon(Icons.arrow_drop_down, color: iconColor),
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

  // Debounce typing so we don't fire a request per keystroke, and a request
  // generation counter so a slow earlier response can't overwrite a newer one.
  Timer? _debounce;
  int _requestSeq = 0;
  static const Duration _debounceDelay = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    final seq = ++_requestSeq;
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
      // Drop the response if a newer request (or a load-more) has started.
      if (seq != _requestSeq || !mounted) return;
      setState(() {
        _items.addAll(result.categories);
        _hasMore = _page < result.pages;
        _loading = false;
      });
    } catch (e) {
      if (seq != _requestSeq || !mounted) return;
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
    final next = q.trim();
    // Debounce: only fire after the user pauses typing, and skip if the query
    // didn't actually change.
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () {
      if (next == _query) return;
      _query = next;
      _load(reset: true);
    });
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
