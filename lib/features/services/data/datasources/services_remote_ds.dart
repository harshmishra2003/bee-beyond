import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/service_item.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServiceItem>> getServices();
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final DioClient? _dioClient;

  ServicesRemoteDataSourceImpl([this._dioClient]);

  @override
  Future<List<ServiceItem>> getServices() async {
    final dio = _dioClient?.instance ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    final candidateEndpoints = [
      ApiEndpoints.services, // '/services.php'
      'https://metricstestingapp.xyz/api/services.php',
      '/services.php',
      '/services',
      '/consultations.php',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await dio.get(
          endpoint,
          queryParameters: {
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          final List<dynamic> list = rawData is Map
              ? (rawData['data'] ?? rawData['services'] ?? rawData['items'] ?? [])
              : (rawData is List ? rawData : []);

          if (list.isNotEmpty) {
            return list
                .map((json) => ServiceItem.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    // Default fallback wellness services if offline or initializing
    return [
      ServiceItem(
        id: '1',
        categoryId: '3',
        category: 'Ayurvedic Upchar',
        serviceName: 'Certified Ayurvedic Upchar & Prakriti Analysis',
        offerImageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600&auto=format&fit=crop',
        descriptionImageUrl: '',
        serviceCharge: 100.0,
        offerPrice: 2004.0,
        status: 1,
        duration: '45 Mins Private Consultation',
        icon: Icons.spa_outlined,
      ),
      ServiceItem(
        id: '2',
        categoryId: '18',
        category: 'Vastu Shastra',
        serviceName: 'Personalized Residential & Work Vastu Analysis',
        offerImageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop',
        descriptionImageUrl: '',
        serviceCharge: 1499.0,
        offerPrice: 3500.0,
        status: 1,
        duration: '60 Mins Private Consultation',
        icon: Icons.home_work_outlined,
      ),
      ServiceItem(
        id: '3',
        categoryId: '17',
        category: 'Bach Flower Therapy',
        serviceName: 'Bach Remedy Personal Formula & Mind Equilibrium',
        offerImageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600&auto=format&fit=crop',
        descriptionImageUrl: '',
        serviceCharge: 899.0,
        offerPrice: 1999.0,
        status: 1,
        duration: '30 Mins Consultation & Custom Drops',
        icon: Icons.local_florist_outlined,
      ),
    ];
  }
}
