import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String title;
  final String? targetRoute;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.targetRoute,
  });

  @override
  List<Object?> get props => [id, imageUrl, title, targetRoute];
}
