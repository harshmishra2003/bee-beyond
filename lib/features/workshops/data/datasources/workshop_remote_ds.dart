import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/workshop_item.dart';

abstract class WorkshopRemoteDataSource {
  Future<List<WorkshopItem>> getWorkshops();
  Future<WorkshopItem?> getWorkshopDetail(String id);
}

class WorkshopRemoteDataSourceImpl implements WorkshopRemoteDataSource {
  final DioClient? _dioClient;

  WorkshopRemoteDataSourceImpl([this._dioClient]);

  static final List<WorkshopItem> _fallbackWorkshops = [
    const WorkshopItem(
      id: 'ws_101',
      title: 'Certified Sound Healing & 528Hz Binaural Masterclass',
      instructor: 'Acharya Devraj',
      lineage: '35 Yrs Sacred Sound Lineage',
      category: 'Sound Healing',
      description: 'Experience sacred sound frequency activation, singing bowl harmonics, and deep meditative state tuning.',
      duration: '3.5 Hours',
      basePrice: 2499.0,
      discount: 500.0,
      rating: 4.95,
      thumbnailUrl: 'https://images.unsplash.com/photo-1514533450685-4493e01d1fdc?w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      takeaways: [
        'Understand 528Hz Solfeggio frequency mechanics',
        'Learn singing bowl acoustic vibration alignment',
        'Hands-on chakra sound cleansing protocol',
        'Receive official accredited completion certificate'
      ],
      upcomingDates: ['Sat, 10 AM IST', 'Sun, 4 PM IST'],
      isLive: true,
      views: 3420,
    ),
    const WorkshopItem(
      id: 'ws_102',
      title: 'Vedic Vastu Remedial Directions & Energy Mapping',
      instructor: 'Dr. Rameshwar Vastu Gurukul',
      lineage: 'Vastu Shastra Kendra',
      category: 'Vastu',
      description: 'Master non-demolition energy correction methods for home, workplace, and commercial spaces.',
      duration: '4.0 Hours',
      basePrice: 2999.0,
      discount: 600.0,
      rating: 4.88,
      thumbnailUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      takeaways: [
        'Nadi and Marma energy grid mapping',
        'Pyramid and crystal directional balancing',
        'Elemental balance without structural alterations',
        'Case study walkthrough of residential vastu'
      ],
      upcomingDates: ['Next Saturday, 11 AM IST'],
      isLive: true,
      views: 2890,
    ),
    const WorkshopItem(
      id: 'ws_103',
      title: 'Ayurvedic Prakriti Diagnosis & Herbal Formulations',
      instructor: 'Vaidya Ananya Sharma',
      lineage: 'Ayurvedic Medical Board',
      category: 'Ayurveda',
      description: 'Comprehensive pulse reading, dosha balance evaluation, and organic herbal compounding techniques.',
      duration: '2.5 Hours',
      basePrice: 1999.0,
      discount: 400.0,
      rating: 4.92,
      thumbnailUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      takeaways: [
        'Vata, Pitta, and Kapha constitution diagnosis',
        'Custom herbal tea and kadha brewing',
        'Daily Dinacharya routines for immunity'
      ],
      upcomingDates: ['Available Recorded HD Stream'],
      isLive: false,
      views: 4150,
    ),
    const WorkshopItem(
      id: 'ws_104',
      title: 'Mind Transformation & Emotional Subconscious Reset',
      instructor: 'Acharya Devraj',
      lineage: '35 Yrs Sacred Vedic Lineage',
      category: 'Life Coaching',
      description: 'Practical subconscious reprogramming, anxiety dissolution, and mental clarity meditation techniques.',
      duration: '3.0 Hours',
      basePrice: 1799.0,
      discount: 300.0,
      rating: 4.90,
      thumbnailUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      takeaways: [
        'Neuro-linguistic emotional release methods',
        'Pranayama routines for stress reduction',
        'Daily 10-minute mindfulness protocol'
      ],
      upcomingDates: ['Available Recorded HD Stream'],
      isLive: false,
      views: 5120,
    ),
  ];

  @override
  Future<List<WorkshopItem>> getWorkshops() async {
    if (_dioClient == null) {
      return _fallbackWorkshops;
    }

    try {
      final response = await _dioClient.get(
        ApiEndpoints.workshops,
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        final List list = rawData is List
            ? rawData
            : (rawData['data'] ?? rawData['workshops'] ?? rawData['items'] ?? []);

        if (list.isNotEmpty) {
          return list.map((json) => WorkshopItem.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Swallowed error fallback
    }

    return _fallbackWorkshops;
  }

  @override
  Future<WorkshopItem?> getWorkshopDetail(String id) async {
    final list = await getWorkshops();
    try {
      return list.firstWhere((w) => w.id == id);
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }
}
