import '../entities/course_entity.dart';
import '../entities/joined_course_entity.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getAllCourses();
  Future<CourseEntity> getCourseById(String id);
  Future<List<JoinedCourseEntity>> getJoinedCourses();
  Future<bool> enrollCourse(String id);
}
