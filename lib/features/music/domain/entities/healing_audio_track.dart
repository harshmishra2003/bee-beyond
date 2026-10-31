import 'package:equatable/equatable.dart';

class HealingAudioTrack extends Equatable {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String audioUrl;
  final String coverUrl;
  final double frequencyHz;
  final String description;

  const HealingAudioTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.audioUrl,
    required this.coverUrl,
    required this.frequencyHz,
    required this.description,
  });

  factory HealingAudioTrack.fromJson(Map<String, dynamic> json) {
    return HealingAudioTrack(
      id: json['id']?.toString() ?? 'aud_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '528Hz Solfeggio Healing Frequency',
      category: json['category']?.toString() ?? 'Binaural Beats',
      duration: json['duration']?.toString() ?? '15:00',
      audioUrl: json['audioUrl']?.toString() ?? json['audio_url']?.toString() ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      coverUrl: json['coverUrl']?.toString() ?? json['image']?.toString() ?? '',
      frequencyHz: double.tryParse(json['frequencyHz']?.toString() ?? '528') ?? 528.0,
      description: json['description']?.toString() ?? 'Deep cellular healing and DNA activation frequency track.',
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        duration,
        audioUrl,
        coverUrl,
        frequencyHz,
        description,
      ];
}
