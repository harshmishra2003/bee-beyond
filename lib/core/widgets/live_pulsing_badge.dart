import 'package:flutter/material.dart';

class LivePulsingBadge extends StatefulWidget {
  final double fontSize;
  final EdgeInsets padding;

  const LivePulsingBadge({
    super.key,
    this.fontSize = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
  });

  @override
  State<LivePulsingBadge> createState() => _LivePulsingBadgeState();
}

class _LivePulsingBadgeState extends State<LivePulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnim = ColorTween(
      begin: const Color(0xFFE11D48), // Vibrant Rose Red
      end: const Color(0xFFF59E0B), // Glowing Amber
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentColor = _colorAnim.value ?? const Color(0xFFE11D48);

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentColor.withAlpha(180),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: currentColor.withAlpha(90),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing Glowing Ball Indicator
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: currentColor,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),

              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
