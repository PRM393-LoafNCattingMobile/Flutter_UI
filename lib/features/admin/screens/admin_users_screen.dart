import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/status_picker.dart';
import 'package:loafncatting_mobile/services/image_upload_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<AdminUserProvider>().load();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _createStaff() async {
    final provider = context.read<AdminUserProvider>();
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _CreateStaffDialog(),
    );
    if (body == null) return;
    final ok = await provider.createStaff(body);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminSavedMessage
          : (provider.error ?? AppStrings.adminSavedMessage)),
    ));
  }

  Future<void> _changeRole(AdminUser user) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    final provider = context.read<AdminUserProvider>();
    if (lookups == null) return;
    final roleOptions = lookups.roles
        .where((role) => role.name == 'Staff' || role.name == 'Customer')
        .toList();
    final roleId = await showStatusPicker(
      context,
      title: AppStrings.adminChangeRoleTitle,
      options: roleOptions,
      currentName: user.roleName,
    );
    if (roleId == null || !mounted) return;
    final ok = await provider.updateRole(user.userId, roleId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminSavedMessage
          : (provider.error ?? AppStrings.adminSavedMessage)),
    ));
  }

  Future<void> _toggleActive(AdminUser user) async {
    final provider = context.read<AdminUserProvider>();
    final ok = await provider.updateActive(user.userId, !user.isActive);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminSavedMessage
          : (provider.error ?? AppStrings.adminSavedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminUsersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createStaff,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(AppStrings.adminCreateStaffTitle),
      ),
      body: CafeSurface(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: AppStrings.adminUsersSearchHint,
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) =>
                    provider.applyFilters(keyword: value.trim()),
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AdminUserProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    if (provider.users.isEmpty) {
      return const EmptyView(AppStrings.adminUsersEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        itemCount: provider.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final user = provider.users[index];
          return _UserCard(
            user: user,
            onChangeRole: () => _changeRole(user),
            onToggleActive: () => _toggleActive(user),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onChangeRole,
    required this.onToggleActive,
  });

  final AdminUser user;
  final VoidCallback onChangeRole;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = resolveCafeMediaUrl(user.avatarUrl);
    return CafeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: loafLightCream,
                backgroundImage:
                    avatarUrl == null ? null : NetworkImage(avatarUrl),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: loafOrange)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: theme.textTheme.titleMedium),
                    Text('${user.email} - ${user.phoneNumber}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: loafMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CafeInfoChip(label: AppStrings.localizedRoleName(user.roleName)),
              CafeInfoChip(
                  label: user.isActive
                      ? AppStrings.adminUserActiveLabel
                      : AppStrings.adminUserInactiveLabel),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onChangeRole,
                icon: const Icon(Icons.badge_outlined),
                label: const Text(AppStrings.adminChangeRoleAction),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: onToggleActive,
                icon:
                    Icon(user.isActive ? Icons.lock_outline : Icons.lock_open),
                label: Text(user.isActive
                    ? AppStrings.adminDeactivateAction
                    : AppStrings.adminActivateAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateStaffDialog extends StatefulWidget {
  const _CreateStaffDialog();

  @override
  State<_CreateStaffDialog> createState() => _CreateStaffDialogState();
}

class _CreateStaffDialogState extends State<_CreateStaffDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  bool uploadingAvatar = false;
  String? avatarKey;
  String? avatarPreviewUrl;
  String? uploadError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _uploadAvatar() async {
    if (uploadingAvatar) return;

    setState(() {
      uploadingAvatar = true;
      uploadError = null;
    });

    try {
      final uploadService =
          ImageUploadService(context.read<AdminUserProvider>().api);
      final uploaded =
          await uploadService.pickAndUpload(MediaUploadType.avatar);
      if (uploaded == null || !mounted) {
        return;
      }

      setState(() {
        avatarKey = uploaded.s3Key;
        avatarPreviewUrl = uploaded.displayUrl;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => uploadError = friendlyErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => uploadingAvatar = false);
      }
    }
  }

  void _clearAvatar() {
    setState(() {
      avatarKey = null;
      avatarPreviewUrl = null;
      uploadError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.adminCreateStaffTitle),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CafeTextFormField(
                controller: nameController,
                labelText: AppStrings.receiverNameLabel,
                validator: CafeValidators.name,
              ),
              const SizedBox(height: 10),
              CafeTextFormField(
                controller: emailController,
                labelText: AppStrings.emailLabel,
                keyboardType: TextInputType.emailAddress,
                validator: CafeValidators.email,
              ),
              const SizedBox(height: 10),
              CafeTextFormField(
                controller: phoneController,
                labelText: AppStrings.phoneLabel,
                keyboardType: TextInputType.phone,
                validator: CafeValidators.phone,
              ),
              const SizedBox(height: 10),
              CafeTextFormField(
                controller: passwordController,
                labelText: AppStrings.passwordLabel,
                obscureText: true,
                validator: CafeValidators.password,
              ),
              const SizedBox(height: 10),
              CafeTextFormField(
                controller: addressController,
                labelText: AppStrings.adminStoreAddressLabel,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.profileAvatarSectionTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.imageUploadHint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: loafMuted),
              ),
              const SizedBox(height: 12),
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: loafLightCream,
                  backgroundImage: avatarPreviewUrl == null
                      ? null
                      : NetworkImage(avatarPreviewUrl!),
                  child: avatarPreviewUrl == null
                      ? const Icon(Icons.person, size: 36, color: loafOrange)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: uploadingAvatar ? null : _uploadAvatar,
                      icon: uploadingAvatar
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        avatarKey == null
                            ? AppStrings.imageUploadButton
                            : AppStrings.imageReplaceButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: avatarKey == null ? null : _clearAvatar,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text(AppStrings.imageRemoveButton),
                  ),
                ],
              ),
              if (uploadError != null) ...[
                const SizedBox(height: 8),
                Text(
                  uploadError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
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
              'email': emailController.text.trim(),
              'phoneNumber': phoneController.text.trim(),
              'password': passwordController.text,
              'address': addressController.text.trim().isEmpty
                  ? null
                  : addressController.text.trim(),
              'avatarUrl': avatarKey,
            });
          },
          child: const Text(AppStrings.adminSaveButton),
        ),
      ],
    );
  }
}
