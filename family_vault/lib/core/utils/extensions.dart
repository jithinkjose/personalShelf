import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  bool get isStrongPassword => length >= 6;
}

extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('dd MMM yyyy').format(this);
  String get formattedWithTime => DateFormat('dd MMM yyyy, HH:mm').format(this);
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

extension FileSizeExtensions on int {
  String get readableSize {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

extension ColorExtensions on Color {
  Color get onColor {
    final luminance = computeLuminance();
    return luminance > 0.4 ? AppColors.black : AppColors.white;
  }

  Color get darkened {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}

extension FileExtension on File {
  String get extension => path.split('.').last.toLowerCase();
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(extension);
  bool get isPdf => extension == 'pdf';
  bool get isVideo => ['mp4', 'mov', 'avi'].contains(extension);
}
