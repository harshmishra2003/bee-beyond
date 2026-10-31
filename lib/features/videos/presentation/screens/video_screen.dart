import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/video_lecture_item.dart';
import '../providers/video_provider.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Overview',
    'Bach Flower',
    'Vastu',
    'Ayurveda',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openYouTubeChannel() async {
    final uri = Uri.parse(VideoLectureItem.youtubeChannelUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube channel.')),
        );
      }
    }
  }

  Future<void> _playVideo(VideoLectureItem video) async {
    final targetUrl = video.videoUrl.isNotEmpty ? video.videoUrl : VideoLectureItem.youtubeChannelUrl;
    final uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await _openYouTubeChannel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoLecturesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Bee Beyonnd Video Portal'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(videoLecturesProvider);
        },
        color: const Color(0xFFFF0000),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OFFICIAL YOUTUBE CHANNEL BRANDING HEADER
              _buildYouTubeHeaderBanner(),

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
                    style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search channel videos, topics, guides...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF0000), size: 22),
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
              _buildCategorySelector(),

              const SizedBox(height: 20),

              // VIDEOS LIST PRESENTATION
              videoAsync.when(
                data: (videos) {
                  final filtered = videos.where((v) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        v.title.toLowerCase().contains(_searchQuery) ||
                        v.instructor.toLowerCase().contains(_searchQuery) ||
                        v.description.toLowerCase().contains(_searchQuery);

                    final matchesCat = _selectedCategory == 'All' ||
                        v.category.toLowerCase().contains(_selectedCategory.toLowerCase());

                    return matchesSearch && matchesCat;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildVideoCard(filtered[index]);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFFF0000))),
                ),
                error: (err, stack) => _buildErrorState(err.toString()),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYouTubeHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F0F), Color(0xFF1F1F1F), Color(0xFF282828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'OFFICIAL YOUTUBE CHANNEL',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openYouTubeChannel,
                icon: const Icon(Icons.subscriptions_rounded, size: 14, color: Colors.white),
                label: Text(
                  'Subscribe',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF0000), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bee Beyonnd Official (@beebeyonndofficial)',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Watch latest uploaded holistic healing lectures, Bach Flower Remedy diagnosis, and Vastu energy masterclasses directly from YouTube.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFFAAAAAA),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _selectedCategory = cat;
                });
              }
            },
            selectedColor: const Color(0xFFFF0000),
            backgroundColor: Colors.white,
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFFFF0000) : AppColors.borderSubtle,
              ),
            ),
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoLectureItem video) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THUMBNAIL WITH YOUTUBE BADGE
          GestureDetector(
            onTap: () => _playVideo(video),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: video.effectiveThumbnailUrl,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 170,
                      color: const Color(0xFF1F1F1F),
                      child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF0000))),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 170,
                      color: const Color(0xFF1F1F1F),
                      child: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFFF0000), size: 56),
                    ),
                  ),
                ),

                // RED PLAY BUTTON
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xEEFF0000),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                // YOUTUBE BADGE
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFFF0000), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'YOUTUBE',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // DURATION
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      video.duration,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DETAILS
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${video.instructor} • ${video.views} Views',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _playVideo(video),
                    icon: const Icon(Icons.play_circle_filled_rounded, size: 16),
                    label: Text(
                      'Watch on YouTube',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                size: 56,
                color: Color(0xFFFF0000),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Videos Found',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Watch all official holistic videos directly on our YouTube Channel @beebeyonndofficial.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openYouTubeChannel,
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text('Open @beebeyonndofficial on YouTube', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_library_rounded,
                size: 56,
                color: Color(0xFFFF0000),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load videos',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openYouTubeChannel,
              icon: const Icon(Icons.subscriptions_rounded, size: 16),
              label: Text('Visit YouTube Channel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
