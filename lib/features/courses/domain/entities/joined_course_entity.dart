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

  @override
  List<Object?> get props => [courseId, title, imageUrl, progressPercentage, joinedDate];
}
