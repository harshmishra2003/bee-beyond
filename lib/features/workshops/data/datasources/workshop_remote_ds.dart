import 'dart:convert';
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

  @override
  Future<List<WorkshopItem>> getWorkshops() async {
    if (_dioClient == null) {
      return [];
    }

    try {
      final response = await _dioClient.get(
        ApiEndpoints.workshops,
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic rawData = response.data;
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }

        final List list = rawData is List
            ? rawData
            : (rawData is Map
                ? (rawData['data'] ?? rawData['workshops'] ?? rawData['items'] ?? [])
                : []);

        return list
            .map((json) => WorkshopItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Swallowed error fallback to empty list
    }

    return [];
  }

  @override
  Future<WorkshopItem?> getWorkshopDetail(String id) async {
    if (_dioClient != null) {
      try {
        final response = await _dioClient.get(
          ApiEndpoints.workshopDetail,
          queryParameters: {
            'id': id,
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
          options: Options(validateStatus: (status) => true),
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) rawData = jsonDecode(rawData);

          final Map<String, dynamic> data = rawData is Map
              ? (rawData['data'] is Map ? rawData['data'] : rawData)
              : {};

          if (data.isNotEmpty && (data['id'] != null || data['title'] != null)) {
            return WorkshopItem.fromJson(data);
          }
        }
      } catch (_) {}
    }

    // Fallback: search in getWorkshops() list fetched from dynamic API
    final list = await getWorkshops();
    try {
      final cleanId = id.trim().toLowerCase();
      return list.firstWhere(
        (w) => w.id.trim().toLowerCase() == cleanId || w.id.toString() == id.toString(),
      );
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }
}
