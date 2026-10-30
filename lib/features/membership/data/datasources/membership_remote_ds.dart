import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/membership_order_response_entity.dart';
import '../../domain/entities/membership_verify_result_entity.dart';
import '../models/membership_plan_model.dart';

abstract class MembershipRemoteDataSource {
  Future<List<MembershipPlanModel>> getMembershipPlans();
  Future<MembershipPlanModel?> getMembershipPlanDetail(String id);
  Future<MembershipOrderResponseEntity?> createMembershipOrder({
    required int planId,
    required String billingPeriod,
  });
  Future<MembershipVerifyResultEntity?> verifyMembershipPayment({
    required int membershipOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
}

class MembershipRemoteDataSourceImpl implements MembershipRemoteDataSource {
  final DioClient? _dioClient;

  MembershipRemoteDataSourceImpl([this._dioClient]);

  @override
  Future<List<MembershipPlanModel>> getMembershipPlans() async {
    final dio = _dioClient;
    if (dio != null) {
      final candidateEndpoints = [
        ApiEndpoints.membershipPlans,
        '/membership_plans.php',
        '/membership.php',
        '/memberships.php',
        '/membership/plans.php',
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
                ? (rawData['data'] ?? rawData['plans'] ?? rawData['memberships'] ?? [])
                : (rawData is List ? rawData : []);

            if (list.isNotEmpty) {
              return list
                  .map((json) => MembershipPlanModel.fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }
        } catch (_) {
          // Fall through candidate endpoints on error
        }
      }
    }

    // Default 4 Official VIP Membership Plans with Banner Images
    return const [
      MembershipPlanModel(
        id: '1',
        slug: 'bloom',
        name: 'Bloom',
        tagline: 'BLOOM MEMBERSHIP PASS',
        badgeText: 'POPULAR',
        price: 1999.0,
        currency: 'INR',
        accessDuration: 1,
        accessType: 'year',
        durationLabel: '1 YEAR ACCESS',
        features: [
          'Annual savings: 389rs (16.3%) compared with paying monthly for 12 months.',
          '• Access to selected digital books, PDFs, music and videos',
          '• 5% off eligible courses, workshops and paid services.',
          'Early notifications about new courses and workshops.',
        ],
      ),
      MembershipPlanModel(
        id: '2',
        slug: 'elevate',
        name: 'Elevate',
        tagline: 'ELEVATE MEMBERSHIP PASS',
        badgeText: 'RECOMMENDED',
        price: 2500.0,
        currency: 'INR',
        accessDuration: 1,
        accessType: 'year',
        durationLabel: '1 YEAR ACCESS',
        features: [
          '20% Flat Discount on Courses, Remedies & Vastu Services',
          'Free Monthly Live Breathwork & Meditation Webinars',
          'Priority Q&A Access in Student & Doctor Forums',
          'Unlimited Audio & PDF Material Downloads',
        ],
      ),
      MembershipPlanModel(
        id: '3',
        slug: 'transform',
        name: 'Transform',
        tagline: 'TRANSFORM MEMBERSHIP PASS',
        badgeText: 'BEST VALUE',
        price: 4999.0,
        currency: 'INR',
        accessDuration: 2,
        accessType: 'year',
        durationLabel: '2 YEARS ACCESS',
        features: [
          '35% FLAT OFF ON EVERYTHING Across Bee Beyonnd Portal',
          '1-on-1 Personal Video Consultation with Doctor (1 Hour)',
          'Unlimited Video Workshop & Course Recordings Access',
          'Free Express Delivery & Priority Tax Invoices',
        ],
      ),
      MembershipPlanModel(
        id: '4',
        slug: 'infinity',
        name: 'Infinity',
        tagline: 'INFINITY MEMBERSHIP PASS',
        badgeText: 'LIFETIME VIP',
        price: 9999.0,
        currency: 'INR',
        accessDuration: 99,
        accessType: 'year',
        durationLabel: 'LIFETIME VIP ACCESS',
        features: [
          '50% FLAT OFF Lifetime VIP Privileges Across All Products',
          'Quarterly Personal Health & Vastu Consultations',
          'VIP Access to All Future Workshops, Courses & Audios',
          'Dedicated 24/7 VIP Concierge & Doctor Support',
        ],
      ),
    ];
  }

  @override
  Future<MembershipPlanModel?> getMembershipPlanDetail(String id) async {
    final dio = _dioClient;
    if (dio != null) {
      try {
        final response = await dio.get(
          ApiEndpoints.membershipPlanDetails,
          queryParameters: {
            'id': id,
            '_t': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }
          final Map<String, dynamic> data = rawData is Map
              ? (rawData['data'] is Map ? rawData['data'] : rawData)
              : {};

          if (data.isNotEmpty) {
            return MembershipPlanModel.fromJson(data);
          }
        }
      } catch (_) {}
    }

    final plans = await getMembershipPlans();
    return plans.firstWhere((p) => p.id == id, orElse: () => plans.first);
  }

  @override
  Future<MembershipOrderResponseEntity?> createMembershipOrder({
    required int planId,
    required String billingPeriod,
  }) async {
    final dio = _dioClient;

    if (dio == null) {
      return null;
    }

    try {
      final response = await dio.post(
        ApiEndpoints.membershipCreateOrder,
        data: {
          'plan_id': planId,
          'billing_period': billingPeriod,
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      dynamic rawData = response.data;

      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map) {
        return null;
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(rawData);

      if (data['success'] != true) {
        return null;
      }

      final order = MembershipOrderResponseEntity.fromJson(data);

      // Only accept a real order ID returned by the backend.
      if (order.razorpayOrderId.isEmpty ||
          !RegExp(r'^order_[A-Za-z0-9]+$')
              .hasMatch(order.razorpayOrderId)) {
        return null;
      }

      return order;
    } catch (e) {
      // Do not invent a local order or retry another endpoint.
      // The caller should display an order-creation error.
      return null;
    }
  }

  @override
  Future<MembershipVerifyResultEntity?> verifyMembershipPayment({
    required int membershipOrderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final dio = _dioClient;

    if (dio == null) {
      return null;
    }

    try {
      final response = await dio.post(
        ApiEndpoints.membershipVerifyPayment,
        data: {
          'membership_order_id': membershipOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      dynamic rawData = response.data;

      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map) {
        return null;
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(rawData);

      return MembershipVerifyResultEntity.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
