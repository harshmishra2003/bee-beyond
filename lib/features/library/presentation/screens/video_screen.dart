import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/entities/video_workshop_item.dart';
import '../providers/library_provider.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  String _selectedCategory = 'All';

  void _playVideoModal(VideoWorkshopItem workshop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoPlayerModal(workshop: workshop),
    );
  }

  List<String> _extractCategories(List<VideoWorkshopItem> workshops, WidgetRef ref) {
    final Set<String> cats = {'All'};

    // 1. Official Course Categories from Home Data
    final homeAsync = ref.watch(homeDataProvider);
    homeAsync.whenData((homeData) {
      for (var c in homeData.categories) {
        if (c.name.isNotEmpty) {
          cats.add(c.name.trim());
        }
      }
    });

    // 2. Dynamic Video Categories from API
    for (var w in workshops) {
      if (w.category.isNotEmpty) {
        cats.add(w.category.trim());
      }
    }

    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoWorkshopsProvider);

    return MembershipAccessGuard(
      featureName: 'Guided Video Workshops',
      featureDescription: 'HD video lectures, practicals & masterclasses',
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Guided Video Workshops'),
      body: videoAsync.when(
        skipLoadingOnRefresh: true,
        data: (allWorkshops) {
          if (allWorkshops.isEmpty) {
            return _buildEmptyState();
          }

          final featuredWorkshop = allWorkshops.firstWhere(
            (w) => w.isFeatured,
            orElse: () => allWorkshops.first,
          );

          final categories = _extractCategories(allWorkshops, ref);

          final filteredWorkshops = allWorkshops.where((w) {
            if (_selectedCategory == 'All') return true;
            final selLower = _selectedCategory.toLowerCase();
            final catLower = w.category.toLowerCase();
            final titleLower = w.title.toLowerCase();
            final descLower = w.description.toLowerCase();

            return catLower == selLower ||
                catLower.contains(selLower) ||
                selLower.contains(catLower) ||
                titleLower.contains(selLower) ||
                descLower.contains(selLower);
          }).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(videoWorkshopsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // FEATURED HERO WORKSHOP BANNER
                  if (allWorkshops.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildFeaturedHeroCard(featuredWorkshop),
                    ),

                  const SizedBox(height: 20),

                  // CATEGORY FILTER CHIPS
                  if (categories.length > 1)
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
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
                                  fontSize: 12.5,
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
                          '$_selectedCategory Videos (${filteredWorkshops.length})',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.ondemand_video_rounded, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // WORKSHOPS LIST OR CATEGORY EMPTY STATE
                  filteredWorkshops.isNotEmpty
                      ? ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredWorkshops.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final workshop = filteredWorkshops[index];
                            return _buildWorkshopCard(workshop);
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.video_camera_back_outlined, size: 48, color: AppColors.textHint),
                                const SizedBox(height: 12),
                                Text(
                                  'No video workshops published under "$_selectedCategory" yet.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                                ),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading video workshops: $err',
                style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(videoWorkshopsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Container(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.75),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: const Icon(
                  Icons.ondemand_video_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Guided Video Workshops Uploaded Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Video workshops uploaded from the Admin panel will appear here automatically. Pull down to refresh!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => ref.invalidate(videoWorkshopsProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                label: const Text('Refresh Videos',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderHeroBox() {
    return Container(
      height: 215,
      width: double.infinity,
      color: AppColors.primaryDark,
      child: const Center(
        child: Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 48),
      ),
    );
  }

  // FEATURED HERO WORKSHOP CARD BUILDER
  Widget _buildFeaturedHeroCard(VideoWorkshopItem workshop) {
    return Container(
      height: 215,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x301E1B4B),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Material(
          color: AppColors.primaryDark,
          child: InkWell(
            onTap: () => _playVideoModal(workshop),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Hero Thumbnail Background
                workshop.thumbnailUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: workshop.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _buildPlaceholderHeroBox(),
                      )
                    : _buildPlaceholderHeroBox(),

                // Dark Gradient Overlay for Readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(160),
                        Colors.black.withAlpha(60),
                        Colors.black.withAlpha(220),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Content Overlay Column
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Badges Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.stars_rounded,
                                    color: Colors.white, size: 13),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '${workshop.rating}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Center Glowing Play Icon
                      Container(
                        padding: const EdgeInsets.all(10),
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
                          size: 32,
                        ),
                      ),

                      // Bottom Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workshop.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  color: Colors.white70, size: 12),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  workshop.instructor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  workshop.duration,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
                      child: workshop.thumbnailUrl.startsWith('http')
                          ? CachedNetworkImage(
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
                            )
                          : Container(
                              width: 105,
                              height: 85,
                              color: AppColors.primary,
                              child: const Icon(Icons.ondemand_video_rounded, color: Colors.white),
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

// IN-APP NATIVE VIDEO PLAYER MODAL BOTTOM SHEET
class _VideoPlayerModal extends StatefulWidget {
  final VideoWorkshopItem workshop;

  const _VideoPlayerModal({required this.workshop});

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final rawUrl = widget.workshop.videoUrl.trim();
    const fallbackSampleUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    final targetUrl = rawUrl.isNotEmpty ? rawUrl : fallbackSampleUrl;

    // Stage 1: Attempt direct network URL stream initialization with 6s timeout
    try {
      final uri = Uri.parse(targetUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      await _videoPlayerController!.initialize().timeout(const Duration(seconds: 6));
      _setupChewieController();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return;
    } catch (_) {
      try {
        await _videoPlayerController?.dispose();
      } catch (_) {}
      _videoPlayerController = null;
    }

    // Stage 2: Download MP4 bytes to local temp file with Dio & initialize VideoPlayerController.file
    try {
      final tempDir = await getTemporaryDirectory();
      final cleanId = widget.workshop.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      final localFile = File('${tempDir.path}/video_workshop_$cleanId.mp4');

      if (!await localFile.exists() || await localFile.length() < 1000) {
        final dio = Dio();
        final response = await dio.get<List<int>>(
          targetUrl,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            },
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          await localFile.writeAsBytes(response.data!);
        }
      }

      if (await localFile.exists() && await localFile.length() > 1000) {
        _videoPlayerController = VideoPlayerController.file(localFile);
        await _videoPlayerController!.initialize();
        _setupChewieController();

        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return;
      }
    } catch (_) {}

    // Stage 3: Guaranteed Stream Fallback (If targetUrl returned 404 or broken MP4 headers)
    try {
      final fallbackUri = Uri.parse(fallbackSampleUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(fallbackUri);
      await _videoPlayerController!.initialize();
      _setupChewieController();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _setupChewieController() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio > 0
          ? _videoPlayerController!.value.aspectRatio
          : 16 / 9,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      showControlsOnInitialize: true,
      deviceOrientationsOnEnterFullScreen: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
      deviceOrientationsAfterFullScreen: const [
        DeviceOrientation.portraitUp,
      ],
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primary,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  Future<void> _launchVideoStream(String videoUrl) async {
    final cleanUrl = videoUrl.trim();
    if (cleanUrl.isEmpty) return;

    final Uri uri = Uri.parse(cleanUrl);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {}

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (launched) return;
    } catch (_) {}

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      return;
    } catch (_) {}
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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

          // IN-APP NATIVE VIDEO PLAYER CONTAINER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _isInitializing
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 12),
                          Text(
                            'Loading In-App Video Stream...',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : (_chewieController != null &&
                          _chewieController!.videoPlayerController.value.isInitialized)
                      ? Chewie(controller: _chewieController!)
                      : GestureDetector(
                          onTap: () => _launchVideoStream(widget.workshop.videoUrl),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              widget.workshop.thumbnailUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: widget.workshop.thumbnailUrl,
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppColors.primaryDark,
                                    ),
                              Container(color: Colors.black45),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_fill_rounded,
                                      color: Colors.amberAccent, size: 52),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to Stream Video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
            ),
          ),

          const SizedBox(height: 12),

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
                    widget.workshop.description.isNotEmpty
                        ? widget.workshop.description
                        : 'Comprehensive guided video workshop covering practical application, clinical case studies, and holistic wellness practices.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Key Takeaways
                  if (widget.workshop.takeaways.isNotEmpty)
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
