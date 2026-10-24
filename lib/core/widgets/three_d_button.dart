import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ThreeDButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color textColor;
  final Color? shadowColor;
  final double fontSize;
  final EdgeInsets padding;
  final double? width;
  final Widget? icon;

  const ThreeDButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor = Colors.white,
    this.shadowColor,
    this.fontSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
    this.width,
    this.icon,
  });

  @override
  State<ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<ThreeDButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = widget.shadowColor ?? const Color(0xFF2B285E);

    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.only(top: _isPressed ? 3.0 : 0.0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.color == null ? AppColors.button3DGradient : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: effectiveShadow,
                      offset: const Offset(0, 4.0),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      offset: const Offset(0, 6),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
