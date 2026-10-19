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
      id: json['id']?.toString() ?? json['course_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? json['category_name']?.toString() ?? 'General',
      subCategory: json['subCategory']?.toString() ?? json['sub_category']?.toString(),
      imageUrl: json['imageUrl']?.toString() ??
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['poster']?.toString() ??
          '',
      price: (json['price'] as num?)?.toDouble() ??
          double.tryParse(json['price']?.toString() ?? '0') ??
          0.0,
      duration: json['duration']?.toString() ?? 'Self-Paced',
      rating: (json['rating'] as num?)?.toDouble() ??
          double.tryParse(json['rating']?.toString() ?? '5.0') ??
          5.0,
      modulesCount: (json['modulesCount'] as num?)?.toInt() ??
          (json['modules_count'] as num?)?.toInt() ??
          int.tryParse(json['modules']?.toString() ?? '10') ??
          10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'imageUrl': imageUrl,
      'price': price,
      'duration': duration,
      'rating': rating,
      'modulesCount': modulesCount,
    };
  }
}
