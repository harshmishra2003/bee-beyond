import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class MaterialItem {
  final String title;
  final String size;
  final String category;

  const MaterialItem({required this.title, required this.size, required this.category});
}

class MaterialScreen extends StatelessWidget {
  const MaterialScreen({super.key});

  static const List<MaterialItem> materials = [
    MaterialItem(
      title: '38 Bach Flower Remedies Quick Reference Chart.pdf',
      size: '2.4 MB',
      category: 'Bach Flower Therapy',
    ),
    MaterialItem(
      title: 'Vastu Shastra Directions & Energy Guide.pdf',
      size: '4.1 MB',
      category: 'Vastu Shastra',
    ),
    MaterialItem(
      title: 'Ayurvedic Dinacharya Daily Routine Handbook.pdf',
      size: '3.2 MB',
      category: 'Ayurveda',
    ),
    MaterialItem(
      title: 'Graphology Handwriting Analysis Basics.pdf',
      size: '1.9 MB',
      category: 'Graphology',
    ),
    MaterialItem(
      title: 'Drugless Natural Healing Principles & Herbs.pdf',
      size: '5.6 MB',
      category: 'Drugless Cure',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Books & Study Materials'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final item = materials[index];
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
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 26),
              ),
              title: Text(
                item.title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(item.size, style: AppTextStyles.labelSmall),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(fontSize: 9.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading "${item.title}"...')),
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
