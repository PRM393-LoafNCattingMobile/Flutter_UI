import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [loafLightCream, loafSoftOrange, loafOrange],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(top: 52, left: 46, child: _DecorPaw(size: 30)),
              const Positioned(top: 96, right: 34, child: _DecorPaw(size: 42)),
              const Positioned(
                  bottom: 34, left: 44, child: _DecorPaw(size: 34)),
              const Positioned(
                  bottom: 74, right: 32, child: _DecorPaw(size: 36)),
              ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(22, 42, 22, 24),
                children: [
                  const SizedBox(height: 10),
                  const Center(child: CafeBrandLogo()),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .62),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: loafOrange.withValues(alpha: .2)),
                      ),
                      child: Text(
                        'Cat Cafe & Good Bites',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: loafBrown,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  CafeCard(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CafeTextFormField(
                            controller: loginController,
                            labelText: 'Email or phone',
                            hintText: 'Enter email or phone',
                            prefixIcon: const Icon(Icons.mail_outline),
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                              AutofillHints.telephoneNumber,
                            ],
                            validator: CafeValidators.loginIdentity,
                          ),
                          const SizedBox(height: 16),
                          CafeTextFormField(
                            controller: passwordController,
                            labelText: 'Password',
                            hintText: 'Enter password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: CafeValidators.password,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword),
                              icon: Icon(obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                            onFieldSubmitted: (_) => _submit(auth),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          if (auth.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(auth.error!,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ),
                          FilledButton.icon(
                            onPressed: auth.isLoading ? null : () => _submit(auth),
                            icon: auth.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.pets),
                            label: const Text('Sign in'),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('or',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: loafMuted)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Create account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'Good coffee. Great cats.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AuthProvider auth) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    final ok = await auth.login(
      loginController.text.trim(),
      passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

class _DecorPaw extends StatelessWidget {
  const _DecorPaw({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.pets,
        color: Colors.white.withValues(alpha: .22), size: size);
  }
}
