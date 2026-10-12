import 'package:flutter/material.dart';

class AnimatedClockIcon extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedClockIcon({
    super.key,
    this.size = 11.0,
    this.color = const Color(0xFF312E81),
  });

  @override
  State<AnimatedClockIcon> createState() => _AnimatedClockIconState();
}

class _AnimatedClockIconState extends State<AnimatedClockIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.schedule_rounded,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}
