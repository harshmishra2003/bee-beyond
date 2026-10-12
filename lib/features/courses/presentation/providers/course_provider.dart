import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/course_remote_ds.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(CourseRemoteDataSourceImpl());
});

final allCoursesProvider = FutureProvider<List<CourseEntity>>((ref) async {
  return await ref.watch(courseRepositoryProvider).getAllCourses();
});

final joinedCoursesProvider = FutureProvider((ref) async {
  return await ref.watch(courseRepositoryProvider).getJoinedCourses();
});

final courseDetailProvider = FutureProvider.family<CourseEntity, String>((ref, id) async {
  return await ref.watch(courseRepositoryProvider).getCourseById(id);
});
