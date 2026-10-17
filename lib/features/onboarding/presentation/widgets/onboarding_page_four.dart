import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageFour extends StatelessWidget {
  const OnboardingPageFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Logo Image
          SizedBox(
            width: 180,
            height: 180,
            child: Image.asset(
              AssetPaths.beeBeyondImage2,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa_rounded, size: 80, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Ready to Begin Your Journey?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Bee Beyonnd is your personal companion guiding you towards physical, mental & spiritual wellbeing.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
