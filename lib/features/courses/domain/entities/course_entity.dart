import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subCategory;
  final String imageUrl;
  final String trailerUrl;
  final double price;
  final String duration;
  final double rating;
  final int modulesCount;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subCategory,
    required this.imageUrl,
    this.trailerUrl = '',
    required this.price,
    required this.duration,
    required this.rating,
    required this.modulesCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        subCategory,
        imageUrl,
        trailerUrl,
        price,
        duration,
        rating,
        modulesCount,
      ];
}
