import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/healing_audio_track.dart';
import '../providers/audio_provider.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  HealingAudioTrack? _currentTrack;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(HealingAudioTrack track) async {
    if (_currentTrack?.id == track.id) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      await _audioPlayer.stop();
      setState(() {
        _currentTrack = track;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      await _audioPlayer.play(UrlSource(track.audioUrl));
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audioAsync = ref.watch(audioTracksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Music & Audio Portal'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(audioTracksProvider);
        },
        color: AppColors.primary,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER BANNER
                    _buildHeaderBanner(),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Healing Frequencies & Binaural Tracks',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    audioAsync.when(
                      data: (tracks) {
                        if (tracks.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tracks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final track = tracks[index];
                            final isThisPlaying = _currentTrack?.id == track.id && _isPlaying;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isThisPlaying ? AppColors.primary : AppColors.borderSubtle,
                                  width: isThisPlaying ? 1.5 : 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isThisPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                                title: Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${track.category} • ${track.frequencyHz.toInt()}Hz • ${track.duration}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () => _playTrack(track),
                                ),
                                onTap: () => _playTrack(track),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      ),
                      error: (err, stack) => _buildErrorState(err.toString()),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // MINI AUDIO PLAYER CONTROLLER AT BOTTOM
            if (_currentTrack != null) _buildMiniPlayer(),
          ],
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
          colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'HEALING FREQUENCIES PORTAL',
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Solfeggio & Binaural Sound Audio',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Listen to 528Hz, 432Hz theta brainwave audio tracks and sacred Vedic chants.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFE0E7FF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTrack!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => _playTrack(_currentTrack!),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 3,
                activeTrackColor: Colors.amber,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.amber,
              ),
              child: Slider(
                value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0),
                max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                onChanged: (val) {
                  _audioPlayer.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.music_off_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'No Audio Tracks Found',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
            Text(
              'Failed to load audio tracks',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(audioTracksProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
