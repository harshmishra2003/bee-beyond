import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/course_entity.dart';
import 'live_course_card.dart';

class LiveCourseCarousel extends StatefulWidget {
  final List<CourseEntity> liveCourses;
  final Function(CourseEntity course) onCourseTap;
  final Function(CourseEntity course) onJoinNowTap;

  const LiveCourseCarousel({
    super.key,
    required this.liveCourses,
    required this.onCourseTap,
    required this.onJoinNowTap,
  });

  @override
  State<LiveCourseCarousel> createState() => _LiveCourseCarouselState();
}

class _LiveCourseCarouselState extends State<LiveCourseCarousel> {
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isReverse = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.liveCourses.length <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      const double stepWidth = 272.0; // card width 260 + margin 12

      if (!_isReverse) {
        if (currentScroll + stepWidth <= maxScroll + 10) {
          _scrollController.animateTo(
            currentScroll + stepWidth,
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _isReverse = true;
          _scrollController.animateTo(
            (currentScroll - stepWidth).clamp(0.0, maxScroll),
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastOutSlowIn,
          );
        }
      } else {
        if (currentScroll - stepWidth >= 0) {
          _scrollController.animateTo(
            currentScroll - stepWidth,
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _isReverse = false;
          _scrollController.animateTo(
            (currentScroll + stepWidth).clamp(0.0, maxScroll),
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.liveCourses.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 215,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.liveCourses.length,
        itemBuilder: (context, index) {
          final course = widget.liveCourses[index];

          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 12),
            child: LiveCourseCard(
              course: course,
              onTap: () => widget.onCourseTap(course),
              onJoinNow: () => widget.onJoinNowTap(course),
            ),
          );
        },
      ),
    );
  }
}
