import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

/// Cập nhật vị trí cửa hàng (Admin-only). Prefill từ `LocationProvider`.
class AdminStoreLocationScreen extends StatefulWidget {
  const AdminStoreLocationScreen({super.key});

  @override
  State<AdminStoreLocationScreen> createState() =>
      _AdminStoreLocationScreenState();
}

class _AdminStoreLocationScreenState extends State<AdminStoreLocationScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final hoursController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  bool seeded = false;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationProvider>().load();
    });
  }

  void _seed(LocationProvider provider) {
    if (seeded || provider.location == null) return;
    final location = provider.location!;
    nameController.text = location.storeName;
    addressController.text = location.address;
    phoneController.text = location.phoneNumber ?? '';
    hoursController.text = location.openingHours ?? '';
    latitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
    seeded = true;
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    hoursController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  String? _coordinate(String? value, double min, double max) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.adminFieldRequiredMessage;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < min || parsed > max) {
      return AppStrings.adminInvalidNumberMessage;
    }
    return null;
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() {
      saving = true;
      error = null;
    });
    final body = {
      'storeName': nameController.text.trim(),
      'address': addressController.text.trim(),
      'phoneNumber': phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      'openingHours': hoursController.text.trim().isEmpty
          ? null
          : hoursController.text.trim(),
      'latitude': double.parse(latitudeController.text.trim()),
      'longitude': double.parse(longitudeController.text.trim()),
    };
    try {
      await context.read<AuthProvider>().api.updateStoreLocation(body);
      if (!mounted) return;
      await context.read<LocationProvider>().load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.adminSavedMessage)));
      Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() {
        saving = false;
        error = friendlyErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        saving = false;
        error = friendlyErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();
    _seed(provider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminStoreLocationTitle)),
      body: CafeSurface(
        child: provider.isLoading && !seeded
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    CafeTextFormField(
                      controller: nameController,
                      labelText: AppStrings.adminStoreNameLabel,
                      validator: (value) => CafeValidators.requiredField(
                          value, AppStrings.adminStoreNameLabel),
                    ),
                    const SizedBox(height: 12),
                    CafeTextFormField(
                      controller: addressController,
                      labelText: AppStrings.adminStoreAddressLabel,
                      maxLines: 2,
                      validator: (value) => CafeValidators.requiredField(
                          value, AppStrings.adminStoreAddressLabel),
                    ),
                    const SizedBox(height: 12),
                    CafeTextFormField(
                      controller: phoneController,
                      labelText: AppStrings.adminStorePhoneLabel,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    CafeTextFormField(
                      controller: hoursController,
                      labelText: AppStrings.adminStoreHoursLabel,
                    ),
                    const SizedBox(height: 12),
                    CafeTextFormField(
                      controller: latitudeController,
                      labelText: AppStrings.adminStoreLatitudeLabel,
                      keyboardType: TextInputType.number,
                      validator: (value) => _coordinate(value, -90, 90),
                    ),
                    const SizedBox(height: 12),
                    CafeTextFormField(
                      controller: longitudeController,
                      labelText: AppStrings.adminStoreLongitudeLabel,
                      keyboardType: TextInputType.number,
                      validator: (value) => _coordinate(value, -180, 180),
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
