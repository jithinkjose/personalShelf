import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account section
          _SectionHeader(label: 'ACCOUNT'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.person_outline,
            color: AppColors.electricBlue,
            title: user?.name ?? 'User',
            subtitle: user?.email ?? '',
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.lock_outline,
            color: AppColors.electricYellow,
            title: 'Change Password',
            onTap: () => _showChangePassword(context),
          ),
          const SizedBox(height: 24),

          // Security section
          _SectionHeader(label: 'SECURITY'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.06),
              border: Border.all(color: AppColors.neonGreen.withOpacity(0.25), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.neonGreen, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AES-256 Encryption Active',
                        style: TextStyle(
                          color: AppColors.neonGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'All your files are encrypted before storage. Decryption key stored in secure keychain.',
                        style: TextStyle(color: AppColors.neonGreen.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About section
          _SectionHeader(label: 'ABOUT'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline,
            color: AppColors.electricPurple,
            title: 'Family Vault',
            subtitle: 'Version 1.0.0',
          ),
          _SettingsTile(
            icon: Icons.storage_outlined,
            color: AppColors.electricCyan,
            title: 'Storage',
            subtitle: _storageInfo(context),
          ),
          const SizedBox(height: 32),

          // Sign out
          NeoButton.danger(
            label: 'Sign Out',
            icon: Icons.logout,
            onTap: () => _signOut(context),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _storageInfo(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    int total = 0;
    for (final p in vault.profiles) {
      total += vault.totalSizeForProfile(p.id);
    }
    if (total < 1024) return '$total B used';
    if (total < 1024 * 1024) return '${(total / 1024).toStringAsFixed(1)} KB used';
    return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB used';
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
        ),
        title: const Text('Sign Out?'),
        content: const Text(
          'Your encrypted data will remain on this device. You can sign back in any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.hotPink)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangePasswordSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.mutedGrey,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            color: AppColors.mutedGrey, fontSize: 12)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.mutedGrey, size: 20),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final success = await context.read<AuthProvider>().changePassword(
          _currentCtrl.text,
          _newCtrl.text,
        );
    setState(() => _saving = false);
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed'),
            backgroundColor: AppColors.neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                context.read<AuthProvider>().error ?? 'Failed to change password'),
            backgroundColor: AppColors.hotPink,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
          left: BorderSide(color: AppColors.border, width: 1.5),
          right: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                color: AppColors.border,
              ),
            ),
            Text('Change Password', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            NeoTextField(
              label: 'Current Password',
              controller: _currentCtrl,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            NeoTextField(
              label: 'New Password',
              controller: _newCtrl,
              obscureText: true,
              prefixIcon: Icons.lock_open,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            NeoTextField(
              label: 'Confirm New Password',
              controller: _confirmCtrl,
              obscureText: true,
              prefixIcon: Icons.lock_open,
              validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: NeoButton.primary(
                label: 'Update Password',
                loading: _saving,
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
