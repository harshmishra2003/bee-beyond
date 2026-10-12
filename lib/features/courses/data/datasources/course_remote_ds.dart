import '../models/course_model.dart';
import '../../domain/entities/joined_course_entity.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getAllCourses();
  Future<CourseModel> getCourseById(String id);
  Future<List<JoinedCourseEntity>> getJoinedCourses();
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
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
        price: 2499.0,
        duration: '24 Hours',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=600&q=80',
        modulesCount: 12,
      ),
      CourseModel(
        id: 'c_2',
        title: 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
        description: 'Learn ancient Indian healing wisdom, Prakriti diagnosis, lifestyle correction, and drugless remedies.',
        category: 'Ayurvedic Upchar',
        subCategory: 'Prakriti Diagnosis',
        price: 3999.0,
        duration: '32 Hours',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1512290900676-26c2bfb26465?auto=format&fit=crop&w=600&q=80',
        modulesCount: 16,
      ),
      CourseModel(
        id: 'c_3',
        title: 'Mind & Life Coaching Masterclass',
        description: 'Transformative emotional counselling skills, stress relief strategies, and life coaching practices.',
        category: 'Counselling',
        subCategory: 'Life Strategies',
        price: 2999.0,
        duration: '20 Hours',
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=600&q=80',
        modulesCount: 10,
      ),
      CourseModel(
        id: 'c_4',
        title: 'Advanced Bach Flower Clinical Cases',
        description: 'In-depth clinical mastery for complex emotional states and chronic issues using Bach remedies.',
        category: 'Bach Flower',
        subCategory: 'Clinical Mastery',
        price: 3499.0,
        duration: '30 Hours',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1596431940984-c5a47e2a9b70?auto=format&fit=crop&w=600&q=80',
        modulesCount: 15,
      ),
      CourseModel(
        id: 'c_5',
        title: 'Ayurvedic Diet & Nutrition',
        description: 'Learn diet planning according to doshas, mindful eating, and resolving gut issues naturally.',
        category: 'Ayurvedic Upchar',
        subCategory: 'Diet',
        price: 1999.0,
        duration: '15 Hours',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=600&q=80',
        modulesCount: 8,
      ),
      CourseModel(
        id: 'c_6',
        title: 'Advanced Vastu Shastra',
        description: 'In-depth Vastu corrections without demolition for residential and commercial spaces.',
        category: 'Vastu',
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
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      JoinedCourseEntity(
        courseId: 'c_1',
        title: 'Certified Bach Flower Therapy & Healing Course',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=600&q=80',
        progressPercentage: 75.0,
        joinedDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      JoinedCourseEntity(
        courseId: 'c_2',
        title: 'Ayurvedic Lifestyle & Drugless Upchar Diploma',
        imageUrl: 'https://images.unsplash.com/photo-1512290900676-26c2bfb26465?auto=format&fit=crop&w=600&q=80',
        progressPercentage: 45.0,
        joinedDate: DateTime.now().subtract(const Duration(days: 8)),
      ),
      JoinedCourseEntity(
        courseId: 'c_6',
        title: 'Advanced Vastu Shastra Certification',
        imageUrl: 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=600&q=80',
        progressPercentage: 100.0,
        joinedDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}
