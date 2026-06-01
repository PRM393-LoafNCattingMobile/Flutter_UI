import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Email or phone',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: loginController,
                          decoration: const InputDecoration(
                            hintText: 'Enter email or phone',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Password',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            hintText: 'Enter password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: Icon(Icons.visibility_outlined),
                          ),
                          obscureText: true,
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
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  final ok = await auth.login(
                                      loginController.text,
                                      passwordController.text);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  }
                                },
                          icon: auth.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
