import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/razorpay_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
import '../../../../core/widgets/status_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All Masterclasses';
  RazorpayService? _razorpayService;

  final Set<String> _bookedWorkshopIds = {};

  static const List<Map<String, dynamic>> _categoryFilters = [
    {'name': 'All Masterclasses', 'emoji': '✨', 'count': 24},
    {'name': 'Sound & 432Hz Gong', 'emoji': '🥣'},
    {'name': 'Herbal Formulary & DIY', 'emoji': '🌿'},
    {'name': 'Sacred Vastu & Grids', 'emoji': '📐'},
    {'name': 'Bach Emotional Healing', 'emoji': '🌸'},
    {'name': 'Kundalini & Breath', 'emoji': '🧘'},
  ];

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    super.dispose();
  }

  void _openMapLocation(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _processWorkshopBooking({
    required String workshopId,
    required String title,
    required double price,
    required String modeStr,
  }) {
    final user = ref.read(authStateProvider).user;
    final customerName = user?.name.isNotEmpty == true ? user!.name : 'Valued Seeker';
    final customerEmail = user?.email.isNotEmpty == true ? user!.email : 'support@beebeyonnd.in';
    final customerPhone = user?.phone.isNotEmpty == true ? user!.phone : '9999999999';

    _razorpayService?.onSuccess = (response) {
      if (!mounted) return;
      setState(() {
        _bookedWorkshopIds.add(workshopId);
      });

      StatusDialog.show(
        context,
        title: 'Seat Reserved Successfully! 🎟️',
        description:
            'Your registration for "$title" ($modeStr) is confirmed!\n\nCheck-in instructions and consecrated material box tracking details have been sent to your registered email.',
        isSuccess: true,
        actionText: 'VIEW MY BOOKINGS',
        onAction: () {},
      );
    };

    _razorpayService?.onError = (response) {
      if (!mounted) return;
      final isDismissed = response.code == Razorpay.PAYMENT_CANCELLED;
      StatusDialog.show(
        context,
        title: isDismissed ? 'Booking Cancelled' : 'Payment Failed',
        description: isDismissed
            ? 'Workshop booking was cancelled. No amount was debited.'
            : (response.message ?? 'Transaction declined. Please try again.'),
        isSuccess: false,
        actionText: 'OK',
        onAction: () {},
      );
    };

    final amountPaise = (price * 100).toInt();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    _razorpayService?.openCheckout(
      keyId: 'rzp_test_beebeeyond',
      amountPaise: amountPaise > 0 ? amountPaise : 129900,
      gatewayOrderId: 'order_workshop_$timestamp',
      name: 'Bee Beyonnd Sacred Masterclass',
      description: title,
      contact: customerPhone,
      email: customerEmail,
      customerName: customerName,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          '✨ Consecrated Living Sessions',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF280253),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 15, color: Color(0xFF9C3E00)),
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
                        color: AppColors.primary,
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
                  fontSize: 12.5,
                  color: const Color(0xFF3E4A40),
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 14),

              // 3. SEARCH & FILTER BAR
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim().toLowerCase());
                        },
                        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF171C24)),
                        decoration: InputDecoration(
                          hintText: 'Search workshops, Vedic masters, schedules...',
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
                  shrinkWrap: true,
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
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
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

              // 5. FEATURED LIVE INTERACTIVE MASTERCLASS (HERO CARD)
              _buildFeaturedHeroMasterclass(),

              const SizedBox(height: 16),

              // 6. MICRO-PERKS UTILITIES RIBBON (2x2 GRID)
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
                            color: AppColors.primary,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 8. UPCOMING WORKSHOP CARDS LIST
              _buildWorkshopCard1(),
              const SizedBox(height: 16),
              _buildWorkshopCard2(),
              const SizedBox(height: 16),
              _buildWorkshopCard3(),

              const SizedBox(height: 20),

              // 9. COMMUNITY SPOTLIGHT / GRADUATE TESTIMONIAL CARD
              _buildTestimonialCard(),

              const SizedBox(height: 16),

              // 10. SATVIK GUARANTEE FOOTER CALLOUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
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
    final isBooked = _bookedWorkshopIds.contains('ws_hero');

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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified_rounded, size: 13, color: Colors.amberAccent),
                                  ],
                                ),
                                Text(
                                  '35 Yrs Sacred Sound Lineage',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '90 Mins',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CARD BODY CONTENT
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MODE BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Virtual Live (Interactive 4K Stream via Zoom + Consecrated Kit Delivery)',
                              style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF171C24)),
                            ),
                            Text(
                              'Worldwide Access • Live 2-way Guru Q&A • HD Recording Included',
                              style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF3E4A40)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Sacred Himalayan Singing Bowl Sound Bath & Prana Cleansing',
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF171C24),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                // TAG PILLS
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTagPill('🎧 Audio Frequency', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                    _buildTagPill('📦 Consecrated Kit Included', const Color(0xFFEDDCFF), const Color(0xFF563781)),
                    _buildTagPill('🖐️ Hands-on Guided DIY', const Color(0xFFFFDBCB), const Color(0xFF7B2F00)),
                  ],
                ),

                const SizedBox(height: 12),

                // SEAT CAPACITY TRACKER
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.airline_seat_recline_extra_rounded, size: 15, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '142 / 180 Seats Reserved',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF171C24)),
                              ),
                              Text(
                                ' • 38 Seats Left',
                                style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDBCB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '⚡ Fast Filling • 79% Booked',
                              style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF7B2F00)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.79,
                          minHeight: 6,
                          backgroundColor: Color(0xFFDFE2EE),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // SCHEDULE & PRICE ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Today, 6:30 PM IST', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF3E4A40))),
                      ],
                    ),
                    Text('+138 registered', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              CurrencyUtils.formatINR(1299),
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF171C24)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              CurrencyUtils.formatINR(2499),
                              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                        Text('48% Inaugural Gift', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked ? const Color(0xFF059669) : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (!isBooked) {
                          _processWorkshopBooking(
                            workshopId: 'ws_hero',
                            title: 'Sacred Himalayan Singing Bowl Sound Bath',
                            price: 1299.0,
                            modeStr: 'Virtual Live 4K Stream',
                          );
                        }
                      },
                      icon: Icon(isBooked ? Icons.check_circle_rounded : Icons.bolt_rounded, color: Colors.amberAccent, size: 18),
                      label: Text(
                        isBookbookedText(isBooked, 'Reserve Live Seat'),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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

  // MICRO-PERKS GRID
  Widget _buildMicroPerksGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: [
        _buildMicroPerkItem(Icons.workspace_premium_rounded, 'Dual Certification', 'ISO & Vedic Board', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
        _buildMicroPerkItem(Icons.markunread_mailbox_rounded, 'Lab Material Box', 'Shipped to doorstep', const Color(0xFFEDDCFF), const Color(0xFF563781)),
        _buildMicroPerkItem(Icons.ondemand_video_rounded, 'Lifetime Recordings', '4K Studio + PDF Notes', const Color(0xFFFFDBCB), const Color(0xFF7B2F00)),
        _buildMicroPerkItem(Icons.forum_rounded, 'Private Cohort Circle', 'Direct Guru Q&A Room', const Color(0xFFDFE2EE), const Color(0xFF171C24)),
      ],
    );
  }

  Widget _buildMicroPerkItem(IconData icon, String title, String sub, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WORKSHOP CARD 1: VEDIC HERBALISM
  Widget _buildWorkshopCard1() {
    final isBooked = _bookedWorkshopIds.contains('ws_1');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  _buildTagPill('🌿 Weekend Intensive', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                  _buildTagPill('📍 Offline Sanctuary', const Color(0xFFFFDBCB), const Color(0xFF7B2F00)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(10)),
                child: Text('Only 6 Seats Left!', style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF93000A))),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=400&auto=format&fit=crop',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, stack) => Container(color: AppColors.primary, child: const Icon(Icons.eco_rounded, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vedic Herbalism: Crafting Custom Rasayanas & Botanical Elixirs',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF171C24)),
                    ),
                    const SizedBox(height: 4),
                    Text('By Vaidya Ananya Sen • Formulator', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // VENUE ADDRESS
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF9C3E00)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sanctuary Venue: Bee Beyonnd Ashram, Indiranagar, Bengaluru', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                      GestureDetector(
                        onTap: () => _openMapLocation('Bee Beyonnd Ashram, Indiranagar, Bengaluru'),
                        child: Text('🗺️ View on Map', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // SEAT CAPACITY TRACKER
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('💺 19 / 25 Seats Reserved • Only 6 Seats Left!', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF93000A))),
                    Text('76% Full', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.76, minHeight: 5, backgroundColor: Color(0xFFE2E8F0), color: Color(0xFF9C3E00)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fee with Herb Kit', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  Text(CurrencyUtils.formatINR(3450), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBooked ? const Color(0xFF059669) : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!isBooked) {
                    _processWorkshopBooking(
                      workshopId: 'ws_1',
                      title: 'Vedic Herbalism & Botanical Elixirs',
                      price: 3450.0,
                      modeStr: 'Offline Bengaluru Ashram',
                    );
                  }
                },
                icon: Icon(isBooked ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                label: Text(
                  isBookbookedText(isBooked, 'Book Offline Seat'),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WORKSHOP CARD 2: VASTU SACRED GEOMETRY
  Widget _buildWorkshopCard2() {
    final isBooked = _bookedWorkshopIds.contains('ws_2');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  _buildTagPill('📐 Spatial Healing', const Color(0xFFEDDCFF), const Color(0xFF563781)),
                  _buildTagPill('📍 Offline Retreat', const Color(0xFFD8BACC), const Color(0xFF563781)),
                ],
              ),
              Text('Sun, 18 Nov • 4 Hrs', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=400&auto=format&fit=crop',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, stack) => Container(color: const Color(0xFF6E4F9A), child: const Icon(Icons.architecture_rounded, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vastu Sacred Geometry & Yantra Consecration Workshop',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF171C24)),
                    ),
                    const SizedBox(height: 4),
                    Text('By Dr. Vedant Sharma • Sacred Architect', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // VENUE
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.pin_drop_rounded, size: 16, color: Color(0xFF6E4F9A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bee Beyonnd Divine Center, Sector 44, Gurugram, NCR', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                      GestureDetector(
                        onTap: () => _openMapLocation('Bee Beyonnd Divine Center, Sector 44, Gurugram'),
                        child: Text('🗺️ View on Map', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6E4F9A))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // SEAT CAPACITY TRACKER
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('💺 22 / 30 Seats Reserved • 8 Seats Remaining', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6E4F9A))),
                    Text('73% Full', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.73, minHeight: 5, backgroundColor: Color(0xFFE2E8F0), color: Color(0xFF6E4F9A)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Investment', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  Text(CurrencyUtils.formatINR(2800), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBooked ? const Color(0xFF059669) : const Color(0xFF6E4F9A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!isBooked) {
                    _processWorkshopBooking(
                      workshopId: 'ws_2',
                      title: 'Vastu Sacred Geometry & Yantra Consecration',
                      price: 2800.0,
                      modeStr: 'Offline Gurugram Retreat',
                    );
                  }
                },
                icon: Icon(isBooked ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                label: Text(
                  isBookbookedText(isBooked, 'Book Workshop'),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WORKSHOP CARD 3: BACH FLOWER
  Widget _buildWorkshopCard3() {
    final isBooked = _bookedWorkshopIds.contains('ws_3');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  _buildTagPill('🧠 Drugless Mind Therapy', const Color(0xFFEDDCFF), const Color(0xFF563781)),
                  _buildTagPill('🌐 Virtual Live Cohort', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                ],
              ),
              Text('Thu, 22 Nov • Evening', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1512290900673-700200411a7f?q=80&w=400&auto=format&fit=crop',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, stack) => Container(color: AppColors.primary, child: const Icon(Icons.local_florist_rounded, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bach Flower Emotional Rescue & Pendulum Dowsing Mastery',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF171C24)),
                    ),
                    const SizedBox(height: 4),
                    Text('By Meera Singhania • Certified Therapist', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // SEAT CAPACITY TRACKER
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('💺 41 / 50 Seats Reserved • 9 Seats Remaining', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('82% Full', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.82, minHeight: 5, backgroundColor: Color(0xFFE2E8F0), color: AppColors.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cohort Fee', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  Text(CurrencyUtils.formatINR(1850), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBooked ? const Color(0xFF059669) : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!isBooked) {
                    _processWorkshopBooking(
                      workshopId: 'ws_3',
                      title: 'Bach Flower Emotional Rescue & Dowsing',
                      price: 1850.0,
                      modeStr: 'Virtual Interactive Studio',
                    );
                  }
                },
                icon: Icon(isBooked ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                label: Text(
                  isBookbookedText(isBooked, 'Book Workshop'),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TESTIMONIAL CARD
  Widget _buildTestimonialCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (_) => const Icon(Icons.star_rounded, size: 18, color: Color(0xFFD97706))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                child: Text('Verified Graduate', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF15803D))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '“The Gong & 528Hz Sound workshop shifted my chronic sleep cycle within 3 days. The consecrated brass bowl sent to my home has transformed our entire evening prayer altar. Truly sacred work.”',
            style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF171C24), height: 1.45),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEDDCFF),
                child: Icon(Icons.person_rounded, size: 18, color: Color(0xFF563781)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suniti Krishnan', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF171C24))),
                  Text('Sound Healing Masterclass • Bangalore', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  String isBookbookedText(bool isBooked, String defaultText) {
    return isBooked ? 'SEAT RESERVED' : defaultText;
  }
}
