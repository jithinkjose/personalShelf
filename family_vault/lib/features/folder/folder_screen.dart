import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../data/models/document_model.dart';
import '../../data/models/folder_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/vault_provider.dart';
import '../document/document_viewer_screen.dart';

class FolderScreen extends StatefulWidget {
  final FolderModel folder;

  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultProvider>().loadDocuments(widget.folder.id);
    });
  }

  Future<void> _pickFiles() async {
    setState(() => _uploading = true);
    try {
      final docs = await FileService.instance.pickAndStoreFiles(
        profileId: widget.folder.profileId,
        folderId: widget.folder.id,
      );
      if (!mounted) return;
      if (docs.isNotEmpty) {
        await context.read<VaultProvider>().addDocuments(docs);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${docs.length} file(s) added'),
            backgroundColor: AppColors.neonGreen.withOpacity(0.9),
            shape: const RoundedRectangleBorder(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    setState(() => _uploading = true);
    try {
      final doc = await FileService.instance.pickImageAndStore(
        profileId: widget.folder.profileId,
        folderId: widget.folder.id,
        source: source,
      );
      if (doc != null && mounted) {
        await context.read<VaultProvider>().addDocuments([doc]);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFileSheet(
        onPickFiles: _pickFiles,
        onCamera: () => _pickImage(ImageSource.camera),
        onGallery: () => _pickImage(ImageSource.gallery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.folder.colorValue);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.folder.icon),
            const SizedBox(width: 8),
            Text(widget.folder.name),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_uploading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(context, color),
      floatingActionButton: _buildFab(color),
    );
  }

  Widget _buildBody(BuildContext context, Color color) {
    final vault = context.watch<VaultProvider>();
    final docs = vault.documents
        .where((d) => d.folderId == widget.folder.id)
        .toList();

    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Center(
                child: Text(widget.folder.icon, style: const TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(height: 20),
            Text('No files yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Tap + to add documents, photos, or PDFs.',
              style: TextStyle(color: AppColors.mutedGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _DocumentTile(
        doc: docs[i],
        index: i,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DocumentViewerScreen(document: docs[i]),
          ),
        ),
        onDelete: () => _confirmDelete(context, docs[i]),
        onShare: () => FileService.instance.shareDocument(docs[i]),
        onRename: () => _renameDialog(context, docs[i]),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, DocumentModel doc) async {
    final vault = context.read<VaultProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
        ),
        title: const Text('Delete file?'),
        content: Text('Delete "${doc.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.hotPink)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vault.deleteDocument(doc);
    }
  }

  Future<void> _renameDialog(BuildContext context, DocumentModel doc) async {
    final vault = context.read<VaultProvider>();
    final ctrl = TextEditingController(text: doc.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
        ),
        title: const Text('Rename File'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'File name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text('Rename',
                style: TextStyle(color: AppColors.electricYellow)),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await vault.renameDocument(doc, newName);
    }
  }

  Widget _buildFab(Color color) {
    return GestureDetector(
      onTap: _showAddOptions,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), offset: const Offset(4, 4))],
          border: Border.all(color: AppColors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Icon(
          Icons.add,
          color: color.computeLuminance() > 0.4 ? AppColors.black : AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentModel doc;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onRename;

  const _DocumentTile({
    required this.doc,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onShare,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [AppTheme.neoShadow(AppColors.electricBlue.withOpacity(0.4))],
        ),
        child: Row(
          children: [
            _FileTypeIcon(doc: doc),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        doc.fileSizeBytes.readableSize,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: AppColors.mutedGrey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        doc.createdAt.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              color: AppColors.surface,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: AppColors.border),
              ),
              onSelected: (v) {
                if (v == 'share') onShare();
                if (v == 'rename') onRename();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(children: [
                    Icon(Icons.share_outlined, size: 18, color: AppColors.electricCyan),
                    SizedBox(width: 8),
                    Text('Share'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Rename'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.hotPink),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.hotPink)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: (index * 40).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.05, end: 0),
    );
  }
}

class _FileTypeIcon extends StatelessWidget {
  final DocumentModel doc;
  const _FileTypeIcon({required this.doc});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (doc.isImage) {
      color = AppColors.electricCyan;
      icon = Icons.image_outlined;
    } else if (doc.isPdf) {
      color = AppColors.hotPink;
      icon = Icons.picture_as_pdf_outlined;
    } else {
      color = AppColors.electricYellow;
      icon = Icons.insert_drive_file_outlined;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _AddFileSheet extends StatelessWidget {
  final VoidCallback onPickFiles;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _AddFileSheet({
    required this.onPickFiles,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
          left: BorderSide(color: AppColors.border, width: 1.5),
          right: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
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
          Text('Add Files', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.folder_outlined,
            color: AppColors.electricYellow,
            title: 'Browse Files',
            subtitle: 'PDF, Images from your device',
            onTap: () {
              Navigator.of(context).pop();
              onPickFiles();
            },
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.camera_alt_outlined,
            color: AppColors.electricCyan,
            title: 'Camera',
            subtitle: 'Take a photo',
            onTap: () {
              Navigator.of(context).pop();
              onCamera();
            },
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.photo_library_outlined,
            color: AppColors.neonGreen,
            title: 'Gallery',
            subtitle: 'Choose from photos',
            onTap: () {
              Navigator.of(context).pop();
              onGallery();
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(color: AppColors.mutedGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
          ],
        ),
      ),
    );
  }
}
