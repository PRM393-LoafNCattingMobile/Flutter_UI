import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';
import 'package:loafncatting_mobile/features/admin/widgets/status_picker.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/image_upload_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';
part '../widgets/admin_cats_widgets.dart';

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
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<AdminCatProvider>().load();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    final lookups = context.watch<AdminLookupsProvider>().lookups;
    final canManage = _canManage;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminCatsTitle)),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _openForm(null),
              child: const Icon(Icons.add),
            )
          : null,
      body: CafeSurface(
        child: Column(
          children: [
            _AdminCatFilterHeader(
              provider: provider,
              lookups: lookups,
              searchController: searchController,
              onOpenFilters: lookups == null
                  ? null
                  : () => _showCatFilters(context, provider, lookups),
              onResetFilters: () {
                searchController.clear();
                provider.resetCatFilters();
              },
              onClearSearch: () {
                searchController.clear();
                provider.clearSearchFilter();
              },
            ),
            Expanded(child: _buildBody(provider, canManage)),
          ],
        ),
      ),
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
      return EmptyView(provider.hasCatFilters
          ? 'Kh\u00f4ng t\u00ecm th\u1ea5y b\u00e9 m\u00e8o n\u00e0o.'
          : AppStrings.adminCatsEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
