import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
import '../../../../routing/route_paths.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All Masterclasses';

  static const List<Map<String, dynamic>> _categoryFilters = [
    {'name': 'All Masterclasses', 'emoji': '✨', 'count': 24},
    {'name': 'Sound & 432Hz Gong', 'emoji': '🥣'},
    {'name': 'Herbal Formulary & DIY', 'emoji': '🌿'},
    {'name': 'Sacred Vastu & Grids', 'emoji': '📐'},
    {'name': 'Bach Emotional Healing', 'emoji': '🌸'},
    {'name': 'Kundalini & Breath', 'emoji': '🧘'},
  ];

  void _openMapLocation(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _navigateToBooking({
    required String title,
    required String instructor,
    required String lineage,
    required double basePrice,
    required double discount,
    required String image,
  }) {
    context.push(
      RoutePaths.workshopBooking,
      extra: {
        'title': title,
        'instructor': instructor,
        'lineage': lineage,
        'basePrice': basePrice,
        'discount': discount,
        'image': image,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MembershipAccessGuard(
      featureName: 'Creative Workshops & Masterclasses',
      featureDescription: 'Immersive certified workshops led by revered masters',
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: const CustomAppBar(title: 'Workshops & Masterclasses'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP EYEBROW ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDDCFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9C3E00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '✨ CONSECRATED LIVING SESSIONS',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF280253),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF9C3E00)),
                      const SizedBox(width: 4),
                      Text(
                        'Vedic Certified',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9C3E00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. MAIN TITLE & WELCOMING PITCH
              RichText(
                text: TextSpan(
                  style: GoogleFonts.epilogue(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF171C24),
                    height: 1.25,
                  ),
                  children: [
                    const TextSpan(text: 'Creative Workshops & '),
                    TextSpan(
                      text: 'Sacred ',
                      style: GoogleFonts.newsreader(
                        color: const Color(0xFF0F8548),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: 'Masterclasses'),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Immersive hands-on certified workshops led by revered masters in Ayurveda, Sound Frequencies, Vastu Architecture, and Drugless Healing.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF3E4A40),
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 14),

              // 3. SEARCH & FILTER BAR
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF0F8548), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim().toLowerCase());
                        },
                        style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF171C24)),
                        decoration: InputDecoration(
                          hintText: 'Search workshops, Vedic masterclasses...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 18),
                      )
                    else
                      const Icon(Icons.mic_rounded, color: Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F8548),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. HORIZONTAL CATEGORY FILTER PILLS
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categoryFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _categoryFilters[index];
                    final name = item['name'] as String;
                    final emoji = item['emoji'] as String;
                    final count = item['count'] as int?;
                    final isSelected = _selectedCategoryFilter == name;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryFilter = name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0F8548) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0F8548) : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0F8548).withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Text(
                              count != null ? '$name ($count)' : name,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF171C24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 5. FEATURED LIVE HERO MASTERCLASS CARD
              _buildFeaturedHeroMasterclass(),

              const SizedBox(height: 16),

              // 6. MICRO-PERKS RIBBON (2x2 GRID)
              _buildMicroPerksGrid(),

              const SizedBox(height: 20),

              // 7. SECTION HEADER: UPCOMING SACRED COHORTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Sacred Cohorts',
                        style: GoogleFonts.epilogue(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF171C24),
                        ),
                      ),
                      Text(
                        'Handcrafted practical modules for daily transformation',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View Schedule',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F8548),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF0F8548)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 8. UPCOMING SACRED COHORT CARDS
              _buildCohortCard1(),
              const SizedBox(height: 16),
              _buildCohortCard2(),
              const SizedBox(height: 16),
              _buildCohortCard3(),

              const SizedBox(height: 20),

              // 9. GRADUATE TESTIMONIAL CARD
              _buildTestimonialCard(),

              const SizedBox(height: 16),

              // 10. SATVIK GUARANTEE FOOTER CALLOUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F8548),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.spa_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Satvik & Drugless Pledge',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF171C24),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All sessions follow ancient authentic lineages without synthetic commercial shortcuts.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF3E4A40),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // FEATURED LIVE HERO CARD
  Widget _buildFeaturedHeroMasterclass() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MEDIA HEADER
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorWidget: (ctx, err, stack) => Container(
                      color: const Color(0xFF1E1B4B),
                      child: const Icon(Icons.music_note_rounded, size: 50, color: Colors.amberAccent),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xDD0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // LIVE PULSING BADGE (Top-Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE IN 25 MINS • 142 JOINED',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 528Hz FREQUENCY TAG (Top-Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E4F9A).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.graphic_eq_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '528Hz Live Feed',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // MASTER PROFILE FLOATING BADGE (Bottom)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.amberAccent,
                              child: Icon(Icons.person_rounded, color: Color(0xFF1E1B4B), size: 20),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Acharya Devraj',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified_rounded, color: Colors.amber, size: 14),
                                  ],
                                ),
                                Text(
                                  '35 Yrs Sacred Sound Lineage',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '90 Mins',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENT CONTAINER
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BANNER CHIP INSIDE CARD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_outlined, size: 15, color: Color(0xFF0F8548)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Virtual Live (Interactive 4K Stream via Zoom + Consecrated Kit Delivery)',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // WORKSHOP TITLE
                Text(
                  'Sacred Himalayan Singing Bowl Sound Bath & Prana Cleansing',
                  style: GoogleFonts.epilogue(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                // TAG CHIPS ROW
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTagChip('🎧 Audio Frequency', const Color(0xFFDCFCE7), const Color(0xFF166534)),
                    _buildTagChip('🎁 Consecrated Kit Included', const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),
                    _buildTagChip('🤚 Hands-on Guided DIY', const Color(0xFFFFEDD5), const Color(0xFF9A3412)),
                  ],
                ),

                const SizedBox(height: 12),

                // SEAT CAPACITY & PROGRESS BAR
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.airline_seat_recline_normal_rounded,
                                  size: 16, color: Color(0xFF0F8548)),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '142 / 180 Seats Reserved ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '• 38 Seats Remaining',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '⚡ Fast Filling • 79% Booked',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFC2410C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0.79,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SCHEDULE & REGISTERED ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF0F8548)),
                        const SizedBox(width: 6),
                        Text(
                          'Today, 6:30 PM IST',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 22,
                          child: Stack(
                            children: const [
                              Positioned(
                                left: 0,
                                child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Color(0xFF22C55E),
                                    child: Text('SN', style: TextStyle(fontSize: 8, color: Colors.white))),
                              ),
                              Positioned(
                                left: 14,
                                child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Color(0xFFA855F7),
                                    child: Text('RK', style: TextStyle(fontSize: 8, color: Colors.white))),
                              ),
                              Positioned(
                                left: 28,
                                child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Color(0xFF3B82F6),
                                    child: Text('TL', style: TextStyle(fontSize: 8, color: Colors.white))),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+138 registered',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // PRICING & RESERVE ACTION BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹1,299',
                              style: GoogleFonts.epilogue(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹2,499',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '48% Inaugural Gift',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigateToBooking(
                          title: 'Sacred Himalayan Singing Bowl Sound Bath & Prana Cleansing',
                          instructor: 'Acharya Devraj',
                          lineage: '35 Yrs Sacred Sound Lineage',
                          basePrice: 2499.0,
                          discount: 1200.0,
                          image:
                              'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=800&auto=format&fit=crop',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F8548),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.electric_bolt_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Reserve Live Seat',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MICRO-PERKS RIBBON (2x2 GRID)
  Widget _buildMicroPerksGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPerkTile(
                icon: Icons.workspace_premium_rounded,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF166534),
                title: 'Dual Certification',
                subtitle: 'ISO & Vedic Board...',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPerkTile(
                icon: Icons.unarchive_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF6B21A8),
                title: 'Lab Material Box',
                subtitle: 'Shipped to door...',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPerkTile(
                icon: Icons.ondemand_video_rounded,
                iconBg: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFF9A3412),
                title: 'Lifetime Recording',
                subtitle: '4K Studio + PDF ...',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPerkTile(
                icon: Icons.forum_rounded,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0369A1),
                title: 'Private Cohort Group',
                subtitle: 'Direct Guru Q&A...',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerkTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPCOMING SACRED COHORT 1 (VEDIC HERBALISM)
  Widget _buildCohortCard1() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP PILLS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTagChip('🍃 Weekend Intensive', const Color(0xFFDCFCE7), const Color(0xFF166534)),
              _buildTagChip('Only 6 Seats Left!', const Color(0xFFFFE4E6), const Color(0xFFE11D48)),
            ],
          ),
          const SizedBox(height: 6),
          _buildTagChip('📍 Offline Sanctuary Masterclass', const Color(0xFFFFEDD5), const Color(0xFFC2410C)),

          const SizedBox(height: 12),

          // INSET IMAGE & DETAILS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=300&auto=format&fit=crop',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, stack) => Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFF0F8548),
                    child: const Icon(Icons.eco_rounded, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vedic Herbalism: Crafting Custom...',
                      style: GoogleFonts.epilogue(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By Vaidya Ananya Sen • Formulator',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // LOCATION BOX
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFFC2410C)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Sanctuary Venue: Bee Beyonnd Ashram, 14 Lotus Pavilion Road, Indiranagar, Bengaluru, 560038',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _openMapLocation(
                      'Bee Beyonnd Ashram 14 Lotus Pavilion Road Indiranagar Bengaluru'),
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded, size: 13, color: Color(0xFF0F8548)),
                      const SizedBox(width: 4),
                      Text(
                        'View on Map ↗',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F8548),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // SEAT CAPACITY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.airline_seat_recline_normal_rounded, size: 15, color: Color(0xFFE11D48)),
                  const SizedBox(width: 6),
                  Text(
                    '19 / 25 Seats Reserved',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  Text(
                    ' • Only 6 Seats Left!',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFE11D48)),
                  ),
                ],
              ),
              Text(
                '76% Full',
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.76,
              minHeight: 5,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE11D48)),
            ),
          ),

          const SizedBox(height: 12),

          // BULLET HIGHLIGHTS
          _buildBulletHighlight(Icons.local_shipping_outlined, 'Physical DIY Herb Box Delivered to Doorstep'),
          const SizedBox(height: 4),
          _buildBulletHighlight(Icons.verified_outlined, 'Govt Recognized Ayurveda Certification'),
          const SizedBox(height: 4),
          _buildBulletHighlight(Icons.calendar_month_outlined, 'Sat, 14 Nov • 2-Day Masterclass'),

          const SizedBox(height: 14),

          // FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee with Herb Kit',
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    '₹3,450',
                    style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToBooking(
                    title: 'Vedic Herbalism: Crafting Custom Formulations',
                    instructor: 'Vaidya Ananya Sen',
                    lineage: 'Ayurvedic Formulator',
                    basePrice: 4500.0,
                    discount: 1050.0,
                    image:
                        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=300&auto=format&fit=crop',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F8548),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Text('Book Offline Seat', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPCOMING SACRED COHORT 2 (VASTU SACRED GEOMETRY)
  Widget _buildCohortCard2() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTagChip('🧘 Spatial Healing & Energy', const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
              _buildTagChip('Sun, 18 Nov • 4 Hrs', const Color(0xFFF1F5F9), const Color(0xFF475569)),
            ],
          ),
          const SizedBox(height: 6),
          _buildTagChip('📍 Offline Weekend Retreat', const Color(0xFFFFEDD5), const Color(0xFFC2410C)),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=300&auto=format&fit=crop',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, stack) => Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFF7E22CE),
                    child: const Icon(Icons.grid_on_rounded, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vastu Sacred Geometry & Yantra Consecration...',
                      style: GoogleFonts.epilogue(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By Dr. Vedant Sharma • Sacred Architect',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF7E22CE)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Bee Beyonnd Divine Center, 77 Prana Vista, Sector 44, Gurugram, NCR 122003',
                        style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF334155), height: 1.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _openMapLocation('Bee Beyonnd Divine Center 77 Prana Vista Sector 44 Gurugram'),
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded, size: 13, color: Color(0xFF7E22CE)),
                      const SizedBox(width: 4),
                      Text(
                        'View on Map ↗',
                        style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF7E22CE)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.airline_seat_recline_normal_rounded, size: 15, color: Color(0xFF7E22CE)),
                  const SizedBox(width: 6),
                  Text('22 / 30 Seats Reserved', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text(' • 8 Seats Remaining', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF7E22CE))),
                ],
              ),
              Text('73% Full', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.73,
              minHeight: 5,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E22CE)),
            ),
          ),

          const SizedBox(height: 12),

          _buildBulletHighlight(Icons.home_outlined, 'Live Personal House-Plan Diagnostic Session'),
          const SizedBox(height: 4),
          _buildBulletHighlight(Icons.auto_awesome_outlined, 'Handcrafted Brass Yantra Kit & Dowsing Grid'),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Investment', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  Text('₹2,800', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToBooking(
                    title: 'Vastu Sacred Geometry & Yantra Consecration',
                    instructor: 'Dr. Vedant Sharma',
                    lineage: 'Sacred Architect',
                    basePrice: 3500.0,
                    discount: 700.0,
                    image:
                        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=300&auto=format&fit=crop',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E22CE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Text('Book Workshop', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPCOMING SACRED COHORT 3 (BACH FLOWER)
  Widget _buildCohortCard3() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTagChip('🧠 Drugless Mind Therapy', const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
              _buildTagChip('Thu, 22 Nov • Evening', const Color(0xFFF1F5F9), const Color(0xFF475569)),
            ],
          ),
          const SizedBox(height: 6),
          _buildTagChip('🌐 Virtual Live Cohort (Global Interactive Studio)', const Color(0xFFDCFCE7), const Color(0xFF15803D)),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1512290900673-70024fe74923?q=80&w=300&auto=format&fit=crop',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, stack) => Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFF0369A1),
                    child: const Icon(Icons.local_florist_rounded, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bach Flower Emotional Rescue & Pendulum...',
                      style: GoogleFonts.epilogue(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By Meera Singhania • Certified Therapist',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.airline_seat_recline_normal_rounded, size: 15, color: Color(0xFF0F8548)),
                  const SizedBox(width: 6),
                  Text('41 / 50 Seats Reserved', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text(' • 9 Seats Remaining', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F8548))),
                ],
              ),
              Text('82% Full', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.82,
              minHeight: 5,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F8548)),
            ),
          ),

          const SizedBox(height: 12),

          _buildBulletHighlight(Icons.psychology_outlined, '1-on-1 Emotional Triad Mapping & Diagnosis'),
          const SizedBox(height: 4),
          _buildBulletHighlight(Icons.water_drop_outlined, 'Personal Custom Rescue Blend Shipped Free'),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cohort Fee', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  Text('₹1,850', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToBooking(
                    title: 'Bach Flower Emotional Rescue & Pendulum Diagnosis',
                    instructor: 'Meera Singhania',
                    lineage: 'Certified Therapist',
                    basePrice: 2500.0,
                    discount: 650.0,
                    image:
                        'https://images.unsplash.com/photo-1512290900673-70024fe74923?q=80&w=300&auto=format&fit=crop',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F8548),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Text('Book Workshop', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GRADUATE TESTIMONIAL CARD
  Widget _buildTestimonialCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                ),
              ),
              _buildTagChip('Verified Graduate', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '“The Gong & 528Hz Sound workshop shifted my chronic sleep cycle within 3 days. The consecrated brass bowl sent to my home has transformed our entire evening prayer altar. Truly sacred work.”',
            style: GoogleFonts.newsreader(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFF3E8FF),
                child: Text('SK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suniti Krishnan',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  Text(
                    'Sound Healing Masterclass • Bangalore',
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildBulletHighlight(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0F8548)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
