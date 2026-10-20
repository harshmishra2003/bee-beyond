import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/healing_audio_track.dart';
import '../providers/library_provider.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  String _selectedCategory = 'All';
  HealingAudioTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  double _playbackProgress = 0.28;

  final Set<String> _favoriteTrackIds = {};
  final Set<String> _downloadedTrackIds = {};

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
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

  void _nextTrack(List<HealingAudioTrack> tracks) {
    if (_currentTrack == null || tracks.isEmpty) return;
    final currentIndex = tracks.indexOf(_currentTrack!);
    final nextIndex = (currentIndex + 1) % tracks.length;
    _playTrack(tracks[nextIndex]);
  }

  void _previousTrack(List<HealingAudioTrack> tracks) {
    if (_currentTrack == null || tracks.isEmpty) return;
    final currentIndex = tracks.indexOf(_currentTrack!);
    final prevIndex = (currentIndex - 1 + tracks.length) % tracks.length;
    _playTrack(tracks[prevIndex]);
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

  void _openFullPlayerModal(List<HealingAudioTrack> tracks) {
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
        onNext: () => _nextTrack(tracks),
        onPrevious: () => _previousTrack(tracks),
        onFavoriteToggle: () => _toggleFavorite(_currentTrack!.id),
        onDownload: () => _downloadTrack(_currentTrack!),
        onProgressChanged: (val) => setState(() => _playbackProgress = val),
        onShuffleToggle: () => setState(() => _isShuffle = !_isShuffle),
        onRepeatToggle: () => setState(() => _isRepeat = !_isRepeat),
      ),
    );
  }

  List<String> _extractCategories(List<HealingAudioTrack> tracks) {
    final Set<String> cats = {'All'};
    for (var t in tracks) {
      if (t.category.isNotEmpty) cats.add(t.category);
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    final audioAsync = ref.watch(audioTracksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Healing Music & Audios'),
      body: audioAsync.when(
        data: (allTracks) {
          if (allTracks.isEmpty) {
            return _buildEmptyState();
          }

          if (_currentTrack == null && allTracks.isNotEmpty) {
            _currentTrack = allTracks.first;
          }

          final categories = _extractCategories(allTracks);
          final filteredTracks = allTracks.where((t) {
            if (_selectedCategory == 'All') return true;
            return t.category.toLowerCase() == _selectedCategory.toLowerCase();
          }).toList();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // TOP FEATURED TRACK BANNER
                      if (allTracks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildFeaturedTrackCard(allTracks.first),
                        ),

                      const SizedBox(height: 18),

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
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 18),

                      // LIST HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_selectedCategory Audios (${filteredTracks.length})',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 22),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // AUDIO TRACKS LIST
                      if (filteredTracks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No audio tracks found in $_selectedCategory category.',
                              style: const TextStyle(color: AppColors.textHint, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTracks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final track = filteredTracks[index];
                            final isPlayingThis = _currentTrack?.id == track.id && _isPlaying;
                            final isFavorite = _favoriteTrackIds.contains(track.id);

                            return _buildTrackTile(track, isPlayingThis, isFavorite);
                          },
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // MINI BOTTOM AUDIO PLAYER BAR
              if (_currentTrack != null)
                _buildMiniPlayerBar(allTracks),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading audio tracks: $err', style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
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
                Icons.music_note_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Healing Audio Tracks Available Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our audio studio is recording certified frequency tracks, chakra resonances, and binaural sleep audio. Stay tuned!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTrackCard(HealingAudioTrack track) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF4338CA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x301E1B4B),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.music_note_rounded, size: 140, color: Colors.white.withAlpha(20)),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: track.imageUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: track.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _buildAudioIconBox(track),
                        )
                      : _buildAudioIconBox(track),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FEATURED HARMONIC',
                          style: TextStyle(color: Color(0xFF1E1B4B), fontSize: 8.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold, height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${track.artist} • ${track.frequency}',
                        style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF312E81),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 0,
                          ),
                          onPressed: () => _playTrack(track),
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('LISTEN NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioIconBox(HealingAudioTrack track) {
    return Container(
      width: 80,
      height: 80,
      color: track.categoryColor,
      child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 36),
    );
  }

  Widget _buildTrackTile(HealingAudioTrack track, bool isPlayingThis, bool isFavorite) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlayingThis ? AppColors.primary : AppColors.borderSubtle,
          width: isPlayingThis ? 1.8 : 1.2,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Material(
        color: isPlayingThis ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: track.imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: track.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        color: track.categoryColor,
                        child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: track.categoryColor,
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                    ),
            ),
            if (isPlayingThis)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.equalizer_rounded, color: Colors.white, size: 24),
              ),
          ],
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: isPlayingThis ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${track.artist} • ${track.duration}',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.redAccent : AppColors.textHint,
                size: 20,
              ),
              onPressed: () => _toggleFavorite(track.id),
            ),
            IconButton(
              icon: Icon(
                isPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              onPressed: () {
                if (isPlayingThis) {
                  _togglePlayPause();
                } else {
                  _playTrack(track);
                }
              },
            ),
          ],
        ),
        onTap: () => _playTrack(track),
      ),
    ),
  );
  }

  Widget _buildMiniPlayerBar(List<HealingAudioTrack> tracks) {
    if (_currentTrack == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1B4B),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => _openFullPlayerModal(tracks),
          child: Row(
            children: [
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.album_rounded, color: Colors.amberAccent, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTrack!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_currentTrack!.artist} • ${_currentTrack!.frequency}',
                      style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 28),
                onPressed: _togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                onPressed: () => _nextTrack(tracks),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F0C20),
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'NOW PLAYING HARMONIC',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? Colors.redAccent : Colors.white),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
          const Spacer(),
          RotationTransition(
            turns: rotationController,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amberAccent, width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withAlpha(80), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: ClipOval(
                child: track.imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: track.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(color: track.categoryColor, child: const Icon(Icons.music_note_rounded, size: 72, color: Colors.white)),
                      )
                    : Container(color: track.categoryColor, child: const Icon(Icons.music_note_rounded, size: 72, color: Colors.white)),
              ),
            ),
          ),
          const Spacer(),
          Text(
            track.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${track.artist} • ${track.frequency}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 13),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.amberAccent,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.amberAccent,
              trackHeight: 3,
            ),
            child: Slider(
              value: progress,
              onChanged: onProgressChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 45).toInt()}:00', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(track.duration, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle_rounded, color: isShuffle ? Colors.amberAccent : Colors.white54),
                onPressed: onShuffleToggle,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36),
                onPressed: onPrevious,
              ),
              FloatingActionButton.large(
                backgroundColor: Colors.amberAccent,
                foregroundColor: const Color(0xFF1E1B4B),
                onPressed: onPlayPauseToggle,
                child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(Icons.repeat_rounded, color: isRepeat ? Colors.amberAccent : Colors.white54),
                onPressed: onRepeatToggle,
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
