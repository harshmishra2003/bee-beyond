import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/course_model.dart';
import '../../domain/entities/joined_course_entity.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getAllCourses();
  Future<CourseModel> getCourseById(String id);
  Future<List<JoinedCourseEntity>> getJoinedCourses();
  Future<void> saveJoinedCourses(List<JoinedCourseEntity> courses);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final DioClient? _dioClient;
  static const String _joinedCoursesKey = 'joined_courses_data';

  CourseRemoteDataSourceImpl([this._dioClient]);

  @override
  Future<List<CourseModel>> getAllCourses() async {
    final dio = _dioClient;
    if (dio != null) {
      try {
        final response = await dio.get(ApiEndpoints.courses);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          final List<dynamic> list = data is Map
              ? (data['data'] ?? data['courses'] ?? [])
              : (data is List ? data : []);

          return list
              .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // Return empty list if endpoint is not live or encounters network issue
        return [];
      }
    }
    return [];
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    final dio = _dioClient;
    if (dio != null) {
      try {
        final response = await dio.get('${ApiEndpoints.courseDetail}$id');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          final Map<String, dynamic> json =
              data is Map ? (data['data'] ?? data) : {};
          return CourseModel.fromJson(json);
        }
      } catch (_) {}
    }

    final courses = await getAllCourses();
    return courses.firstWhere(
      (c) => c.id == id,
      orElse: () => CourseModel(
        id: id,
        title: 'Course Detail',
        description: 'Details for this course will be loaded dynamically.',
        category: 'General',
        imageUrl: '',
        price: 0.0,
        duration: 'Self-Paced',
        rating: 5.0,
        modulesCount: 10,
      ),
    );
  }

  @override
  Future<List<JoinedCourseEntity>> getJoinedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_joinedCoursesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded
            .map((e) => JoinedCourseEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveJoinedCourses(List<JoinedCourseEntity> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(courses.map((e) => e.toJson()).toList());
    await prefs.setString(_joinedCoursesKey, jsonString);
  }
}
