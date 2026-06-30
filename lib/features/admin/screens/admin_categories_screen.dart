import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

/// Quản lý danh mục (Admin-only). Dùng chung `AdminCatalogProvider`.
class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  Future<void> _openForm(BuildContext context, {Category? category}) async {
    final provider = context.read<AdminCatalogProvider>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CategoryFormDialog(category: category),
    );
    if (result == null) return;
    final ok =
        await provider.saveCategory(result, id: category?.categoryId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminSavedMessage
          : (provider.error ?? AppStrings.adminSavedMessage)),
    ));
  }

  Future<void> _delete(BuildContext context, Category category) async {
    final provider = context.read<AdminCatalogProvider>();
    final confirmed = await _confirmDelete(context);
    if (confirmed != true) return;
    final ok = await provider.deleteCategory(category.categoryId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminDeletedMessage
          : (provider.error ?? AppStrings.adminDeletedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCatalogProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminManageCategoriesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: CafeSurface(
        child: provider.categories.isEmpty
            ? const EmptyView(AppStrings.adminCategoriesEmptyMessage)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: provider.categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final category = provider.categories[index];
                  return CafeCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              if ((category.description ?? '').isNotEmpty)
                                Text(category.description!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _openForm(context, category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(context, category),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.adminDeleteConfirmTitle),
        content: const Text(AppStrings.adminDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.adminCancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.adminDeleteButton),
          ),
        ],
      ),
    );

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});
  final Category? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? AppStrings.adminAddCategoryTitle
          : AppStrings.adminEditCategoryTitle),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CafeTextFormField(
              controller: nameController,
              labelText: AppStrings.categoryNameLabel,
              validator: (value) => CafeValidators.requiredField(
                  value, AppStrings.categoryNameLabel),
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: descriptionController,
              labelText: AppStrings.categoryDescriptionLabel,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.adminCancelButton),
        ),
        FilledButton(
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, {
              'name': nameController.text.trim(),
              'description': descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
            });
          },
          child: const Text(AppStrings.adminSaveButton),
        ),
      ],
    );
  }
}
