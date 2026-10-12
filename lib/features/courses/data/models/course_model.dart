import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.subCategory,
    required super.imageUrl,
    required super.price,
    required super.duration,
    required super.rating,
    required super.modulesCount,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'],
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      modulesCount: json['modules_count'] ?? 10,
    );
  }
}
