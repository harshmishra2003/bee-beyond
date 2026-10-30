import 'package:equatable/equatable.dart';

class MembershipVerifyResultEntity extends Equatable {
  final bool success;
  final String membershipStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final String message;

  const MembershipVerifyResultEntity({
    required this.success,
    required this.membershipStatus,
    this.startDate,
    this.endDate,
    this.message = '',
  });

  bool get isActive => membershipStatus.toLowerCase() == 'active';
  bool get isScheduled => membershipStatus.toLowerCase() == 'scheduled';
  bool get isExpired => membershipStatus.toLowerCase() == 'expired';

  factory MembershipVerifyResultEntity.fromJson(Map<String, dynamic> json) {
    final bool isSuccess = json['success'] == true || json['status'] == 'success';

    // Support nested 'data' map if backend returns { success: true, data: { ... } }
    final Map<String, dynamic> dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final statusStr = (dataMap['membership_status'] ??
            dataMap['status'] ??
            json['membership_status'] ??
            '')
        .toString()
        .toLowerCase()
        .trim();

    final rawStart = dataMap['start_date'] ?? json['start_date'];
    final rawEnd = dataMap['end_date'] ?? dataMap['expires_at'] ?? json['end_date'] ?? json['expires_at'];

    DateTime? parsedStart;
    if (rawStart != null && rawStart.toString().trim().isNotEmpty) {
      parsedStart = DateTime.tryParse(rawStart.toString().trim());
    }

    DateTime? parsedEnd;
    if (rawEnd != null && rawEnd.toString().trim().isNotEmpty) {
      parsedEnd = DateTime.tryParse(rawEnd.toString().trim());
    }

    return MembershipVerifyResultEntity(
      success: isSuccess,
      membershipStatus: statusStr.isNotEmpty
          ? statusStr
          : (isSuccess ? 'active' : 'failed'),
      startDate: parsedStart,
      endDate: parsedEnd,
      message: (json['message'] ?? dataMap['message'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props =>
      [success, membershipStatus, startDate, endDate, message];
}
