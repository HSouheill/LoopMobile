import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import 'category_picker_field.dart';

/// A dashboard tile that shows the service provider's current category and lets
/// them change it. Used by the SP individual/company dashboards so existing
/// (category-less) providers can set one.
class EditCategoryTile extends StatefulWidget {
  /// Called after a successful update with the new display label, so the parent
  /// can refresh any cached user it holds.
  final ValueChanged<String>? onUpdated;

  const EditCategoryTile({super.key, this.onUpdated});

  @override
  State<EditCategoryTile> createState() => _EditCategoryTileState();
}

class _EditCategoryTileState extends State<EditCategoryTile> {
  bool _saving = false;

  Future<void> _editCategory() async {
    final user = AuthService.currentUser;
    final initial = (user?.categoryKey != null && user!.categoryKey!.isNotEmpty)
        ? CategorySelection(
            categoryKey: user.categoryKey,
            displayLabel: user.category ?? user.categoryKey!,
          )
        : null;

    final selection = await Navigator.push<CategorySelection>(
      context,
      MaterialPageRoute(
        builder: (_) => CategorySelectionPage(initial: initial),
      ),
    );
    if (selection == null || !mounted) return;

    setState(() => _saving = true);
    final result = await CategoryService.updateMyCategory(
      categoryKey: selection.categoryKey,
      customCategory: selection.customCategory,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final updatedUser = data?['user'] as Map<String, dynamic>?;
      final newLabel = updatedUser?['category']?.toString() ??
          selection.displayLabel;
      final newKey = updatedUser?['categoryKey']?.toString() ??
          selection.categoryKey;

      // Keep the cached current user in sync so the dashboard reflects it.
      final current = AuthService.currentUser;
      if (current != null) {
        await AuthService.updateCurrentUser(
          current.copyWith(category: newLabel, categoryKey: newKey),
        );
      }
      widget.onUpdated?.call(newLabel);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Category updated to "$newLabel"'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result['error']?.toString() ?? 'Failed to update category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = AuthService.currentUser?.category;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.category_outlined, color: Colors.blue),
        title: const Text('Category'),
        subtitle: Text(
          (category != null && category.isNotEmpty)
              ? category
              : 'No category set',
        ),
        trailing: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.edit, size: 20),
        onTap: _saving ? null : _editCategory,
      ),
    );
  }
}
