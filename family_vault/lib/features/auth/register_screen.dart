import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailCtrl.text.trim(),
      _nameCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Text(
                  'Create your\nvault.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 8),
                Text(
                  'Your documents stay encrypted on your device.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedGrey,
                      ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                const SizedBox(height: 32),

                // Security badge
                _SecurityBadge()
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 500.ms),

                const SizedBox(height: 32),

                NeoTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 16),

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
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 16),

                NeoTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 16),

                NeoTextField(
                  label: 'Confirm Password',
                  controller: _confirmCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    child: NeoButton.primary(
                      label: 'Create Vault',
                      loading: auth.isLoading,
                      onTap: _register,
                      icon: Icons.lock,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.08),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.neonGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AES-256 encryption • All data stays on your device • No cloud sync',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
