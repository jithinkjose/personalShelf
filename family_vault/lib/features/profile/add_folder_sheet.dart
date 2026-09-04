import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';

class AddFolderSheet extends StatefulWidget {
  final String profileId;
  const AddFolderSheet({super.key, required this.profileId});

  @override
  State<AddFolderSheet> createState() => _AddFolderSheetState();
}

class _AddFolderSheetState extends State<AddFolderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _selectedIcon = '📁';
  int _selectedColorIndex = 0;
  bool _saving = false;

  static const _icons = [
    '📁', '🪪', '🏥', '🎓', '💰', '🛡️',
    '⚖️', '✈️', '📷', '📜', '🏠', '🚗',
    '💊', '🎂', '📱', '💻', '🔑', '📋',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await context.read<VaultProvider>().createFolder(
          profileId: widget.profileId,
          name: _nameCtrl.text.trim(),
          icon: _selectedIcon,
          colorValue: AppColors.profileColors[_selectedColorIndex].value,
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
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                color: AppColors.border,
              ),
            ),
            Text('New Folder', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),

            NeoTextField(
              label: 'Folder Name',
              hint: 'e.g. Identity, Medical',
              controller: _nameCtrl,
              prefixIcon: Icons.folder_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 20),

            const Text(
              'ICON',
              style: TextStyle(
                color: AppColors.mutedGrey,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final icon = _icons[i];
                  final selected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.electricYellow.withOpacity(0.12)
                            : AppColors.surfaceElevated,
                        border: Border.all(
                          color: selected ? AppColors.electricYellow : AppColors.border,
                          width: selected ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'COLOUR',
              style: TextStyle(
                color: AppColors.mutedGrey,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
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
                      duration: const Duration(milliseconds: 130),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: selected ? AppColors.white : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check,
                              size: 16,
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

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: NeoButton.primary(
                label: 'Create Folder',
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
