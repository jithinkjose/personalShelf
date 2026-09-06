import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';

class AddProfileSheet extends StatefulWidget {
  const AddProfileSheet({super.key});

  @override
  State<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends State<AddProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _relationshipCtrl = TextEditingController();

  String _selectedEmoji = AppConstants.profileEmojis[0];
  int _selectedColorIndex = 0;
  bool _saving = false;

  static const _relationships = [
    'Myself', 'Spouse', 'Child', 'Parent', 'Sibling',
    'Grandparent', 'Relative', 'Other',
  ];
  String _selectedRelationship = 'Myself';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationshipCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().currentUser!.id;
    await context.read<VaultProvider>().createProfile(
          userId: userId,
          name: _nameCtrl.text.trim(),
          emoji: _selectedEmoji,
          colorValue:
              AppColors.profileColors[_selectedColorIndex].value,
          relationship: _selectedRelationship,
        );
    if (mounted) Navigator.of(context).pop();
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
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                color: AppColors.border,
              ),
            ),
            Text(
              'New Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a locker for a family member.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedGrey,
                  ),
            ),
            const SizedBox(height: 24),

            // Emoji picker
            Text('Choose Avatar', style: _labelStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.profileEmojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final emoji = AppConstants.profileEmojis[i];
                  final selected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.electricYellow.withOpacity(0.15)
                            : AppColors.surfaceElevated,
                        border: Border.all(
                          color: selected
                              ? AppColors.electricYellow
                              : AppColors.border,
                          width: selected ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Color picker
            Text('Locker Colour', style: _labelStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.profileColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final color = AppColors.profileColors[i];
                  final selected = i == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: selected ? AppColors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]
                            : [],
                      ),
                      child: selected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: color.computeLuminance() > 0.4
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            NeoTextField(
              label: 'Name',
              hint: 'e.g. Rahul, Priya',
              controller: _nameCtrl,
              prefixIcon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Relationship picker
            Text('Relationship', style: _labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _relationships.map((r) {
                final selected = r == _selectedRelationship;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRelationship = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.electricYellow
                          : AppColors.surfaceElevated,
                      border: Border.all(
                        color: selected ? AppColors.electricYellow : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      r,
                      style: TextStyle(
                        color: selected ? AppColors.black : AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: NeoButton.primary(
                label: 'Create Profile',
                loading: _saving,
                onTap: _save,
                icon: Icons.lock,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(
        color: AppColors.mutedGrey,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
}
