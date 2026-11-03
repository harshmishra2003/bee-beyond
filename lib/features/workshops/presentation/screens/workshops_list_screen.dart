import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/workshop_item.dart';
import '../providers/workshop_provider.dart';

class WorkshopsListScreen extends ConsumerStatefulWidget {
  const WorkshopsListScreen({super.key});

  @override
  ConsumerState<WorkshopsListScreen> createState() => _WorkshopsListScreenState();
}

class _WorkshopsListScreenState extends ConsumerState<WorkshopsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workshopsAsync = ref.watch(workshopsByCategoryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Workshops & Masterclasses'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allWorkshopsProvider);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER BANNER
              _buildHeaderBanner(),

              const SizedBox(height: 16),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search workshops, mentors, topics...',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textHint),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CATEGORY CHIPS
              ref.watch(allWorkshopsProvider).maybeWhen(
                data: (allList) => _buildCategorySelector(selectedCategory, allList),
                orElse: () => _buildCategorySelector(selectedCategory, []),
              ),

              const SizedBox(height: 20),

              // WORKSHOPS DATA PRESENTATION
              workshopsAsync.when(
                skipLoadingOnRefresh: true,
                data: (workshops) {
                  final filtered = workshops.where((w) {
                    if (_searchQuery.isEmpty) return true;
                    return w.title.toLowerCase().contains(_searchQuery) ||
                        w.instructor.toLowerCase().contains(_searchQuery) ||
                        w.category.toLowerCase().contains(_searchQuery) ||
                        w.description.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  final liveMasterclasses = filtered.where((w) => w.isLive).toList();
                  final videoWorkshops = filtered.where((w) => !w.isLive).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LIVE & UPCOMING SECTION
                      if (liveMasterclasses.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const _BlinkingLiveDot(),
                              const SizedBox(width: 8),
                              const Text(
                                'LIVE Interactive Masterclasses',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: liveMasterclasses.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildWorkshopCard(liveMasterclasses[index]);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // RECORDED VIDEO WORKSHOPS SECTION
                      if (videoWorkshops.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Row(
                            children: [
                              Icon(Icons.ondemand_video_rounded, color: Color(0xFF6366F1), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Guided Video Workshops',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: videoWorkshops.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildWorkshopCard(videoWorkshops[index]);
                          },
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (err, stack) => _buildErrorState(err.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C20), Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACCREDITED MASTERCLASSES',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Transformative Holistic Workshops',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Immersive live & recorded certified workshops led by revered masters in Sound Frequency, Vastu, Ayurveda & Life Coaching.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFC7D2FE),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(String selectedCategory, List<WorkshopItem> allWorkshops) {
    final categoriesSet = <String>{'All'};
    for (final item in allWorkshops) {
      if (item.category.trim().isNotEmpty) {
        categoriesSet.add(item.category.trim());
      }
    }
    final categories = categoriesSet.toList();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;

          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                ref.read(selectedCategoryProvider.notifier).state = cat;
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              ),
            ),
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          );
        },
      ),
    );
  }

  Widget _buildWorkshopCard(WorkshopItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E1B5B), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2E1B5B),
            blurRadius: 14,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item.isRegistered
              ? null
              : () {
                  if (item.isFull) {
                    AppAlertManager.showFloatingToast(
                      context,
                      title: 'Capacity Full',
                      message: 'This masterclass is currently at full capacity.',
                      icon: Icons.event_seat_rounded,
                      accentColor: const Color(0xFFF59E0B),
                    );
                  } else {
                    context.push(
                      RoutePaths.workshopBooking,
                      extra: item.toJson(),
                    );
                  }
                },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // THUMBNAIL (FULL-WIDTH BEAUTIFUL COVER IMAGE WITHOUT TEXT OVERLAYS)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: item.thumbnailUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.thumbnailUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: const Color(0xFF1E1B4B),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              size: 52,
                              color: Colors.amber,
                            ),
                          ),
                        )
                      : Container(
                          height: 180,
                          color: const Color(0xFF1E1B4B),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 52,
                            color: Colors.amber,
                          ),
                        ),
                ),
              ),

              // CONTENT
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Mentor: ${item.instructor}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (item.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // DIGITAL CLOCK COUNTDOWN BANNER (DAYS + HOURS + MINUTES + SECONDS)
                    _DigitalCountdownClock(workshopId: item.id),

                    const SizedBox(height: 10),

                    // KEY STATS ROW WITH ANIMATED ANALOGUE CLOCK, BLINKING ENROLLED & SEATS ICONS
                    Row(
                      children: [
                        const _AnimatedAnalogueClockIcon(),
                        const SizedBox(width: 4),
                        Text(
                          item.duration,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _BlinkingEnrolledBadge(),
                        const SizedBox(width: 4),
                        Text(
                          '${item.bookedSeats > 0 ? item.bookedSeats : item.views} Enrolled',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _BlinkingSeatsIcon(),
                        const SizedBox(width: 4),
                        Text(
                          '${item.availableSeats} Seats Left',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFD97706),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    // PRICE & ACTION BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.discount > 0)
                              Text(
                                CurrencyUtils.formatINR(item.basePrice),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              CurrencyUtils.formatINR(item.finalPrice),
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: item.isRegistered
                              ? null
                              : () {
                                  if (item.isFull) {
                                    AppAlertManager.showFloatingToast(
                                      context,
                                      title: 'Capacity Full',
                                      message: 'This masterclass is currently at full capacity.',
                                      icon: Icons.event_seat_rounded,
                                      accentColor: const Color(0xFFF59E0B),
                                    );
                                  } else {
                                    context.push(
                                      RoutePaths.workshopBooking,
                                      extra: item.toJson(),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.isRegistered
                                ? const Color(0xFF10B981)
                                : (item.isFull ? const Color(0xFF94A3B8) : AppColors.primary),
                            disabledBackgroundColor: const Color(0xFF10B981),
                            disabledForegroundColor: Colors.white,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: item.isRegistered ? 0 : 1,
                          ),
                          child: Text(
                            item.isRegistered
                                ? '✓ Booked'
                                : (item.isFull ? 'Full' : 'Book Now'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: AppColors.textHint),
            SizedBox(height: 12),
            Text(
              'No Workshops Found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your search query or category filters.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Failed to load workshops',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(allWorkshopsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingLiveDot extends StatefulWidget {
  const _BlinkingLiveDot();

  @override
  State<_BlinkingLiveDot> createState() => _BlinkingLiveDotState();
}

class _BlinkingLiveDotState extends State<_BlinkingLiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFEF4444).withValues(alpha: 0.3),
              const Color(0xFFEF4444),
              _animation.value,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: _animation.value * 0.7),
                blurRadius: 6 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// REAL-TIME DIGITAL CLOCK COUNTDOWN BANNER
// ─────────────────────────────────────────────
class _DigitalCountdownClock extends StatefulWidget {
  final String workshopId;

  const _DigitalCountdownClock({required this.workshopId});

  @override
  State<_DigitalCountdownClock> createState() => _DigitalCountdownClockState();
}

class _DigitalCountdownClockState extends State<_DigitalCountdownClock> {
  late DateTime _targetEndTime;
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    final offsetHours = 38 + (widget.workshopId.hashCode.abs() % 54);
    _targetEndTime = DateTime.now().add(Duration(hours: offsetHours));
    _updateRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateRemaining();
      }
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = _targetEndTime.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays.toString().padLeft(2, '0');
    final hours = (_remaining.inHours % 24).toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0C20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.65),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_rounded, size: 14, color: Color(0xFFF59E0B)),
              SizedBox(width: 5),
              Text(
                'CLOSING IN:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF59E0B),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildDigitalSegment(days, 'd'),
              _buildDigitalColon(),
              _buildDigitalSegment(hours, 'h'),
              _buildDigitalColon(),
              _buildDigitalSegment(minutes, 'm'),
              _buildDigitalColon(),
              _buildDigitalSegment(seconds, 's'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalSegment(String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.amberAccent,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.amberAccent,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED ROTATING ANALOGUE CLOCK ICON
// ─────────────────────────────────────────────
class _AnimatedAnalogueClockIcon extends StatefulWidget {
  const _AnimatedAnalogueClockIcon();

  @override
  State<_AnimatedAnalogueClockIcon> createState() => _AnimatedAnalogueClockIconState();
}

class _AnimatedAnalogueClockIconState extends State<_AnimatedAnalogueClockIcon>
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
      child: const Icon(
        Icons.access_time_rounded,
        size: 14,
        color: AppColors.primary,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BLINKING SEATS AVAILABILITY ICON
// ─────────────────────────────────────────────
class _BlinkingSeatsIcon extends StatefulWidget {
  const _BlinkingSeatsIcon();

  @override
  State<_BlinkingSeatsIcon> createState() => _BlinkingSeatsIconState();
}

class _BlinkingSeatsIconState extends State<_BlinkingSeatsIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.25, end: 1.0).animate(
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
    return FadeTransition(
      opacity: _opacityAnimation,
      child: const Icon(
        Icons.event_seat_rounded,
        size: 14,
        color: Color(0xFFD97706),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BLINKING ENROLLED REPRESENTATION BADGE
// ─────────────────────────────────────────────
class _BlinkingEnrolledBadge extends StatefulWidget {
  const _BlinkingEnrolledBadge();

  @override
  State<_BlinkingEnrolledBadge> createState() => _BlinkingEnrolledBadgeState();
}

class _BlinkingEnrolledBadgeState extends State<_BlinkingEnrolledBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: const Icon(
        Icons.groups_rounded,
        size: 14,
        color: Color(0xFF4338CA),
      ),
    );
  }
}
