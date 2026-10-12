import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../providers/course_provider.dart';

class JoinedCoursesScreen extends ConsumerWidget {
  const JoinedCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedAsync = ref.watch(joinedCoursesProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Joined Courses'),
      body: joinedAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('You have not joined any courses yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = courses[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: c.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: AppTextStyles.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: c.progressPercentage / 100,
                              backgroundColor: AppColors.surfaceVariant,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 4),
                            Text('${c.progressPercentage.toInt()}% Completed', style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 36),
                        onPressed: () {
                          context.push(RoutePaths.courseMaterial);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
