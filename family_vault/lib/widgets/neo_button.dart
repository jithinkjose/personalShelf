import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum NeoButtonStyle { primary, secondary, danger, ghost }

class NeoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final NeoButtonStyle style;
  final bool loading;
  final IconData? icon;
  final double? width;
  final double height;

  const NeoButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = NeoButtonStyle.primary,
    this.loading = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  const NeoButton.primary({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
    this.width,
    this.height = 56,
  }) : style = NeoButtonStyle.primary;

  const NeoButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
    this.width,
    this.height = 56,
  }) : style = NeoButtonStyle.secondary;

  const NeoButton.danger({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
    this.width,
    this.height = 56,
  }) : style = NeoButtonStyle.danger;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _offsetAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bg {
    switch (widget.style) {
      case NeoButtonStyle.primary: return AppColors.electricYellow;
      case NeoButtonStyle.secondary: return AppColors.surface;
      case NeoButtonStyle.danger: return AppColors.hotPink;
      case NeoButtonStyle.ghost: return Colors.transparent;
    }
  }

  Color get _fg {
    switch (widget.style) {
      case NeoButtonStyle.primary: return AppColors.black;
      case NeoButtonStyle.secondary: return AppColors.white;
      case NeoButtonStyle.danger: return AppColors.white;
      case NeoButtonStyle.ghost: return AppColors.white;
    }
  }

  Color get _shadow {
    switch (widget.style) {
      case NeoButtonStyle.primary: return AppColors.electricBlue;
      case NeoButtonStyle.secondary: return AppColors.mutedGrey;
      case NeoButtonStyle.danger: return AppColors.electricPurple;
      case NeoButtonStyle.ghost: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.loading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => _controller.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onTap?.call();
            },
      onTapCancel: () => _controller.reverse(),
      child: SlideTransition(
        position: _offsetAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: disabled ? _bg.withOpacity(0.5) : _bg,
            border: Border.all(
              color: widget.style == NeoButtonStyle.ghost
                  ? AppColors.border
                  : AppColors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: disabled || widget.style == NeoButtonStyle.ghost
                ? []
                : [AppTheme.neoShadow(_shadow)],
          ),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: _fg, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: _fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
