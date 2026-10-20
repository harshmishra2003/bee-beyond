import 'package:equatable/equatable.dart';

class ModuleItemEntity extends Equatable {
  final String id;
  final String title;
  final String type; // 'video' or 'pdf'
  final String mediaUrl;
  final String durationOrSize;

  const ModuleItemEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.mediaUrl,
    required this.durationOrSize,
  });

  @override
  List<Object?> get props => [id, title, type, mediaUrl, durationOrSize];
}

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
  final List<String> learnings;
  final List<ModuleItemEntity> modulesList;

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
    this.learnings = const [],
    this.modulesList = const [],
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
        learnings,
        modulesList,
      ];
}
