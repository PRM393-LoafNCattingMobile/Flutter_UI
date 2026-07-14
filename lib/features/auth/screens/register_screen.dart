import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final verificationCodeController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createAccountTitle)),
      body: CafeSurface(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _RegisterHeader(),
            _RegisterFormCard(
              formKey: formKey,
              auth: auth,
              nameController: nameController,
              emailController: emailController,
              phoneController: phoneController,
              passwordController: passwordController,
              verificationCodeController: verificationCodeController,
              obscurePassword: obscurePassword,
              onTogglePassword: () =>
                  setState(() => obscurePassword = !obscurePassword),
              onSubmit: () => _submit(auth),
              onVerify: () => _verify(auth),
              onResend: () => _resend(auth),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(AuthProvider auth) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    final ok = await auth.register(
      nameController.text.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      verificationCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.verificationEmailSentTo(
              auth.pendingVerification!.email,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _verify(AuthProvider auth) async {
    final code = verificationCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.verificationCodeRequiredMessage),
        ),
      );
      return;
    }

    final ok = await auth.verifyEmail(code);
    if (!mounted) return;
    if (ok) {
      await context.read<CartProvider>().loadForUser(auth.user!.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.verificationSuccessMessage)),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
    }
  }

  Future<void> _resend(AuthProvider auth) async {
    final ok = await auth.resendVerification();
    if (!mounted) return;
    if (ok) {
      verificationCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.resendVerificationSuccessMessage),
        ),
      );
    }
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 14),
        Center(
          child: CafeBrandLogo(width: 196, height: 150),
        ),
        SizedBox(height: 16),
        CafeHeroHeader(
          title: AppStrings.registerHeroTitle,
          subtitle: AppStrings.registerHeroSubtitle,
          icon: Icons.pets,
        ),
      ],
    );
  }
}

class _RegisterFormCard extends StatelessWidget {
  const _RegisterFormCard({
    required this.formKey,
    required this.auth,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.verificationCodeController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onVerify,
    required this.onResend,
  });

  final GlobalKey<FormState> formKey;
  final AuthProvider auth;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController verificationCodeController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final awaitingVerification = auth.isAwaitingEmailVerification;
    final challenge = auth.pendingVerification;
    return CafeCard(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            CafeTextFormField(
              controller: nameController,
              readOnly: awaitingVerification,
              labelText: AppStrings.guestNameLabel,
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) => CafeValidators.name(value),
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: emailController,
              readOnly: awaitingVerification,
              labelText: AppStrings.emailLabel,
              prefixIcon: const Icon(Icons.mail_outline),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: CafeValidators.email,
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: phoneController,
              readOnly: awaitingVerification,
              labelText: AppStrings.phoneNumberLabel,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: CafeValidators.phone,
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: passwordController,
              readOnly: awaitingVerification,
              labelText: AppStrings.passwordLabel,
              prefixIcon: const Icon(Icons.lock_outline),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: CafeValidators.password,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                onPressed: awaitingVerification ? null : onTogglePassword,
                icon: Icon(obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
              onFieldSubmitted: (_) =>
                  awaitingVerification ? onVerify() : onSubmit(),
            ),
            if (challenge != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.verificationCardTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.verificationCardSubtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: loafMuted),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.verificationEmailSentTo(challenge.email),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.verificationExpiresAt(
                  challenge.expiresAtUtc.toLocal(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: loafMuted),
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: verificationCodeController,
                labelText: AppStrings.verificationCodeLabel,
                hintText: AppStrings.verificationCodeHint,
                prefixIcon: const Icon(Icons.mark_email_read_outlined),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onVerify(),
              ),
            ],
            if (auth.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  auth.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : awaitingVerification
                      ? onVerify
                      : onSubmit,
              icon: auth.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(awaitingVerification
                      ? Icons.verified_outlined
                      : Icons.favorite_outline),
              label: Text(awaitingVerification
                  ? AppStrings.verifyEmailButton
                  : AppStrings.registerButton),
            ),
            if (awaitingVerification) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: auth.isLoading ? null : onResend,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.resendVerificationButton),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              awaitingVerification
                  ? AppStrings.verificationCardSubtitle
                  : AppStrings.registerHelperText,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: loafMuted),
            ),
          ],
        ),
      ),
    );
  }
}
