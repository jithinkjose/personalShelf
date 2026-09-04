import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../data/models/document_model.dart';
import '../../data/services/encryption_service.dart';
import '../../data/services/file_service.dart';

class DocumentViewerScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _loading = true;
  String? _tmpPath;
  Uint8List? _imageBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _decryptFile();
  }

  @override
  void dispose() {
    // Clean up temp file
    if (_tmpPath != null) {
      FileService.instance.cleanTempFiles();
    }
    super.dispose();
  }

  Future<void> _decryptFile() async {
    try {
      final doc = widget.document;
      if (doc.isImage) {
        final bytes = await EncryptionService.instance.decryptFile(doc.encryptedPath);
        if (mounted) setState(() { _imageBytes = bytes; _loading = false; });
      } else {
        final path = await FileService.instance.decryptForViewing(doc);
        if (mounted) setState(() { _tmpPath = path; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to decrypt file.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.document.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => FileService.instance.shareDocument(widget.document),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: _buildInfo(),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.electricYellow),
            SizedBox(height: 16),
            Text('Decrypting file…', style: TextStyle(color: AppColors.mutedGrey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.hotPink, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.hotPink)),
          ],
        ),
      );
    }

    final doc = widget.document;

    if (doc.isImage && _imageBytes != null) {
      return PhotoView(
        imageProvider: MemoryImage(_imageBytes!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: AppColors.background),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(color: AppColors.electricYellow),
        ),
      );
    }

    if (doc.isPdf && _tmpPath != null) {
      return PDFView(
        filePath: _tmpPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        nightMode: true,
        backgroundColor: AppColors.background,
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 64, color: AppColors.mutedGrey),
          SizedBox(height: 12),
          Text('Preview not available for this file type.',
              style: TextStyle(color: AppColors.mutedGrey)),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final doc = widget.document;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doc.fileSizeBytes.readableSize,
                  style: const TextStyle(
                    color: AppColors.electricYellow,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Added ${doc.createdAt.formattedWithTime}',
                  style: const TextStyle(color: AppColors.mutedGrey, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => FileService.instance.shareDocument(doc),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.electricYellow,
                boxShadow: [AppTheme.neoShadow(AppColors.electricBlue)],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share_outlined, color: AppColors.black, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
