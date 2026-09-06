import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.hotPink,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo / Brand
                _buildBrand()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 56),

                Text(
                  'Welcome\nback.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 8),
                Text(
                  'Sign in to access your family vault.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedGrey,
                      ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 40),

                NeoTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: 16),

                NeoTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    child: NeoButton.primary(
                      label: 'Sign In',
                      loading: auth.isLoading,
                      onTap: _login,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.mutedGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: Text(
                        'Create one',
                        style: TextStyle(
                          color: AppColors.electricYellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.electricYellow,
            boxShadow: [AppTheme.neoShadow(AppColors.electricBlue)],
          ),
          child: const Icon(Icons.lock, color: AppColors.black, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FAMILY',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            Text(
              'VAULT',
              style: TextStyle(
                color: AppColors.electricYellow,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
