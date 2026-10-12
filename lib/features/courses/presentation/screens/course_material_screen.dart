import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class CourseMaterialScreen extends StatelessWidget {
  const CourseMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Course Study Material'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('Module 1: Introduction to Bach Flower Remedies', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text('Learn the core philosophy of Dr. Edward Bach and natural remedy selection.', style: AppTextStyles.bodyMedium),
          const Divider(height: 32),
          Text('Downloadable Study PDF Guides', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
            title: const Text('Module 1 - Complete Handbook.pdf'),
            subtitle: const Text('2.4 MB'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
