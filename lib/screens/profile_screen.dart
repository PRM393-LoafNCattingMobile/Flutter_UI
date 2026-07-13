import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/image_upload_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;

  Future<void> _editProfile(AuthProvider auth) async {
    final user = auth.user;
    if (user == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(auth: auth, user: user),
    );

    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.profileUpdatedMessage)),
    );
  }

  Future<void> _updateAvatar(AuthProvider auth) async {
    if (auth.user == null || _uploadingAvatar) return;

    setState(() => _uploadingAvatar = true);
    try {
      final uploadService = ImageUploadService(auth.api);
      final uploaded =
          await uploadService.pickAndUpload(MediaUploadType.avatar);
      if (uploaded == null || !mounted) {
        return;
      }

      final ok = await auth.updateAvatar(uploaded.s3Key);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? AppStrings.profileAvatarUpdatedMessage
              : (auth.error ?? AppStrings.imageUploadFailedMessage)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            CafeHeroHeader(
              title: user?.name ?? AppStrings.profileGuestTitle,
              subtitle: user == null
                  ? AppStrings.profileGuestSubtitle
                  : AppStrings.localizedRoleName(user.roleName),
              icon: Icons.person,
              trailing: _ProfileAvatar(url: user?.avatarUrl),
            ),
            if (user != null)
              CafeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.profileAvatarSectionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.profileAvatarSectionSubtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: loafMuted),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: _ProfileAvatar(
                        url: user.avatarUrl,
                        radius: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _uploadingAvatar || auth.isLoading
                          ? null
                          : () => _updateAvatar(auth),
                      icon: _uploadingAvatar
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: const Text(AppStrings.profileAvatarUploadButton),
                    ),
                  ],
                ),
              ),
            if (user != null) const SizedBox(height: 18),
            CafeCard(
              child: Column(
                children: [
                  _ProfileRow(
                      icon: Icons.person_outline,
                      label: AppStrings.profileNameLabel,
                      value: user?.name ?? ''),
                  const Divider(height: 22),
                  _ProfileRow(
                      icon: Icons.mail_outline,
                      label: AppStrings.emailLabel,
                      value: user?.email ?? ''),
                  const Divider(height: 22),
                  _ProfileRow(
                      icon: Icons.phone_outlined,
                      label: AppStrings.profilePhoneLabel,
                      value: user?.phoneNumber ?? ''),
                ],
              ),
            ),
            if (user != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: auth.isLoading ? null : () => _editProfile(auth),
                icon: const Icon(Icons.edit_outlined),
                label: const Text(AppStrings.profileEditButton),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await SessionCoordinator().logout(
                  auth: auth,
                  cart: context.read<CartProvider>(),
                  reservations: context.read<ReservationProvider>(),
                  orderHistory: context.read<OrderHistoryProvider>(),
                  notifications: context.read<NotificationProvider>(),
                  chat: context.read<ChatProvider>(),
                );
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logoutButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.auth, required this.user});

  final AuthProvider auth;
  final AuthUser user;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  String? validationError;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(() {
        validationError = name.isEmpty
            ? AppStrings.nameRequiredMessage
            : AppStrings.phoneRequiredMessage;
      });
      return;
    }

    setState(() {
      saving = true;
      validationError = null;
    });

    final ok = await widget.auth.updateProfile(name, phone);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      saving = false;
      validationError =
          widget.auth.error ?? AppStrings.profileUpdateFailedMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.profileEditTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: AppStrings.profileNameLabel,
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: AppStrings.profilePhoneLabel,
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          if (validationError != null) ...[
            const SizedBox(height: 12),
            Text(
              validationError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancelButton),
        ),
        FilledButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.saveButton),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url, this.radius = 24});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveCafeMediaUrl(url);
    return CircleAvatar(
      radius: radius,
      backgroundColor: loafLightCream,
      backgroundImage: resolved == null ? null : NetworkImage(resolved),
      child: resolved == null
          ? Icon(Icons.person, size: radius, color: loafOrange)
          : null,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: loafOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: loafMuted)),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}
