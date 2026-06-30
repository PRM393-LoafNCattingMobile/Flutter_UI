import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

/// Form tạo/sửa sản phẩm (Admin). `product == null` nghĩa là tạo mới.
class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({
    super.key,
    this.product,
    required this.categories,
  });

  final Product? product;
  final List<LookupItem> categories;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController discountController;
  late final TextEditingController stockController;
  late final TextEditingController pictureController;
  int? categoryId;
  bool isAvailable = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    nameController = TextEditingController(text: product?.name ?? '');
    descriptionController =
        TextEditingController(text: product?.description ?? '');
    priceController =
        TextEditingController(text: product == null ? '' : _trim(product.price));
    discountController = TextEditingController(
        text: product?.discountPrice == null
            ? ''
            : _trim(product!.discountPrice!));
    stockController = TextEditingController(
        text: product == null ? '' : product.unitInStock.toString());
    pictureController = TextEditingController(text: product?.picture ?? '');
    categoryId = product?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    isAvailable = product?.isAvailable ?? true;
  }

  String _trim(double value) => value.toStringAsFixed(0);

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountController.dispose();
    stockController.dispose();
    pictureController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (categoryId == null) return;

    setState(() {
      saving = true;
      error = null;
    });
    final body = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      'price': double.parse(priceController.text.trim()),
      'discountPrice': discountController.text.trim().isEmpty
          ? null
          : double.parse(discountController.text.trim()),
      'unitInStock': int.parse(stockController.text.trim()),
      'picture': pictureController.text.trim().isEmpty
          ? null
          : pictureController.text.trim(),
      'categoryId': categoryId,
      'isAvailable': isAvailable,
    };

    final provider = context.read<AdminCatalogProvider>();
    final ok = await provider.saveProduct(body, id: widget.product?.productId);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        saving = false;
        error = provider.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? AppStrings.adminAddProductTitle
            : AppStrings.adminEditProductTitle),
      ),
      body: CafeSurface(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              CafeTextFormField(
                controller: nameController,
                labelText: AppStrings.productNameLabel,
                validator: (value) => CafeValidators.requiredField(
                    value, AppStrings.productNameLabel),
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: descriptionController,
                labelText: AppStrings.productDescriptionLabel,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: priceController,
                labelText: AppStrings.productPriceLabel,
                keyboardType: TextInputType.number,
                validator: _nonNegativeNumber,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: discountController,
                labelText: AppStrings.productDiscountPriceLabel,
                keyboardType: TextInputType.number,
                validator: _optionalNonNegativeNumber,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: stockController,
                labelText: AppStrings.productStockLabel,
                keyboardType: TextInputType.number,
                validator: _nonNegativeInt,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: pictureController,
                labelText: AppStrings.productPictureLabel,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: categoryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.productCategoryLabel,
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.categories
                    .map((category) => DropdownMenuItem(
                        value: category.id, child: Text(category.name)))
                    .toList(),
                onChanged: (value) => setState(() => categoryId = value),
                validator: (value) =>
                    value == null ? AppStrings.adminFieldRequiredMessage : null,
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                value: isAvailable,
                title: const Text(AppStrings.productAvailableLabel),
                onChanged: (value) => setState(() => isAvailable = value),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: const Text(AppStrings.adminSaveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _nonNegativeNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.adminFieldRequiredMessage;
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < 0) return AppStrings.adminInvalidNumberMessage;
  return null;
}

String? _optionalNonNegativeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < 0) return AppStrings.adminInvalidNumberMessage;
  return null;
}

String? _nonNegativeInt(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.adminFieldRequiredMessage;
  }
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 0) return AppStrings.adminInvalidNumberMessage;
  return null;
}
