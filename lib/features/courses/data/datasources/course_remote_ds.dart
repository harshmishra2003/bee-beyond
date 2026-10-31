import 'dart:convert';
import 'package:logger/logger.dart';
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
    final logger = Logger();

    if (dio != null) {
      try {
        logger.i('[COURSE_API_LOG] Fetching all courses from ${ApiEndpoints.courses}');
        final response = await dio.get(
          ApiEndpoints.courses,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final List<dynamic> list = rawData is Map
              ? (rawData['data'] ?? rawData['courses'] ?? [])
              : (rawData is List ? rawData : []);

          logger.i('[COURSE_API_LOG] Successfully fetched ${list.length} courses.');

          return list
              .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        logger.e('[COURSE_API_LOG] Error fetching courses: $e');
        return [];
      }
    }
    return [];
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    final dio = _dioClient;
    final logger = Logger();

    if (dio != null) {
      try {
        logger.i('[COURSE_API_LOG] Fetching course detail for id=$id from ${ApiEndpoints.courseDetail}');
        final response = await dio.get(
          ApiEndpoints.courseDetail,
          queryParameters: {
            'id': id,
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final Map<String, dynamic> json = rawData is Map
              ? (rawData['data'] is Map ? rawData['data'] : rawData)
              : {};

          if (json.isNotEmpty) {
            return CourseModel.fromJson(json);
          }
        }
      } catch (e) {
        logger.e('[COURSE_API_LOG] Error fetching course detail for id=$id: $e');
      }
    }

    final courses = await getAllCourses();
    return courses.firstWhere((c) => c.id == id);
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
