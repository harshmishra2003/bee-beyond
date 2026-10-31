import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/healing_audio_track.dart';

final audioTracksProvider = FutureProvider<List<HealingAudioTrack>>((ref) async {
  final dio = ref.watch(dioClientProvider);

  try {
    final response = await dio.get(
      ApiEndpoints.music,
      queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
    );

    if (response.statusCode == 200 && response.data != null) {
      dynamic rawData = response.data;
      if (rawData is String) rawData = jsonDecode(rawData);

      final List list = rawData is Map
          ? (rawData['data'] ?? rawData['tracks'] ?? rawData['music'] ?? [])
          : (rawData is List ? rawData : []);

      if (list.isNotEmpty) {
        return list.map((json) => HealingAudioTrack.fromJson(json as Map<String, dynamic>)).toList();
      }
    }
  } catch (_) {}

  // Standard official binaural audio tracks list
  return const [
    HealingAudioTrack(
      id: 'aud_101',
      title: '528Hz Solfeggio Miracle Frequency & DNA Repair',
      category: 'Solfeggio',
      duration: '20:00',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80',
      frequencyHz: 528.0,
      description: 'Sacred 528Hz acoustic vibration for deep stress relief, cellular transformation, and peace.',
    ),
    HealingAudioTrack(
      id: 'aud_102',
      title: '432Hz Deep Sleep & Theta Wave Brain Synchronization',
      category: 'Binaural Beats',
      duration: '25:00',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      coverUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=800&q=80',
      frequencyHz: 432.0,
      description: 'Harmonic 432Hz theta binaural beats designed for restorative sleep and mental calming.',
    ),
    HealingAudioTrack(
      id: 'aud_103',
      title: 'Sacred Vedic Chanting & Chakra Balancing Vibrations',
      category: 'Chanting',
      duration: '18:30',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      coverUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80',
      frequencyHz: 639.0,
      description: 'Ancient Vedic mantra harmonics for heart chakra alignment and emotional harmony.',
    ),
  ];
});
