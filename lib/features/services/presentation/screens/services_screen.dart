import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';

class ServiceItem {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String price;
  final IconData icon;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    required this.icon,
  });
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<ServiceItem> servicesList = [
    ServiceItem(
      id: 'srv_1',
      title: 'Personal Counseling & Mental Therapy',
      description: 'Individual 1-on-1 therapy for stress, anxiety, emotional balance, and relationship guidance.',
      duration: '45 Mins Session',
      price: '₹ 1,499',
      icon: Icons.psychology_outlined,
    ),
    ServiceItem(
      id: 'srv_2',
      title: 'Vastu Shastra Home & Office Consultation',
      description: 'Energy alignment, directional balance, and remedy guidance for living and work spaces.',
      duration: '60 Mins Session',
      price: '₹ 2,999',
      icon: Icons.home_work_outlined,
    ),
    ServiceItem(
      id: 'srv_3',
      title: 'Bach Flower Remedy Personal Assessment',
      description: 'Customized flower essence prescription for mood balance, panic relief, and emotional release.',
      duration: '30 Mins Session',
      price: '₹ 999',
      icon: Icons.local_florist_outlined,
    ),
    ServiceItem(
      id: 'srv_4',
      title: 'DMIT & Brain Mapping Analysis',
      description: 'Dermatoglyphics Multiple Intelligence Test for career discovery, innate talents, and learning style.',
      duration: '60 Mins Session',
      price: '₹ 3,499',
      icon: Icons.fingerprint_outlined,
    ),
    ServiceItem(
      id: 'srv_5',
      title: 'Graphology & Handwriting Analysis',
      description: 'Subconscious personality insights, habit diagnosis, and signature correction guidance.',
      duration: '30 Mins Session',
      price: '₹ 1,199',
      icon: Icons.edit_note_outlined,
    ),
    ServiceItem(
      id: 'srv_6',
      title: 'Ayurvedic Health & Diet Consultation',
      description: 'Prakriti analysis, dosha balancing, and drugless herbal lifestyle consultation.',
      duration: '45 Mins Session',
      price: '₹ 1,299',
      icon: Icons.spa_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Wellness & Consultation Services'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Top Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Expert Practitioner Consultations',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book 1-on-1 private sessions with certified Ayurvedic doctors, Vastu masters, graphologists, and counselors.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Services List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: servicesList.length,
              itemBuilder: (context, index) {
                final srv = servicesList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(srv.icon, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  srv.title,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  srv.duration,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        srv.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            srv.price,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          ThreeDButton(
                            text: 'Book Session',
                            fontSize: 12,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Booking request sent for "${srv.title}"!'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
