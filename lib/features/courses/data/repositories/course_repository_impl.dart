import '../../domain/entities/course_entity.dart';
import '../../domain/entities/joined_course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_ds.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CourseEntity>> getAllCourses() async {
    return await remoteDataSource.getAllCourses();
  }

  @override
  Future<CourseEntity> getCourseById(String id) async {
    return await remoteDataSource.getCourseById(id);
  }

  @override
  Future<List<JoinedCourseEntity>> getJoinedCourses() async {
    return await remoteDataSource.getJoinedCourses();
  }

  @override
  Future<bool> enrollCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<void> saveJoinedCourses(List<JoinedCourseEntity> courses) async {
    await remoteDataSource.saveJoinedCourses(courses);
  }
}
