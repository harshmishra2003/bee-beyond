import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class VideoItem {
  final String title;
  final String duration;
  final String category;

  const VideoItem({required this.title, required this.duration, required this.category});
}

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  static const List<VideoItem> videos = [
    VideoItem(title: 'Daily Morning Ayurvedic Dinacharya Routine', duration: '18 Mins', category: 'Ayurveda'),
    VideoItem(title: 'Pranayama & Breathwork Secrets Masterclass', duration: '25 Mins', category: 'Breathwork'),
    VideoItem(title: 'Vastu Directions & Remedy Installation Guide', duration: '32 Mins', category: 'Vastu Shastra'),
    VideoItem(title: 'Bach Flower Remedies Case Study Tutorial', duration: '40 Mins', category: 'Bach Flower'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Guided Video Workshops'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final vid = videos[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x104B489B),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary, size: 28),
              ),
              title: Text(
                vid.title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text('${vid.duration} • ${vid.category}', style: AppTextStyles.labelSmall),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
            ),
          );
        },
      ),
    );
  }
}
