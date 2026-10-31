import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/membership_order_response_entity.dart';
import '../../domain/entities/membership_verify_result_entity.dart';
import '../models/membership_plan_model.dart';
import '../../presentation/providers/expiry_provider.dart';

abstract class MembershipRemoteDataSource {
  Future<List<MembershipPlanModel>> getMembershipPlans();
  Future<MembershipPlanModel?> getMembershipPlanDetail(String id);
  Future<UserPassSubscription?> getActiveUserMembership();
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
    final logger = Logger();

    if (dio != null) {
      try {
        logger.i('[MEMBERSHIP_API_LOG] Fetching membership plans from ${ApiEndpoints.membershipPlans}');
        final response = await dio.get(
          ApiEndpoints.membershipPlans,
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

          logger.i('[MEMBERSHIP_API_LOG] Membership plans API returned ${list.length} plans.');

          return list
              .map((json) => MembershipPlanModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        logger.e('[MEMBERSHIP_API_LOG] Failed to fetch membership plans from backend: $e');
      }
    }

    return [];
  }

  @override
  Future<MembershipPlanModel?> getMembershipPlanDetail(String id) async {
    final dio = _dioClient;
    final logger = Logger();

    if (dio != null) {
      try {
        logger.i('[MEMBERSHIP_API_LOG] Fetching plan detail for id=$id from ${ApiEndpoints.membershipPlanDetails}');
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
      } catch (e) {
        logger.e('[MEMBERSHIP_API_LOG] Failed to fetch plan detail for id=$id: $e');
      }
    }

    final plans = await getMembershipPlans();
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserPassSubscription?> getActiveUserMembership() async {
    final dio = _dioClient;
    final logger = Logger();

    if (dio != null) {
      try {
        logger.i('[MEMBERSHIP_API_LOG] Fetching active user membership from ${ApiEndpoints.activeMembership}');
        final response = await dio.get(
          ApiEndpoints.activeMembership,
          queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
          options: Options(validateStatus: (status) => true),
        );

        if (response.statusCode == 200 && response.data != null) {
          dynamic rawData = response.data;
          if (rawData is String) {
            rawData = jsonDecode(rawData);
          }

          if (rawData is Map) {
            // ============================================================
            // EXACT BACKEND SHAPE (from status endpoint):
            // {
            //   "success": true,
            //   "data": {
            //     "active_membership": { ... } | null,
            //     "scheduled_memberships": [...],
            //     "memberships": [...]
            //   }
            // }
            // ============================================================
            Map<String, dynamic>? activeMap;

            if (rawData['data'] is Map) {
              final data = Map<String, dynamic>.from(rawData['data']);

              // Primary key used by your backend
              if (data['active_membership'] is Map) {
                activeMap = Map<String, dynamic>.from(data['active_membership']);
              }
              // Fallbacks (in case backend changes later)
              else if (data['membership'] is Map) {
                activeMap = Map<String, dynamic>.from(data['membership']);
              } else if (data['subscription'] is Map) {
                activeMap = Map<String, dynamic>.from(data['subscription']);
              } else if (data['pass'] is Map) {
                activeMap = Map<String, dynamic>.from(data['pass']);
              }
            }

            // Final fallback: if the whole response is the membership object
            if (activeMap == null && rawData['status'] != null && rawData['plan_id'] != null) {
              activeMap = Map<String, dynamic>.from(rawData);
            }

            if (activeMap != null && activeMap.isNotEmpty) {
              final statusRaw = (activeMap['status'] ??
                  activeMap['membership_status'] ??
                  '')
                  .toString()
                  .toLowerCase()
                  .trim();

              final isActiveFlag = activeMap['is_active'] == true ||
                  activeMap['active'] == true;

              final isActiveStatus = statusRaw == 'active' ||
                  statusRaw == 'activated' ||
                  statusRaw == 'live' ||
                  statusRaw == 'valid';

              // Backend already filters by dates, but we still double-check
              if (isActiveFlag || isActiveStatus) {
                final pass = UserPassSubscription.fromJson(activeMap);

                if (!pass.isExpired) {
                  logger.i(
                    '[MEMBERSHIP_API_LOG] Active membership found: '
                        '${pass.passName} | plan_id=${activeMap['plan_id']} | '
                        'Expires: ${pass.expiresAt}',
                  );
                  return pass;
                } else {
                  logger.i('[MEMBERSHIP_API_LOG] Membership found but already expired on client side.');
                }
              } else {
                logger.i('[MEMBERSHIP_API_LOG] Membership object present but status is not active: "$statusRaw"');
              }
            } else {
              logger.i('[MEMBERSHIP_API_LOG] No active_membership object in response (user has no active pass).');
            }
          }
        } else {
          logger.i('[MEMBERSHIP_API_LOG] Active membership endpoint returned HTTP ${response.statusCode}');
        }
      } catch (e) {
        logger.e('[MEMBERSHIP_API_LOG] Failed to fetch active membership from backend: $e');
      }
    }
    return null;
  }

  @override
  Future<MembershipOrderResponseEntity?> createMembershipOrder({
    required int planId,
    required String billingPeriod,
  }) async {
    final dio = _dioClient;
    final logger = Logger();

    if (dio == null) {
      return null;
    }

    try {
      logger.i('[MEMBERSHIP_API_LOG] Creating order: plan_id=$planId, billing_period=$billingPeriod');
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

      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);

      if (data['success'] != true) {
        logger.w('[MEMBERSHIP_API_LOG] Order creation failed at backend: ${data['message']}');
        return null;
      }

      final order = MembershipOrderResponseEntity.fromJson(data);

      if (order.razorpayOrderId.isEmpty ||
          !RegExp(r'^order_[A-Za-z0-9]+$').hasMatch(order.razorpayOrderId)) {
        logger.e('[MEMBERSHIP_API_LOG] Invalid razorpay_order_id received: ${order.razorpayOrderId}');
        return null;
      }

      return order;
    } catch (e) {
      logger.e('[MEMBERSHIP_API_LOG] Network exception creating membership order: $e');
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
    final logger = Logger();

    if (dio == null) {
      return null;
    }

    try {
      logger.i(
        '[MEMBERSHIP_VERIFY_LOG] Verification API Request Sent:\n'
            '  Endpoint: ${ApiEndpoints.membershipVerifyPayment}\n'
            '  Membership Order ID: $membershipOrderId\n'
            '  Razorpay Payment ID: $razorpayPaymentId\n'
            '  Razorpay Order ID: $razorpayOrderId',
      );

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
        logger.e('[MEMBERSHIP_VERIFY_LOG] HTTP Error: ${response.statusCode}');
        return null;
      }

      dynamic rawData = response.data;

      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map) {
        logger.e('[MEMBERSHIP_VERIFY_LOG] Response data is not a JSON object.');
        return null;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
      final result = MembershipVerifyResultEntity.fromJson(data);

      logger.i(
        '[MEMBERSHIP_VERIFY_LOG] Verification API Response Received:\n'
            '  Success: ${result.success}\n'
            '  Message: ${result.message}\n'
            '  Membership Status: ${result.membershipStatus}\n'
            '  Is Active: ${result.isActive}\n'
            '  Start Date: ${result.startDate}\n'
            '  End Date: ${result.endDate}',
      );

      return result;
    } catch (e) {
      logger.e('[MEMBERSHIP_API_LOG] Verification network exception: $e');
      return null;
    }
  }
}