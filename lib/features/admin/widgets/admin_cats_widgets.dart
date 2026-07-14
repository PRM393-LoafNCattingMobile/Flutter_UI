part of '../screens/admin_cats_screen.dart';

class _AdminCatFilterHeader extends StatelessWidget {
  const _AdminCatFilterHeader({
    required this.provider,
    required this.lookups,
    required this.searchController,
    required this.onOpenFilters,
    required this.onResetFilters,
    required this.onClearSearch,
  });

  final AdminCatProvider provider;
  final AdminLookups? lookups;
  final TextEditingController searchController;
  final VoidCallback? onOpenFilters;
  final VoidCallback onResetFilters;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'T\u00ecm m\u00e8o',
                  ),
                  onSubmitted: (value) => provider.applySearch(value.trim()),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: loafBorder),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: onOpenFilters,
                          icon: const Icon(Icons.tune),
                        ),
                      ),
                    ),
                    if (provider.hasCatFilters)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: loafOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (provider.hasCatFilters)
          _AdminCatActiveFilters(
            provider: provider,
            onResetFilters: onResetFilters,
            onClearSearch: onClearSearch,
          ),
      ],
    );
  }
}

class _AdminCatActiveFilters extends StatelessWidget {
  const _AdminCatActiveFilters({
    required this.provider,
    required this.onResetFilters,
    required this.onClearSearch,
  });

  final AdminCatProvider provider;
  final VoidCallback onResetFilters;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (provider.search.trim().isNotEmpty)
            _ActiveFilterChip(
              label: 'T\u00ecm: ${provider.search.trim()}',
              onDeleted: onClearSearch,
            ),
          if (provider.statusFilterName != null)
            _ActiveFilterChip(
              label: provider.statusFilterName!,
              onDeleted: () => provider.applyStatusFilter(null),
            ),
          if (provider.genderFilterName != null)
            _ActiveFilterChip(
              label: provider.genderFilterName!,
              onDeleted: () => provider.applyGenderFilter(null),
            ),
          if (provider.notWorkingOnly)
            _ActiveFilterChip(
              label: 'M\u00e8o ngh\u1ec9/\u1ed1m',
              onDeleted: provider.clearNotWorkingFilter,
            ),
          TextButton(
            onPressed: onResetFilters,
            child: const Text(AppStrings.resetButton),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }
}

Future<void> _showCatFilters(
  BuildContext context,
  AdminCatProvider provider,
  AdminLookups lookups,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CatFilterSheet(provider: provider, lookups: lookups),
  );
}

class _CatFilterSheet extends StatefulWidget {
  const _CatFilterSheet({
    required this.provider,
    required this.lookups,
  });

  final AdminCatProvider provider;
  final AdminLookups lookups;

  @override
  State<_CatFilterSheet> createState() => _CatFilterSheetState();
}

class _CatFilterSheetState extends State<_CatFilterSheet> {
  String? statusName;
  String? genderName;
  bool notWorkingOnly = false;

  @override
  void initState() {
    super.initState();
    statusName = widget.provider.statusFilterName;
    genderName = widget.provider.genderFilterName;
    notWorkingOnly = widget.provider.notWorkingOnly;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: loafBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(AppStrings.filterSheetTitle,
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: _resetDraft,
                  child: const Text(AppStrings.resetButton),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FilterSection(
              title: AppStrings.adminFilterByStatusLabel,
              children: [
                _FilterChoice(
                  label: AppStrings.adminFilterAllStatuses,
                  selected: statusName == null,
                  onSelected: () => setState(() => statusName = null),
                ),
                ...widget.lookups.catStatuses.map(
                  (status) => _FilterChoice(
                    label: status.name,
                    selected: statusName == status.name,
                    onSelected: () => setState(() => statusName = status.name),
                  ),
                ),
              ],
            ),
            _FilterSection(
              title: AppStrings.catGenderLabel,
              children: [
                _FilterChoice(
                  label: AppStrings.allCategoryLabel,
                  selected: genderName == null,
                  onSelected: () => setState(() => genderName = null),
                ),
                ...widget.lookups.genders.map(
                  (gender) => _FilterChoice(
                    label: gender.name,
                    selected: genderName == gender.name,
                    onSelected: () => setState(() => genderName = gender.name),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: loafOrange,
              title: const Text(AppStrings.adminCatsNotWorkingOnlyLabel),
              value: notWorkingOnly,
              onChanged: (value) => setState(() => notWorkingOnly = value),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                widget.provider.applyStatusFilter(statusName);
                widget.provider.applyGenderFilter(genderName);
                widget.provider.applyNotWorkingFilter(notWorkingOnly);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text(AppStrings.applyButton),
            ),
          ],
        ),
      ),
    );
  }

  void _resetDraft() {
    setState(() {
      statusName = null;
      genderName = null;
      notWorkingOnly = false;
    });
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ],
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
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
