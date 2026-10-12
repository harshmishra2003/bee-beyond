import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class HealingAudioTrack {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String description;
  final String artist;
  final String frequency;
  final String imageUrl;
  final bool isPopular;

  const HealingAudioTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.artist,
    required this.frequency,
    required this.imageUrl,
    this.isPopular = false,
  });

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'chakra therapy':
        return const Color(0xFF7C3AED);
      case 'bach ambient':
        return const Color(0xFF059669);
      case 'binaural sleep':
        return const Color(0xFF4338CA);
      case 'mantra therapy':
        return const Color(0xFFD97706);
      case 'nature sounds':
        return const Color(0xFF0288D1);
      default:
        return AppColors.primary;
    }
  }
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  
  String _selectedCategory = 'All';
  HealingAudioTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  double _playbackProgress = 0.28;

  final Set<String> _favoriteTrackIds = {'t_1', 't_3'};
  final Set<String> _downloadedTrackIds = {'t_1'};

  static const List<String> _categories = [
    'All',
    'Chakra Therapy',
    'Bach Ambient',
    'Binaural Sleep',
    'Mantra Therapy',
    'Nature Sounds',
  ];

  static const List<HealingAudioTrack> _allTracks = [
    HealingAudioTrack(
      id: 't_1',
      title: '432 Hz Deep Chakra Alignment & Aura Cleansing',
      category: 'Chakra Therapy',
      duration: '45:00',
      description: 'Pure 432Hz harmonic resonance tuned for deep chakra balance, stress release, and aura field restoration.',
      artist: 'Dr. Vivek Anand',
      frequency: '432 Hz',
      imageUrl: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=800&q=80',
      isPopular: true,
    ),
    HealingAudioTrack(
      id: 't_2',
      title: 'Bach Flower Anti-Stress Ambient Bansuri Flute',
      category: 'Bach Ambient',
      duration: '30:00',
      description: 'Soothing Indian bamboo flute melodies infused with gentle nature sounds to calm panic states.',
      artist: 'Pt. Ronu Majumdar & Bee Beyond',
      frequency: '528 Hz',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80',
    ),
    HealingAudioTrack(
      id: 't_3',
      title: 'Deep Sleep Delta Wave Mind Calming Binaural Beats',
      category: 'Binaural Sleep',
      duration: '60:00',
      description: 'Subtle Delta binaural pulses designed to induce REM sleep and relieve chronic insomnia.',
      artist: 'NeuroWellness Labs',
      frequency: '0.5 - 4 Hz',
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=80',
      isPopular: true,
    ),
    HealingAudioTrack(
      id: 't_4',
      title: 'Mahamrityunjaya Mantra 108 Times Cosmic Chants',
      category: 'Mantra Therapy',
      duration: '25:00',
      description: 'Sacred Sanskrit healing chants for longevity, protection, and mental fortitude.',
      artist: 'Swami Satyananda',
      frequency: '108 Chants',
      imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=800&q=80',
    ),
    HealingAudioTrack(
      id: 't_5',
      title: 'Sacred Himalayan Forest Rain & Gentle Stream',
      category: 'Nature Sounds',
      duration: '40:00',
      description: 'Authentic high-definition field recordings of Himalayan rainfall and mountain stream water.',
      artist: 'Nature Audio Vault',
      frequency: 'Natural White Noise',
      imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
    ),
    HealingAudioTrack(
      id: 't_6',
      title: '528 Hz Transformation & DNA Cell Repair Harmonics',
      category: 'Chakra Therapy',
      duration: '50:00',
      description: 'Solfeggio 528Hz Miracle frequency for emotional resetting and deep cell rejuvenation.',
      artist: 'Dr. Ananya Sharma',
      frequency: '528 Hz Solfeggio',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _currentTrack = _allTracks.first;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _playTrack(HealingAudioTrack track) {
    setState(() {
      _currentTrack = track;
      _isPlaying = true;
    });
    _rotationController.repeat();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  void _nextTrack() {
    if (_currentTrack == null) return;
    final currentIndex = _allTracks.indexOf(_currentTrack!);
    final nextIndex = (currentIndex + 1) % _allTracks.length;
    _playTrack(_allTracks[nextIndex]);
  }

  void _previousTrack() {
    if (_currentTrack == null) return;
    final currentIndex = _allTracks.indexOf(_currentTrack!);
    final prevIndex = (currentIndex - 1 + _allTracks.length) % _allTracks.length;
    _playTrack(_allTracks[prevIndex]);
  }

  void _toggleFavorite(String trackId) {
    setState(() {
      if (_favoriteTrackIds.contains(trackId)) {
        _favoriteTrackIds.remove(trackId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites'), duration: Duration(seconds: 1)),
        );
      } else {
        _favoriteTrackIds.add(trackId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites! ❤️'), backgroundColor: AppColors.primary, duration: Duration(seconds: 1)),
        );
      }
    });
  }

  void _downloadTrack(HealingAudioTrack track) {
    if (_downloadedTrackIds.contains(track.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${track.title}" is already downloaded in offline mode.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "${track.title}" for offline playback...'),
        backgroundColor: AppColors.primary,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _downloadedTrackIds.add(track.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${track.title}" downloaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _openFullPlayerModal() {
    if (_currentTrack == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FullAudioPlayerModal(
        track: _currentTrack!,
        isPlaying: _isPlaying,
        isFavorite: _favoriteTrackIds.contains(_currentTrack!.id),
        isDownloaded: _downloadedTrackIds.contains(_currentTrack!.id),
        isShuffle: _isShuffle,
        isRepeat: _isRepeat,
        progress: _playbackProgress,
        rotationController: _rotationController,
        onPlayPauseToggle: _togglePlayPause,
        onNext: _nextTrack,
        onPrevious: _previousTrack,
        onFavoriteToggle: () => _toggleFavorite(_currentTrack!.id),
        onDownload: () => _downloadTrack(_currentTrack!),
        onProgressChanged: (val) => setState(() => _playbackProgress = val),
        onShuffleToggle: () => setState(() => _isShuffle = !_isShuffle),
        onRepeatToggle: () => setState(() => _isRepeat = !_isRepeat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTracks = _allTracks.where((t) {
      if (_selectedCategory == 'All') return true;
      return t.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Healing Music & Audios'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // TOP FEATURED TRACK BANNER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildFeaturedTrackCard(_allTracks.first),
                  ),

                  const SizedBox(height: 18),

                  // CATEGORY FILTER CHIPS
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
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

                  // TRACKS LIST HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_selectedCategory Playlists (${filteredTracks.length})',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TRACKS LIST
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTracks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final track = filteredTracks[index];
                      final isCurrent = _currentTrack?.id == track.id;

                      return _buildTrackCard(track, isCurrent);
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // FLOATING MINI AUDIO PLAYER AT BOTTOM
          if (_currentTrack != null) _buildMiniPlayer(),
        ],
      ),
    );
  }

  // FEATURED TRACK CARD
  Widget _buildFeaturedTrackCard(HealingAudioTrack track) {
    return GestureDetector(
      onTap: () {
        _playTrack(track);
        _openFullPlayerModal();
      },
      child: Container(
        height: 160,
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
              CachedNetworkImage(
                imageUrl: track.imageUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(200),
                      Colors.black.withAlpha(120),
                      Colors.black.withAlpha(230),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '🔥 MOST POPULAR TRACK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.title,
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
                          Text(
                            '${track.artist} • ${track.frequency}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 32),
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

  // TRACK ITEM CARD
  Widget _buildTrackCard(HealingAudioTrack track, bool isCurrent) {
    final isFav = _favoriteTrackIds.contains(track.id);
    final isDown = _downloadedTrackIds.contains(track.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.borderSubtle,
          width: isCurrent ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent ? AppColors.primary.withAlpha(30) : const Color(0x0C4B489B),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _playTrack(track),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail with Play / Equalizer Overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: track.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isCurrent && _isPlaying
                            ? AppColors.primary.withAlpha(180)
                            : Colors.black.withAlpha(80),
                      ),
                      child: Icon(
                        isCurrent && _isPlaying ? Icons.equalizer_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Track Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: track.categoryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              track.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            track.frequency,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${track.duration} • ${track.artist}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Actions: Download & Favorite
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isDown ? Icons.download_done_rounded : Icons.download_rounded,
                        color: isDown ? AppColors.success : AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () => _downloadTrack(track),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? const Color(0xFFEF4444) : AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () => _toggleFavorite(track.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BOTTOM MINI AUDIO PLAYER
  Widget _buildMiniPlayer() {
    final track = _currentTrack!;

    return SafeArea(
      child: GestureDetector(
        onTap: _openFullPlayerModal,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334B489B),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Spinning Record Disc
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(track.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),

              // Title & Frequency
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${track.artist} • ${track.frequency}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Play / Pause Button
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                onPressed: _togglePlayPause,
              ),

              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                onPressed: _nextTrack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FULL SCREEN AUDIO PLAYER MODAL
class _FullAudioPlayerModal extends StatelessWidget {
  final HealingAudioTrack track;
  final bool isPlaying;
  final bool isFavorite;
  final bool isDownloaded;
  final bool isShuffle;
  final bool isRepeat;
  final double progress;
  final AnimationController rotationController;

  final VoidCallback onPlayPauseToggle;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDownload;
  final ValueChanged<double> onProgressChanged;
  final VoidCallback onShuffleToggle;
  final VoidCallback onRepeatToggle;

  const _FullAudioPlayerModal({
    required this.track,
    required this.isPlaying,
    required this.isFavorite,
    required this.isDownloaded,
    required this.isShuffle,
    required this.isRepeat,
    required this.progress,
    required this.rotationController,
    required this.onPlayPauseToggle,
    required this.onNext,
    required this.onPrevious,
    required this.onFavoriteToggle,
    required this.onDownload,
    required this.onProgressChanged,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              Column(
                children: [
                  const Text(
                    'PLAYING FROM HEALING AUDIOS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.textHint,
                    ),
                  ),
                  Text(
                    track.category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
                  color: isDownloaded ? AppColors.success : AppColors.primary,
                ),
                onPressed: onDownload,
              ),
            ],
          ),

          const Spacer(),

          // Spinning Album Art Disc
          AnimatedBuilder(
            animation: rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: rotationController.value * 2 * math.pi,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x334B489B),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(track.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Track Title & Favorite Button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${track.artist} • ${track.frequency}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xFFEF4444) : AppColors.textHint,
                  size: 28,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.borderSubtle,
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  value: progress,
                  onChanged: onProgressChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '12:30',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      track.duration,
                      style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Player Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: isShuffle ? AppColors.primary : AppColors.textHint,
                  size: 22,
                ),
                onPressed: onShuffleToggle,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: AppColors.primary, size: 36),
                onPressed: onPrevious,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x334B489B), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: IconButton(
                  iconSize: 42,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onPlayPauseToggle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.primary, size: 36),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(
                  Icons.repeat_rounded,
                  color: isRepeat ? AppColors.primary : AppColors.textHint,
                  size: 22,
                ),
                onPressed: onRepeatToggle,
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
