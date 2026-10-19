import 'package:equatable/equatable.dart';

class JoinedCourseEntity extends Equatable {
  final String courseId;
  final String title;
  final String imageUrl;
  final double progressPercentage;
  final DateTime joinedDate;

  const JoinedCourseEntity({
    required this.courseId,
    required this.title,
    required this.imageUrl,
    required this.progressPercentage,
    required this.joinedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'title': title,
      'imageUrl': imageUrl,
      'progressPercentage': progressPercentage,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  factory JoinedCourseEntity.fromJson(Map<String, dynamic> json) {
    return JoinedCourseEntity(
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [courseId, title, imageUrl, progressPercentage, joinedDate];
}
