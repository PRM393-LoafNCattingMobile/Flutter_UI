import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
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

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final result = await showDialog<({String name, String phoneNumber})>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phoneNumber = phoneController.text.trim();
              if (name.isEmpty || phoneNumber.isEmpty) return;
              Navigator.pop(
                dialogContext,
                (name: name, phoneNumber: phoneNumber),
              );
            },
            child: const Text(AppStrings.saveButton),
          ),
        ],
      ),
    );
    nameController.dispose();
    phoneController.dispose();
    if (result == null || !mounted) return;

    final ok = await auth.updateProfile(result.name, result.phoneNumber);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? AppStrings.profileUpdatedMessage
            : (auth.error ?? AppStrings.profileUpdatedMessage)),
      ),
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
                      label: AppStrings.phoneLabel,
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
