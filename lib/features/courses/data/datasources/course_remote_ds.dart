import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../../domain/entities/joined_course_entity.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getAllCourses();
  Future<CourseModel> getCourseById(String id);
  Future<List<JoinedCourseEntity>> getJoinedCourses();
  Future<void> saveJoinedCourses(List<JoinedCourseEntity> courses);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  static const String _joinedCoursesKey = 'joined_courses_data';

  @override
  Future<List<CourseModel>> getAllCourses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      CourseModel(
        id: 'c_1',
        title: 'Certified Bach Flower Therapy & Healing Course',
        description: 'Comprehensive online certification in Bach Flower Remedies, remedy selection, clinical case studies, and emotional wellness.',
        category: 'Bach Flower',
        subCategory: 'Remedy Basics',
        price: 2999.0,
        duration: '24 Hours',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=600&q=80',
        modulesCount: 12,
      ),
      CourseModel(
        id: 'c_2',
        title: 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
        description: 'Learn fundamental principles of Dinacharya, Ritucharya, Prakriti analysis, and home remedies for everyday ailments.',
        category: 'Ayurvedic Upchar',
        subCategory: 'Prakriti & Doshas',
        price: 3499.0,
        duration: '32 Hours',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1512290900676-26c2bfb26465?auto=format&fit=crop&w=600&q=80',
        modulesCount: 16,
      ),
      CourseModel(
        id: 'c_3',
        title: 'Complete Vastu Shastra for Home & Workplace',
        description: 'Master directional energies, room placements, Five Elements balance, and non-demolition remedies.',
        category: 'Vastu Shastra',
        subCategory: 'Residential Vastu',
        price: 3999.0,
        duration: '28 Hours',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80',
        modulesCount: 14,
      ),
      CourseModel(
        id: 'c_4',
        title: 'Spiritual Life Coaching & Emotional Healing',
        description: 'Guided techniques for chakras balance, mindfulness, meditation, and spiritual growth.',
        category: 'Life Coaching',
        subCategory: 'Chakra Healing',
        price: 2499.0,
        duration: '18 Hours',
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80',
        modulesCount: 10,
      ),
      CourseModel(
        id: 'c_5',
        title: 'Aromatherapy & Essential Oils Practitioner Course',
        description: 'Science of essential oils, therapeutic blending, carrier oils, and safe application.',
        category: 'Aromatherapy',
        subCategory: 'Essential Blends',
        price: 1999.0,
        duration: '15 Hours',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=600&q=80',
        modulesCount: 8,
      ),
      CourseModel(
        id: 'c_6',
        title: 'Advanced Vastu Shastra Certification',
        description: 'Professional training in commercial Vastu remedies, industrial layouts, and energy auditing.',
        category: 'Vastu Shastra',
        subCategory: 'Commercial Vastu',
        price: 4999.0,
        duration: '40 Hours',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=600&q=80',
        modulesCount: 20,
      ),
    ];
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    final courses = await getAllCourses();
    return courses.firstWhere((c) => c.id == id, orElse: () => courses.first);
  }

  @override
  Future<List<JoinedCourseEntity>> getJoinedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_joinedCoursesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((e) => JoinedCourseEntity.fromJson(e as Map<String, dynamic>)).toList();
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
