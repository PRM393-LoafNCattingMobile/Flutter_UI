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
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
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
              obscurePassword: obscurePassword,
              onTogglePassword: () =>
                  setState(() => obscurePassword = !obscurePassword),
              onSubmit: () => _submit(auth),
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
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
          title: 'Join the cafe',
          subtitle: 'Order faster, reserve cozy tables, and meet the cats.',
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
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AuthProvider auth;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            CafeTextFormField(
              controller: nameController,
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) => CafeValidators.name(value),
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: const Icon(Icons.mail_outline),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: CafeValidators.email,
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: phoneController,
              labelText: 'Phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: CafeValidators.phone,
            ),
            const SizedBox(height: 12),
            CafeTextFormField(
              controller: passwordController,
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: CafeValidators.password,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
              onFieldSubmitted: (_) => onSubmit(),
            ),
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
              onPressed: auth.isLoading ? null : onSubmit,
              icon: auth.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite_outline),
              label: const Text(AppStrings.registerButton),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cafe profile keeps orders and reservations together.',
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
