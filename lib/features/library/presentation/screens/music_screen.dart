import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _MusicScreenState extends ConsumerState<MusicScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  HealingAudioTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isSpinningUp = false;
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
    HapticFeedback.mediumImpact();
    setState(() {
      _currentTrack = track;
      _isPlaying = true;
    });
    _rotationController.repeat();
  }

  void _playFeaturedTrackWithSpinUp(HealingAudioTrack track) async {
    HapticFeedback.mediumImpact();

    if (_currentTrack?.id == track.id && _isPlaying) return;

    setState(() {
      _currentTrack = track;
      _isPlaying = true;
      _isSpinningUp = true;
    });

    _rotationController.repeat();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Spinning vinyl record & streaming "${track.title}"...',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        duration: const Duration(milliseconds: 2500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      setState(() {
        _isSpinningUp = false;
      });
    }
  }

  void _togglePlayPause() {
    HapticFeedback.mediumImpact();
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
    HapticFeedback.mediumImpact();
    if (_currentTrack == null || tracks.isEmpty) return;
    final currentIndex = tracks.indexOf(_currentTrack!);
    final nextIndex = (currentIndex + 1) % tracks.length;
    _playTrack(tracks[nextIndex]);
  }

  void _previousTrack(List<HealingAudioTrack> tracks) {
    HapticFeedback.mediumImpact();
    if (_currentTrack == null || tracks.isEmpty) return;
    final currentIndex = tracks.indexOf(_currentTrack!);
    final prevIndex = (currentIndex - 1 + tracks.length) % tracks.length;
    _playTrack(tracks[prevIndex]);
  }

  void _toggleFavorite(String trackId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favoriteTrackIds.contains(trackId)) {
        _favoriteTrackIds.remove(trackId);
      } else {
        _favoriteTrackIds.add(trackId);
      }
    });
  }

  void _downloadTrack(HealingAudioTrack track) {
    HapticFeedback.mediumImpact();
    if (_downloadedTrackIds.contains(track.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${track.title}" is already downloaded in offline mode.'),
        ),
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
    HapticFeedback.lightImpact();

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
        onShuffleToggle: () {
          HapticFeedback.selectionClick();
          setState(() => _isShuffle = !_isShuffle);
        },
        onRepeatToggle: () {
          HapticFeedback.selectionClick();
          setState(() => _isRepeat = !_isRepeat);
        },
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.library_music_rounded;
      case 'chakra therapy':
        return Icons.auto_awesome_rounded;
      case 'bach ambient':
        return Icons.local_florist_rounded;
      case 'binaural sleep':
        return Icons.nightlight_round;
      case 'mantra therapy':
        return Icons.brightness_high_rounded;
      case 'nature sounds':
        return Icons.nature_people_rounded;
      default:
        return Icons.graphic_eq_rounded;
    }
  }

  int _getCategoryCount(List<HealingAudioTrack> allTracks, String category) {
    if (category == 'All') return allTracks.length;
    return allTracks
        .where((t) => t.category.toLowerCase() == category.toLowerCase())
        .length;
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
            final matchesCategory = _selectedCategory == 'All' ||
                t.category.toLowerCase() == _selectedCategory.toLowerCase();

            final query = _searchQuery.trim().toLowerCase();
            final matchesSearch = query.isEmpty ||
                t.title.toLowerCase().contains(query) ||
                t.artist.toLowerCase().contains(query) ||
                t.frequency.toLowerCase().contains(query) ||
                t.category.toLowerCase().contains(query);

            return matchesCategory && matchesSearch;
          }).toList();

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(audioTracksProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // TOP FEATURED TRACK BANNER WITH VINYL SPIN-UP ANIMATION
                      if (allTracks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildFeaturedTrackCard(allTracks.first),
                        ),

                      const SizedBox(height: 16),

                      // SEARCH BAR
                      _buildSearchBar(),

                      const SizedBox(height: 16),

                      // CATEGORY FILTER CHIPS WITH ICONS & COUNTS
                      if (categories.length > 1)
                        _buildCategoryFilterBar(categories, allTracks),

                      const SizedBox(height: 18),

                      // LIST HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$_selectedCategory Audios',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFC7D2FE)),
                                  ),
                                  child: Text(
                                    '${filteredTracks.length}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _AnimatedEqualizerBars(isPlaying: _isPlaying),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ANIMATED AUDIO TRACKS LIST
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: filteredTracks.isEmpty
                            ? KeyedSubtree(
                                key: ValueKey('empty_${_selectedCategory}_$_searchQuery'),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.music_off_rounded,
                                            size: 44, color: AppColors.textHint),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No audio tracks found in "$_selectedCategory".',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : KeyedSubtree(
                                key: ValueKey('list_${_selectedCategory}_$_searchQuery'),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredTracks.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final track = filteredTracks[index];
                                    final isPlayingThis =
                                        _currentTrack?.id == track.id && _isPlaying;
                                    final isFavorite =
                                        _favoriteTrackIds.contains(track.id);

                                    return _buildTrackTile(
                                        track, isPlayingThis, isFavorite);
                                  },
                                ),
                              ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // MINI BOTTOM AUDIO PLAYER BAR
            if (_currentTrack != null) _buildMiniPlayerBar(allTracks),
          ],
        );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading audio tracks: $err',
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
        ref.invalidate(audioTracksProvider);
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
                  Icons.music_note_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Healing Audio Tracks Uploaded Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Audio tracks uploaded from the Admin panel will appear here automatically. Pull down to refresh.',
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
                onPressed: () => ref.invalidate(audioTracksProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                label: const Text('Refresh Audios',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) {
          HapticFeedback.selectionClick();
          setState(() => _searchQuery = val);
        },
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search audio, frequency (e.g. 528 Hz), or artist...',
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 18),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterBar(
      List<String> categories, List<HealingAudioTrack> allTracks) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected =
              _selectedCategory.toLowerCase() == cat.toLowerCase();
          final count = _getCategoryCount(allTracks, cat);
          final icon = _getCategoryIcon(cat);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [
                        const BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.amberAccent : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            child: RotationTransition(
              turns: _rotationController,
              child: Icon(Icons.album_rounded,
                  size: 140, color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                RotationTransition(
                  turns: _rotationController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: track.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: track.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildAudioIconBox(track, size: 80),
                          )
                        : _buildAudioIconBox(track, size: 80),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FEATURED HARMONIC',
                              style: TextStyle(
                                  color: Color(0xFF1E1B4B),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (_isSpinningUp) ...[
                            const SizedBox(width: 6),
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.8, color: Colors.amberAccent),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${track.artist} • ${track.frequency}',
                        style: const TextStyle(
                            color: Color(0xFFC7D2FE), fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF312E81),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            elevation: 2,
                          ),
                          onPressed: () => _playFeaturedTrackWithSpinUp(track),
                          icon: _isSpinningUp
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFF312E81)),
                                )
                              : const Icon(Icons.play_arrow_rounded, size: 18),
                          label: Text(
                            _isSpinningUp ? 'SPINNING VINYL...' : 'LISTEN NOW',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w900),
                          ),
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

  Widget _buildAudioIconBox(HealingAudioTrack track, {double size = 56}) {
    return Container(
      width: size,
      height: size,
      color: track.categoryColor,
      child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 28),
    );
  }

  Widget _buildTrackTile(
      HealingAudioTrack track, bool isPlayingThis, bool isFavorite) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isPlayingThis ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlayingThis ? AppColors.primary : const Color(0xFFE2E8F0),
          width: isPlayingThis ? 2.0 : 1.2,
        ),
        boxShadow: isPlayingThis
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                const BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _playTrack(track),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail with Equalizer Overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: track.imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: track.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  _buildAudioIconBox(track, size: 56),
                            )
                          : _buildAudioIconBox(track, size: 56),
                    ),
                    if (isPlayingThis)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: _AnimatedEqualizerBars(
                              isPlaying: true, color: Colors.amberAccent),
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
                      // Category Tag & Frequency Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: track.categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: track.categoryColor.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              track.category.toUpperCase(),
                              style: TextStyle(
                                color: track.categoryColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.graphic_eq_rounded,
                                    size: 10, color: Color(0xFFD97706)),
                                const SizedBox(width: 3),
                                Text(
                                  track.frequency,
                                  style: const TextStyle(
                                    color: Color(0xFFB45309),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isPlayingThis ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Text(
                            track.artist,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          const Text('•',
                              style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                          const SizedBox(width: 6),
                          const Icon(Icons.access_time_rounded,
                              size: 11, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Text(
                            track.duration,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Actions with Haptic Heart Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedHeartButton(
                      isFavorite: isFavorite,
                      onTap: () => _toggleFavorite(track.id),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlayingThis
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: AppColors.primary,
                        size: 34,
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
              ],
            ),
          ),
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
                  child: const Icon(Icons.album_rounded,
                      color: Colors.amberAccent, size: 28),
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
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_currentTrack!.artist} • ${_currentTrack!.frequency}',
                          style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 10.5),
                        ),
                        if (_isPlaying) ...[
                          const SizedBox(width: 8),
                          const _AnimatedEqualizerBars(
                              isPlaying: true, color: Colors.amberAccent),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 28),
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

// ANIMATED EQUALIZER SOUND WAVE BARS
class _AnimatedEqualizerBars extends StatefulWidget {
  final bool isPlaying;
  final Color color;

  const _AnimatedEqualizerBars({
    required this.isPlaying,
    this.color = AppColors.primary,
  });

  @override
  State<_AnimatedEqualizerBars> createState() => _AnimatedEqualizerBarsState();
}

class _AnimatedEqualizerBarsState extends State<_AnimatedEqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedEqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(8 + val * 10),
            const SizedBox(width: 2.5),
            _buildBar(16 - val * 8),
            const SizedBox(width: 2.5),
            _buildBar(6 + val * 14),
            const SizedBox(width: 2.5),
            _buildBar(14 - val * 10),
          ],
        );
      },
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 3.0,
      height: widget.isPlaying ? height.clamp(4.0, 20.0) : 5.0,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ANIMATED HEART POP BUTTON WITH HAPTIC FEEDBACK
class _AnimatedHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _AnimatedHeartButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<_AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<_AnimatedHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.45), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.45, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: widget.isFavorite ? Colors.redAccent : AppColors.textHint,
            size: 22,
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
            decoration: BoxDecoration(
                color: Colors.white30, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 30),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
              const Text(
                'NOW PLAYING HARMONIC',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              _AnimatedHeartButton(
                isFavorite: isFavorite,
                onTap: onFavoriteToggle,
              ),
            ],
          ),
          const Spacer(),

          // SLIDE & FADE ANIMATED TRACK PLAYER ARTWORK & DETAILS
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(track.id),
              child: Column(
                children: [
                  RotationTransition(
                    turns: rotationController,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amberAccent, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 2),
                        ],
                      ),
                      child: ClipOval(
                        child: track.imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: track.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                    color: track.categoryColor,
                                    child: const Icon(Icons.music_note_rounded,
                                        size: 72, color: Colors.white)),
                              )
                            : Container(
                                color: track.categoryColor,
                                child: const Icon(Icons.music_note_rounded,
                                    size: 72, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    track.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${track.artist} • ${track.frequency}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // AUDIO PLAYER PROGRESS SLIDER
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
              Text('${(progress * 45).toInt()}:00',
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(track.duration,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 24),

          // CONTROL BUTTONS ROW WITH HAPTIC FEEDBACK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle_rounded,
                    color: isShuffle ? Colors.amberAccent : Colors.white54),
                onPressed: onShuffleToggle,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded,
                    color: Colors.white, size: 36),
                onPressed: onPrevious,
              ),
              FloatingActionButton.large(
                backgroundColor: Colors.amberAccent,
                foregroundColor: const Color(0xFF1E1B4B),
                onPressed: onPlayPauseToggle,
                child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded,
                    color: Colors.white, size: 36),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(Icons.repeat_rounded,
                    color: isRepeat ? Colors.amberAccent : Colors.white54),
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
