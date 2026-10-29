import 'dart:async';
import 'package:flutter/material.dart';

class DigitalClockCountdown extends StatefulWidget {
  final DateTime targetDate;
  final String label;

  const DigitalClockCountdown({
    super.key,
    required this.targetDate,
    this.label = 'COURSE STARTS IN',
  });

  @override
  State<DigitalClockCountdown> createState() => _DigitalClockCountdownState();
}

class _DigitalClockCountdownState extends State<DigitalClockCountdown>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late Duration _remaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _calculateRemaining();
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final diff = widget.targetDate.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isUrgent => _remaining.inHours < 24 && _remaining.inSeconds > 0;

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final mins = _remaining.inMinutes.remainder(60);
    final secs = _remaining.inSeconds.remainder(60);

    // Urgent color scheme when remaining < 24 hours
    final mainColor = _isUrgent ? const Color(0xFFEF4444) : const Color(0xFF312E81);
    final accentBg = _isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFEEF2FF);
    final borderColor = _isUrgent ? const Color(0xFFFCA5A5) : const Color(0xFFC7D2FE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: mainColor.withAlpha(_isUrgent ? 40 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Label with Pulsing Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isUrgent
                  ? ScaleTransition(
                      scale: _pulseAnim,
                      child: const Icon(
                        Icons.timer_sharp,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                    )
                  : const Icon(
                      Icons.access_time_filled_rounded,
                      color: Color(0xFF312E81),
                      size: 18,
                    ),
              const SizedBox(width: 6),
              Text(
                _isUrgent ? 'REGISTRATION CLOSING SOON!' : widget.label,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Digital Timer Blocks: Days : Hours : Mins : Secs
          _remaining.inSeconds == 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Text(
                    'BATCH IN PROGRESS • REGISTRATION CLOSED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeUnit(
                      value: days.toString().padLeft(2, '0'),
                      label: 'DAYS',
                      color: mainColor,
                    ),
                    _buildSeparator(mainColor),
                    _buildTimeUnit(
                      value: hours.toString().padLeft(2, '0'),
                      label: 'HOURS',
                      color: mainColor,
                    ),
                    _buildSeparator(mainColor),
                    _buildTimeUnit(
                      value: mins.toString().padLeft(2, '0'),
                      label: 'MINS',
                      color: mainColor,
                    ),
                    _buildSeparator(mainColor),
                    _buildTimeUnit(
                      value: secs.toString().padLeft(2, '0'),
                      label: 'SECS',
                      color: mainColor,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withAlpha(80),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(20),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color.withAlpha(200),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
