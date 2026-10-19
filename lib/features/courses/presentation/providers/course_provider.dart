import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/course_remote_ds.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/joined_course_entity.dart';
import '../../domain/repositories/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(
    CourseRemoteDataSourceImpl(ref.watch(dioClientProvider)),
  );
});

final allCoursesProvider = FutureProvider<List<CourseEntity>>((ref) async {
  return await ref.watch(courseRepositoryProvider).getAllCourses();
});

final joinedCoursesProvider =
    StateNotifierProvider<JoinedCoursesNotifier, AsyncValue<List<JoinedCourseEntity>>>((ref) {
  return JoinedCoursesNotifier(ref.watch(courseRepositoryProvider));
});

class JoinedCoursesNotifier extends StateNotifier<AsyncValue<List<JoinedCourseEntity>>> {
  final CourseRepository _repository;

  JoinedCoursesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadJoinedCourses();
  }

  Future<void> loadJoinedCourses() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getJoinedCourses();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> joinCourse({
    required String courseId,
    required String title,
    required String imageUrl,
    double initialProgress = 0.0,
  }) async {
    final currentList = state.value ?? [];

    final exists = currentList.any((c) => c.courseId == courseId);
    if (!exists) {
      final newJoined = JoinedCourseEntity(
        courseId: courseId,
        title: title,
        imageUrl: imageUrl,
        progressPercentage: initialProgress,
        joinedDate: DateTime.now(),
      );

      final updatedList = [newJoined, ...currentList];
      state = AsyncValue.data(updatedList);

      try {
        await _repository.saveJoinedCourses(updatedList);
      } catch (_) {}
    }
  }
}

final courseDetailProvider = FutureProvider.family<CourseEntity, String>((ref, id) async {
  return await ref.watch(courseRepositoryProvider).getCourseById(id);
});
