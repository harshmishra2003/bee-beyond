import 'package:flutter/material.dart';

/// A 3D "View All" Button featuring a continuous periodic shining glint light beam animation
class ShiningViewAllButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const ShiningViewAllButton({
    super.key,
    required this.onPressed,
    this.text = 'View All',
  });

  @override
  State<ShiningViewAllButton> createState() => _ShiningViewAllButtonState();
}

class _ShiningViewAllButtonState extends State<ShiningViewAllButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shineAnimation = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _startShineLoop();
  }

  void _startShineLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1800));
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 3.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF1E1B4B),
                    offset: Offset(0, 3.5),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x3B000000),
                    offset: Offset(0, 5),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Button Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: Color(0xFF312E81),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10.5,
                      color: Color(0xFF312E81),
                    ),
                  ],
                ),
              ),

              // Dynamic Periodic Shining Glint Light Beam
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _shineAnimation,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: Offset(_shineAnimation.value, 0),
                        child: Transform.rotate(
                          angle: 0.4,
                          child: Container(
                            width: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.95),
                                  Colors.amberAccent.withValues(alpha: 0.7),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.4, 0.6, 1.0],
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
    );
  }
}
