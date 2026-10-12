import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'About Bee Beyond'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.spa, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(AppConstants.appName, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            Text(AppConstants.appTagline, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Text(
              'Bee Beyond is a dedicated holistic wellness platform offering certified online courses, drugless therapies, Bach Flower remedies, and authentic natural healing products.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text('Version 1.0.0 (Build 100)', style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}
