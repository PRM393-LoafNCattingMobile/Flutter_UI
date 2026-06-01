import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

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
      appBar: AppBar(title: const Text('Create account')),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SizedBox(height: 14),
            const Center(
              child: CafeBrandLogo(width: 196, height: 150),
            ),
            const SizedBox(height: 16),
            const CafeHeroHeader(
              title: 'Join the cafe',
              subtitle: 'Order faster, reserve cozy tables, and meet the cats.',
              icon: Icons.pets,
            ),
            CafeCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline)),
                      obscureText: true),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(auth.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final ok = await auth.register(
                                nameController.text,
                                emailController.text,
                                phoneController.text,
                                passwordController.text);
                            if (!context.mounted) return;
                            if (ok) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (_) => false);
                            }
                          },
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.favorite_outline),
                    label: const Text('Register'),
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
          ],
        ),
      ),
    );
  }
}
