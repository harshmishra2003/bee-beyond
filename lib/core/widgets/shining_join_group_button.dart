import 'package:flutter/material.dart';

/// A button featuring a continuous periodic shining glint light beam animation
/// specifically designed for "Join Group" / "Study Group" action buttons in course cards.
class ShiningJoinGroupButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;
  final bool isLoading;
  final double borderRadius;

  const ShiningJoinGroupButton({
    super.key,
    required this.onPressed,
    this.text = 'Join Group',
    this.icon = Icons.groups_rounded,
    this.backgroundColor = const Color(0xFF25D366),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.fontSize = 10.5,
    this.iconSize = 13,
    this.isLoading = false,
    this.borderRadius = 8,
  });

  @override
  State<ShiningJoinGroupButton> createState() => _ShiningJoinGroupButtonState();
}

class _ShiningJoinGroupButtonState extends State<ShiningJoinGroupButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shineAnimation = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _startShineLoop();
  }

  void _startShineLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        await _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed();
            },
      onTapCancel: widget.isLoading ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.35),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Button Content
                Padding(
                  padding: widget.padding,
                  child: widget.isLoading
                      ? SizedBox(
                          height: widget.iconSize,
                          width: widget.iconSize,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.icon, size: widget.iconSize, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),

                // Periodic Shining Glint Light Beam Overlay
                if (!widget.isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return FractionalTranslation(
                            translation: Offset(_shineAnimation.value, 0),
                            child: Transform.rotate(
                              angle: 0.35,
                              child: Container(
                                width: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.9),
                                      Colors.amberAccent.withValues(alpha: 0.65),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.35, 0.65, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
