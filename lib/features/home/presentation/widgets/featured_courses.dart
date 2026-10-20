import 'package:flutter/material.dart';
import '../../../../core/widgets/course_card.dart';

class FeaturedCoursesSection extends StatelessWidget {
  final Function(String courseId) onCourseTap;
  final Function(String courseId)? onJoinGroup;

  const FeaturedCoursesSection({
    super.key,
    required this.onCourseTap,
    this.onJoinGroup,
  });

  @override
  Widget build(BuildContext context) {
    final mockCourses = [
      {
        'id': 'c_1',
        'title': 'Certified Bach Flower Therapy & Healing Course',
        'category': 'Bach Flower',
        'price': 2499.0,
        'duration': '12 Modules • 24 hrs',
        'rating': 4.9,
        'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=600&q=80',
      },
      {
        'id': 'c_2',
        'title': 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
        'category': 'Ayurvedic Upchar',
        'price': 3999.0,
        'duration': '16 Modules • 32 hrs',
        'rating': 4.8,
        'image': 'https://images.unsplash.com/photo-1512290900676-26c2bfb26465?auto=format&fit=crop&w=600&q=80',
      },
      {
        'id': 'c_3',
        'title': 'Holistic Nutrition & Healing Herbal Foods',
        'category': 'Nutrition',
        'price': 1899.0,
        'duration': '8 Modules • 16 hrs',
        'rating': 4.9,
        'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=600&q=80',
      },
    ];

    return SizedBox(
      height: 275,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mockCourses.length,
        itemBuilder: (context, index) {
          final course = mockCourses[index];
          return CourseCard(
            title: course['title'] as String,
            category: course['category'] as String,
            imageUrl: course['image'] as String,
            price: course['price'] as double,
            duration: course['duration'] as String,
            rating: course['rating'] as double,
            isNew: true,
            onTap: () => onCourseTap(course['id'] as String),
            onJoinGroup: () => onJoinGroup?.call(course['id'] as String),
          );
        },
      ),
    );
  }
}
