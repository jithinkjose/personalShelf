import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class NeoTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final int maxLines;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const NeoTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixWidget,
    this.maxLines = 1,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  bool _obscured = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.obscureText;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          boxShadow: _focused
              ? [AppTheme.neoShadow(AppColors.electricYellow)]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: isPassword && _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          autofocus: widget.autofocus,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.mutedGrey, size: 20)
                : null,
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.mutedGrey,
                      size: 20,
                    ),
                  )
                : widget.suffixWidget,
          ),
        ),
      ),
    );
  }
}
