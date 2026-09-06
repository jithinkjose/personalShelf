import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class NeoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borderColor;
  final Color? shadowColor;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final bool animated;

  const NeoCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    this.shadowColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.animated = true,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shadow = widget.shadowColor ?? AppColors.electricBlue;
    final border = widget.borderColor ?? AppColors.border;
    final bg = widget.backgroundColor ?? AppColors.surface;

    return GestureDetector(
      onTapDown: widget.animated && widget.onTap != null
          ? (_) => _controller.forward()
          : null,
      onTapUp: widget.animated && widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      onTap: !widget.animated ? widget.onTap : null,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1.5),
            boxShadow: widget.onTap != null
                ? [AppTheme.neoShadow(shadow)]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
