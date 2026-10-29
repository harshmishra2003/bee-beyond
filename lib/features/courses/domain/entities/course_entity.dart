import 'package:equatable/equatable.dart';

class ModuleItemEntity extends Equatable {
  final String id;
  final String moduleTitle;
  final String lessonTitle;
  final String description;
  final String type; // 'video', 'pdf', 'text'
  final String mediaUrl;
  final String durationOrSize;
  final int accessLevel; // 0 = free, 1 = paid

  const ModuleItemEntity({
    required this.id,
    required this.moduleTitle,
    required this.lessonTitle,
    this.description = '',
    required this.type,
    required this.mediaUrl,
    required this.durationOrSize,
    this.accessLevel = 0,
  });

  bool get isFree => accessLevel == 0;
  bool get isPaid => accessLevel == 1;

  String get title =>
      lessonTitle.isNotEmpty ? '$moduleTitle • $lessonTitle' : moduleTitle;

  @override
  List<Object?> get props =>
      [id, moduleTitle, lessonTitle, description, type, mediaUrl, durationOrSize, accessLevel];
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
  final DateTime? createdAt;

  // LIVE COURSES FIELDS
  final bool isLive;
  final DateTime? batchStartDate;
  final DateTime? batchEndDate;
  final DateTime? registrationDeadline;
  final int courseDurationDays;
  final String meetingLink;
  final List<String> outcomes;

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
    this.createdAt,
    this.isLive = false,
    this.batchStartDate,
    this.batchEndDate,
    this.registrationDeadline,
    this.courseDurationDays = 15,
    this.meetingLink = '',
    this.outcomes = const [],
  });

  bool get isNewCourse {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final diffInHours = now.difference(createdAt!).inHours;
    return diffInHours >= 0 && diffInHours <= 48;
  }

  bool get isRegistrationUrgent {
    if (registrationDeadline == null) return false;
    final now = DateTime.now();
    final remaining = registrationDeadline!.difference(now);
    return remaining.inHours >= 0 && remaining.inHours <= 24;
  }

  Duration get timeUntilStart {
    if (batchStartDate == null) return Duration.zero;
    final now = DateTime.now();
    final diff = batchStartDate!.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  Duration get timeUntilDeadline {
    if (registrationDeadline == null) return Duration.zero;
    final now = DateTime.now();
    final diff = registrationDeadline!.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

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
        createdAt,
        isLive,
        batchStartDate,
        batchEndDate,
        registrationDeadline,
        courseDurationDays,
        meetingLink,
        outcomes,
      ];
}
