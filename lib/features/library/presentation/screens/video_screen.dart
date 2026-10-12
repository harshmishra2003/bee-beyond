import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class VideoWorkshopItem {
  final String id;
  final String title;
  final String category;
  final String instructor;
  final String duration;
  final String views;
  final double rating;
  final String thumbnailUrl;
  final String description;
  final List<String> takeaways;
  final bool isFeatured;

  const VideoWorkshopItem({
    required this.id,
    required this.title,
    required this.category,
    required this.instructor,
    required this.duration,
    required this.views,
    required this.rating,
    required this.thumbnailUrl,
    required this.description,
    required this.takeaways,
    this.isFeatured = false,
  });

  String get categoryBadge {
    switch (category.toLowerCase()) {
      case 'bach flower':
        return '🌿 BACH FLOWER';
      case 'ayurveda':
        return '🎓 AYURVEDA';
      case 'vastu shastra':
        return '🔮 VASTU SHASTRA';
      case 'breathwork':
        return '🧘 BREATHWORK';
      case 'meditation':
        return '✨ MEDITATION';
      default:
        return '📹 WORKSHOP';
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'bach flower':
        return const Color(0xFF059669);
      case 'ayurveda':
        return const Color(0xFF4338CA);
      case 'vastu shastra':
        return const Color(0xFFD97706);
      case 'breathwork':
        return const Color(0xFF0288D1);
      case 'meditation':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.primary;
    }
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Bach Flower',
    'Ayurveda',
    'Vastu Shastra',
    'Breathwork',
    'Meditation',
  ];

  static const List<VideoWorkshopItem> _allWorkshops = [
    VideoWorkshopItem(
      id: 'v_1',
      title: 'Mastering 38 Bach Flower Essences & Diagnostic Clinical Cases',
      category: 'Bach Flower',
      instructor: 'Dr. Ananya Sharma (MD)',
      duration: '45 Mins',
      views: '3.8k Views',
      rating: 4.9,
      thumbnailUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80',
      description: 'A complete clinical masterclass on 38 Bach remedies, emotional mapping, dosage selection, and practical patient diagnosis.',
      takeaways: [
        'Emotional mapping for 38 Bach essences',
        'Clinical diagnosis & dosage formulation',
        'Patient case study analysis & live practice',
      ],
      isFeatured: true,
    ),
    VideoWorkshopItem(
      id: 'v_2',
      title: 'Daily Morning Ayurvedic Dinacharya & Gut Healing Secrets',
      category: 'Ayurveda',
      instructor: 'Acharya Devraj Ji',
      duration: '22 Mins',
      views: '2.1k Views',
      rating: 4.8,
      thumbnailUrl: 'https://images.unsplash.com/photo-1512290900676-26c2bfb26465?auto=format&fit=crop&w=800&q=80',
      description: 'Learn ancient Indian healing routines, Prakriti assessment, morning rituals, and natural drugless gut healing.',
      takeaways: [
        'Prakriti self-diagnosis guidelines',
        'Morning ritual routine for high energy',
        'Herbal teas & gut health remedies',
      ],
    ),
    VideoWorkshopItem(
      id: 'v_3',
      title: 'Vastu Directions, North-East Energy & Non-Demolition Remedies',
      category: 'Vastu Shastra',
      instructor: 'Guruji Rajesh Vastu',
      duration: '35 Mins',
      views: '4.2k Views',
      rating: 4.9,
      thumbnailUrl: 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=800&q=80',
      description: 'In-depth video guide on direction correction, balancing 5 elements, and applying pyramid non-demolition remedies.',
      takeaways: [
        'North-East and South-West energy balancing',
        'Pyramid and brass metal remedy placement',
        'Office & residential Vastu optimization',
      ],
    ),
    VideoWorkshopItem(
      id: 'v_4',
      title: 'Pranayama, Anulom Vilom & Deep Mind Release Masterclass',
      category: 'Breathwork',
      instructor: 'Yogini Sunita',
      duration: '28 Mins',
      views: '1.9k Views',
      rating: 4.8,
      thumbnailUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=80',
      description: 'Transformative breathwork session for anxiety relief, nervous system reset, and vital prana energy cultivation.',
      takeaways: [
        'Correct posture & breathing rhythm',
        'Vagus nerve activation techniques',
        'Instant 5-minute stress relief method',
      ],
    ),
    VideoWorkshopItem(
      id: 'v_5',
      title: '7 Chakra Sound Alignment & Aura Cleansing Guided Workshop',
      category: 'Meditation',
      instructor: 'Dr. Vivek Anand',
      duration: '30 Mins',
      views: '5.1k Views',
      rating: 5.0,
      thumbnailUrl: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=800&q=80',
      description: 'Experience deep sonic meditation frequencies for chakra rebalancing, aura purification, and inner tranquility.',
      takeaways: [
        '7 Primary Chakra frequency frequencies',
        'Aura cleansing visualization guide',
        'Deep relaxation & sleep enhancement',
      ],
    ),
  ];

  void _playVideoModal(VideoWorkshopItem workshop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoPlayerModal(workshop: workshop),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredWorkshop = _allWorkshops.firstWhere((w) => w.isFeatured, orElse: () => _allWorkshops.first);
    final filteredWorkshops = _allWorkshops.where((w) {
      if (_selectedCategory == 'All') return true;
      return w.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Guided Video Workshops'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // FEATURED HERO WORKSHOP BANNER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFeaturedHeroCard(featuredWorkshop),
            ),

            const SizedBox(height: 20),

            // CATEGORY FILTER CHIPS
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // WORKSHOPS LIST HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedCategory Workshops (${filteredWorkshops.length})',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 18, color: AppColors.textHint),
                      SizedBox(width: 4),
                      Text(
                        'Recent',
                        style: TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // WORKSHOPS LIST
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredWorkshops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final workshop = filteredWorkshops[index];
                return _buildWorkshopCard(workshop);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // FEATURED HERO WORKSHOP CARD BUILDER
  Widget _buildFeaturedHeroCard(VideoWorkshopItem workshop) {
    return GestureDetector(
      onTap: () => _playVideoModal(workshop),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x204B489B),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: workshop.thumbnailUrl,
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 210,
                  color: AppColors.primaryDark,
                  child: const Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 48),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(200),
                        Colors.black.withAlpha(100),
                        Colors.black.withAlpha(220),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Top Badges Row
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED WORKSHOP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '${workshop.rating}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Center Glowing Play Button
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(230),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(120),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
              ),

              // Bottom Details Text
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          workshop.instructor,
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            workshop.duration,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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

  // STANDARD WORKSHOP CARD BUILDER
  Widget _buildWorkshopCard(VideoWorkshopItem workshop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C4B489B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _playVideoModal(workshop),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Image with Duration Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: workshop.thumbnailUrl,
                        width: 105,
                        height: 85,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 105,
                          height: 85,
                          color: AppColors.primary,
                          child: const Icon(Icons.ondemand_video_rounded, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withAlpha(60),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(180),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          workshop.duration,
                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: workshop.categoryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              workshop.categoryBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                              const SizedBox(width: 2),
                              Text(
                                '${workshop.rating}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        workshop.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              workshop.instructor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            workshop.views,
                            style: const TextStyle(color: AppColors.textHint, fontSize: 10.5),
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
      ),
    );
  }
}

// INTERACTIVE VIDEO PLAYER MODAL BOTTOM SHEET
class _VideoPlayerModal extends StatefulWidget {
  final VideoWorkshopItem workshop;

  const _VideoPlayerModal({required this.workshop});

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  bool _isPlaying = true;
  double _sliderValue = 0.25;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Video Player Screen Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 210,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.workshop.thumbnailUrl,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withAlpha(100),
                    ),
                  ),
                ),

                // Play / Pause Overlay Button
                Center(
                  child: IconButton(
                    iconSize: 54,
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                    },
                  ),
                ),

                // Video Progress Bar Controls
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: _sliderValue,
                          onChanged: (val) {
                            setState(() {
                              _sliderValue = val;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '07:15 / ${widget.workshop.duration}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.hd_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Scrollable View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge & Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.workshop.categoryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.workshop.categoryBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '⭐ ${widget.workshop.rating} • ${widget.workshop.views}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.workshop.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    'Instructor: ${widget.workshop.instructor}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Divider(height: 24, color: AppColors.divider),

                  // Overview
                  const Text(
                    'Workshop Overview',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.workshop.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Key Takeaways
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Key Learning Takeaways',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...widget.workshop.takeaways.map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_right_rounded, color: AppColors.primary, size: 18),
                                  Expanded(
                                    child: Text(
                                      t,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Download Study Notes PDF Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading Workshop Study Notes PDF...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Download Workshop Notes & Chart (PDF)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
