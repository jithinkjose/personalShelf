import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../data/models/folder_model.dart';
import '../../data/models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vault_provider.dart';
import '../folder/folder_screen.dart';
import 'add_folder_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultProvider>().loadFolders(widget.profile.id);
    });
  }

  void _openAddFolder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFolderSheet(profileId: widget.profile.id),
    );
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(name: widget.profile.name),
    );
    if (confirmed == true && mounted) {
      final userId = context.read<AuthProvider>().currentUser!.id;
      await context.read<VaultProvider>().deleteProfile(widget.profile, userId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.profile.colorValue);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(color),
            Expanded(child: _buildFolderGrid(context)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader(Color color) {
    final vault = context.watch<VaultProvider>();
    final totalSize = vault.totalSizeForProfile(widget.profile.id);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Top bar with back + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  color: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.border),
                  ),
                  onSelected: (v) {
                    if (v == 'delete') _deleteProfile();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.hotPink, size: 18),
                          SizedBox(width: 8),
                          Text('Delete Profile',
                              style: TextStyle(color: AppColors.hotPink)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Profile info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    border: Border.all(color: color, width: 2),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), offset: const Offset(3, 3))],
                  ),
                  child: Center(
                    child: Text(widget.profile.emoji, style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.profile.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        widget.profile.relationship,
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalSize.readableSize} stored',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.mutedGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderGrid(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final folders = vault.folders.where((f) => f.profileId == widget.profile.id).toList();

    if (folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, color: AppColors.mutedGrey, size: 48),
            const SizedBox(height: 12),
            Text('No folders', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Tap + to add a folder.',
              style: TextStyle(color: AppColors.mutedGrey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: folders.length,
      itemBuilder: (_, i) => _FolderCard(
        folder: folders[i],
        index: i,
        onTap: () {
          context.read<VaultProvider>().selectFolder(folders[i]);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FolderScreen(folder: folders[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFab() {
    final color = Color(widget.profile.colorValue);
    return GestureDetector(
      onTap: _openAddFolder,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: AppColors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), offset: const Offset(4, 4))],
        ),
        child: Icon(
          Icons.create_new_folder_outlined,
          color: color.computeLuminance() > 0.4 ? AppColors.black : AppColors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final FolderModel folder;
  final int index;
  final VoidCallback onTap;

  const _FolderCard({
    required this.folder,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(folder.colorValue);
    final docCount = context.watch<VaultProvider>().docCountForFolder(folder.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.35),
            offset: const Offset(4, 4),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Center(
                child: Text(folder.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const Spacer(),
            Text(
              folder.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$docCount file${docCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      )
          .animate(delay: (index * 50).ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  final String name;
  const _ConfirmDeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "$name"?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'This will permanently delete all folders and documents in this profile. This cannot be undone.',
              style: TextStyle(color: AppColors.mutedGrey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hotPink,
                      foregroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
