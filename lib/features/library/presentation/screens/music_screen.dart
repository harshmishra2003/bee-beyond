import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class MusicTrack {
  final String title;
  final String duration;
  final String category;

  const MusicTrack({required this.title, required this.duration, required this.category});
}

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  static const List<MusicTrack> tracks = [
    MusicTrack(title: '432 Hz Deep Chakra Healing Meditation', duration: '45 Mins', category: 'Chakra Therapy'),
    MusicTrack(title: 'Stress & Anxiety Relief Ambient Flute', duration: '30 Mins', category: 'Bach Flower Ambient'),
    MusicTrack(title: 'Deep Sleep & Mind Calming Binaural Beats', duration: '60 Mins', category: 'Binaural Sleep'),
    MusicTrack(title: 'Mahamrityunjaya Mantra Healing Chants', duration: '20 Mins', category: 'Mantra Therapy'),
    MusicTrack(title: 'Nature River & Gentle Rain Relaxation', duration: '40 Mins', category: 'Nature Sounds'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Healing Music & Audios'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x104B489B),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 28),
              ),
              title: Text(
                track.title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text('${track.duration} • ${track.category}', style: AppTextStyles.labelSmall),
              trailing: IconButton(
                icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "${track.title}" to favorites!')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
