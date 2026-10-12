import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;
  GetCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getAllCourses();
  }
}
