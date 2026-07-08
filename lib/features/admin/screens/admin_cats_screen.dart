import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/status_picker.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/image_upload_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

int? lookupIdForName(List<LookupItem> options, String? name) {
  for (final option in options) {
    if (option.name == name) return option.id;
  }
  return null;
}

class AdminCatsScreen extends StatefulWidget {
  const AdminCatsScreen({super.key});

  @override
  State<AdminCatsScreen> createState() => _AdminCatsScreenState();
}

class _AdminCatsScreenState extends State<AdminCatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<AdminCatProvider>().load();
    });
  }

  bool get _canManage =>
      RoleRouting.isStaffOrAdmin(context.read<AuthProvider>().user?.roleName);

  Future<void> _openForm(Cat? cat) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    if (lookups == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminCatFormScreen(
          cat: cat,
          genders: lookups.genders,
          statuses: lookups.catStatuses,
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.adminSavedMessage)));
    }
  }

  Future<void> _delete(Cat cat) async {
    final provider = context.read<AdminCatProvider>();
    final confirmed = await _confirmDelete(context);
    if (confirmed != true) return;
    final ok = await provider.deleteCat(cat.catId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminDeletedMessage
          : (provider.error ?? AppStrings.adminDeletedMessage)),
    ));
  }

  Future<void> _updateStatus(Cat cat) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    final provider = context.read<AdminCatProvider>();
    if (lookups == null) return;
    final statusId = await showStatusPicker(
      context,
      title: AppStrings.adminUpdateStatusTitle,
      options: lookups.catStatuses,
      currentName: cat.statusName,
    );
    if (statusId == null || !mounted) return;
    final ok = await provider.updateStatus(cat.catId, statusId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminStatusUpdatedMessage
          : (provider.error ?? AppStrings.adminStatusUpdatedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCatProvider>();
    final canManage = _canManage;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminCatsTitle)),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _openForm(null),
              child: const Icon(Icons.add),
            )
          : null,
      body: CafeSurface(child: _buildBody(provider, canManage)),
    );
  }

  Widget _buildBody(AdminCatProvider provider, bool canManage) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    if (provider.cats.isEmpty) {
      return const EmptyView(AppStrings.adminCatsEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.cats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final cat = provider.cats[index];
          return CafeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CafeImageFrame(
                        imageUrl: cat.picture,
                        icon: Icons.pets,
                        label: cat.name,
                        borderRadius: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(cat.breed ?? AppStrings.unknownBreed,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: loafMuted)),
                          const SizedBox(height: 6),
                          Text(
                            cat.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: loafMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CafeInfoChip(label: cat.statusName),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: canManage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => _openForm(cat),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text(AppStrings.adminSaveButton),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(cat),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () => _updateStatus(cat),
                          icon: const Icon(Icons.sync),
                          label: const Text(AppStrings.adminUpdateStatusButton),
                        ),
                ),
              ],
            ),
          );
        },
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

class AdminCatFormScreen extends StatefulWidget {
  const AdminCatFormScreen({
    super.key,
    this.cat,
    required this.genders,
    required this.statuses,
  });

  final Cat? cat;
  final List<LookupItem> genders;
  final List<LookupItem> statuses;

  @override
  State<AdminCatFormScreen> createState() => _AdminCatFormScreenState();
}

class _AdminCatFormScreenState extends State<AdminCatFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController breedController;
  late final TextEditingController pictureController;
  late final TextEditingController descriptionController;
  late final TextEditingController friendlinessController;
  late final TextEditingController cutenessController;
  late final TextEditingController playfulnessController;
  int? genderId;
  int? statusId;
  bool saving = false;
  bool uploadingImage = false;
  String? error;
  String? picturePreviewUrl;

  @override
  void initState() {
    super.initState();
    final cat = widget.cat;
    nameController = TextEditingController(text: cat?.name ?? '');
    ageController = TextEditingController(text: cat?.age?.toString() ?? '');
    breedController = TextEditingController(text: cat?.breed ?? '');
    pictureController = TextEditingController(text: cat?.pictureKey ?? '');
    descriptionController = TextEditingController(text: cat?.description ?? '');
    friendlinessController =
        TextEditingController(text: cat?.friendlinessRating?.toString() ?? '');
    cutenessController =
        TextEditingController(text: cat?.cutenessRating?.toString() ?? '');
    playfulnessController =
        TextEditingController(text: cat?.playfulnessRating?.toString() ?? '');
    genderId = lookupIdForName(widget.genders, cat?.genderName);
    statusId = lookupIdForName(widget.statuses, cat?.statusName) ??
        (widget.statuses.isNotEmpty ? widget.statuses.first.id : null);
    picturePreviewUrl = cat?.picture;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    breedController.dispose();
    pictureController.dispose();
    descriptionController.dispose();
    friendlinessController.dispose();
    cutenessController.dispose();
    playfulnessController.dispose();
    super.dispose();
  }

  int? _optionalInt(String text) =>
      text.trim().isEmpty ? null : int.tryParse(text.trim());

  String? _emptyOr(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _uploadPicture() async {
    if (uploadingImage) return;

    setState(() {
      uploadingImage = true;
      error = null;
    });

    try {
      final uploadService =
          ImageUploadService(context.read<AdminCatProvider>().api);
      final uploaded = await uploadService.pickAndUpload(MediaUploadType.cat);
      if (uploaded == null || !mounted) {
        return;
      }

      setState(() {
        pictureController.text = uploaded.s3Key;
        picturePreviewUrl = uploaded.displayUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.imageUploadSuccessMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => uploadingImage = false);
      }
    }
  }

  void _clearPicture() {
    setState(() {
      pictureController.clear();
      picturePreviewUrl = null;
    });
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (statusId == null) return;
    setState(() {
      saving = true;
      error = null;
    });
    final body = {
      'name': nameController.text.trim(),
      'age': _optionalInt(ageController.text),
      'genderId': genderId,
      'breed': _emptyOr(breedController.text),
      'picture': _emptyOr(pictureController.text),
      'description': _emptyOr(descriptionController.text),
      'friendlinessRating': _optionalInt(friendlinessController.text),
      'cutenessRating': _optionalInt(cutenessController.text),
      'playfulnessRating': _optionalInt(playfulnessController.text),
      'statusId': statusId,
    };
    final provider = context.read<AdminCatProvider>();
    final ok = await provider.saveCat(body, id: widget.cat?.catId);
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

  String? _rating(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 5) {
      return AppStrings.adminInvalidNumberMessage;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat == null
            ? AppStrings.adminAddCatTitle
            : AppStrings.adminEditCatTitle),
      ),
      body: CafeSurface(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              CafeTextFormField(
                controller: nameController,
                labelText: AppStrings.catNameLabel,
                validator: (value) => CafeValidators.requiredField(
                    value, AppStrings.catNameLabel),
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: ageController,
                labelText: AppStrings.catAgeLabel,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return AppStrings.adminInvalidNumberMessage;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: genderId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.catGenderLabel,
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: widget.genders
                    .map((gender) => DropdownMenuItem<int?>(
                        value: gender.id, child: Text(gender.name)))
                    .toList(),
                onChanged: (value) => setState(() => genderId = value),
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: breedController,
                labelText: AppStrings.catBreedLabel,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: pictureController,
                labelText: AppStrings.catPictureLabel,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.imageUploadHint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: CafeImageFrame(
                  imageUrl: picturePreviewUrl,
                  icon: Icons.pets,
                  label: nameController.text.trim().isEmpty
                      ? AppStrings.catNameLabel
                      : nameController.text.trim(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: uploadingImage ? null : _uploadPicture,
                      icon: uploadingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        pictureController.text.trim().isEmpty
                            ? AppStrings.imageUploadButton
                            : AppStrings.imageReplaceButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: pictureController.text.trim().isEmpty
                        ? null
                        : _clearPicture,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text(AppStrings.imageRemoveButton),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: descriptionController,
                labelText: AppStrings.catDescriptionLabel,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: friendlinessController,
                labelText: AppStrings.catFriendlinessLabel,
                keyboardType: TextInputType.number,
                validator: _rating,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: cutenessController,
                labelText: AppStrings.catCutenessLabel,
                keyboardType: TextInputType.number,
                validator: _rating,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: playfulnessController,
                labelText: AppStrings.catPlayfulnessLabel,
                keyboardType: TextInputType.number,
                validator: _rating,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: statusId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.catStatusLabel,
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: widget.statuses
                    .map((status) => DropdownMenuItem(
                        value: status.id, child: Text(status.name)))
                    .toList(),
                onChanged: (value) => setState(() => statusId = value),
                validator: (value) =>
                    value == null ? AppStrings.adminFieldRequiredMessage : null,
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
