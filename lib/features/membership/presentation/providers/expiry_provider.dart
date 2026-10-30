import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/expiry_manager_service.dart';

class UserPassSubscription {
  final String passId;
  final String passName;
  final String slug;
  final DateTime startDate;
  final DateTime expiresAt;
  final bool autoRenew;
  final double amountPaid;
  final String transactionId;

  const UserPassSubscription({
    required this.passId,
    required this.passName,
    required this.slug,
    required this.startDate,
    required this.expiresAt,
    this.autoRenew = false,
    this.amountPaid = 2999.0,
    this.transactionId = 'TXN-VIP-1001',
  });

  bool get isExpired => ExpiryManagerService.isPassExpired(expiresAt);
  bool get isActive => !isExpired;
  bool get isExpiringSoon => ExpiryManagerService.isExpiringSoon(expiresAt);
  AccessStatus get status => ExpiryManagerService.getAccessStatus(expiresAt);
  String get statusLabel => ExpiryManagerService.formatExpiryStatus(expiresAt);
  double get progress => ExpiryManagerService.getExpiryProgress(startDate, expiresAt);

  /// Robust plan matching helper across IDs ("1") and Slugs ("bloom")
  bool matchesPlan(String targetPlanId, [String? targetSlug]) {
    final cleanPassId = passId.toLowerCase().trim();
    final cleanSlug = slug.toLowerCase().trim();
    final targetId = targetPlanId.toLowerCase().trim();
    final targetS = (targetSlug ?? '').toLowerCase().trim();

    return cleanPassId == targetId ||
        (targetS.isNotEmpty && cleanPassId == targetS) ||
        (cleanSlug.isNotEmpty && cleanSlug == targetId) ||
        (cleanSlug.isNotEmpty && targetS.isNotEmpty && cleanSlug == targetS);
  }

  bool isMatchingPlanActive(String targetPlanId, [String? targetSlug]) {
    return isActive && matchesPlan(targetPlanId, targetSlug);
  }

  bool isMatchingPlanExpired(String targetPlanId, [String? targetSlug]) {
    return isExpired && matchesPlan(targetPlanId, targetSlug);
  }

  /// Exact live countdown duration
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Formatted live countdown string: "14d 23h 58m 42s"
  String get formattedLiveCountdown {
    final rem = timeRemaining;
    if (rem == Duration.zero) return 'Expired';

    final days = rem.inDays;
    final hours = rem.inHours % 24;
    final minutes = rem.inMinutes % 60;
    final seconds = rem.inSeconds % 60;

    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toJson() {
    return {
      'passId': passId,
      'passName': passName,
      'slug': slug,
      'startDate': startDate.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'autoRenew': autoRenew,
      'amountPaid': amountPaid,
      'transactionId': transactionId,
    };
  }

  factory UserPassSubscription.fromJson(Map<String, dynamic> json) {
    return UserPassSubscription(
      passId: json['passId']?.toString() ?? 'gold_pass',
      passName: json['passName']?.toString() ?? 'Gold VIP Membership',
      slug: json['slug']?.toString() ?? 'gold',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now().subtract(const Duration(days: 300)),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(days: 18)),
      autoRenew: json['autoRenew'] == true,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 2999.0,
      transactionId: json['transactionId']?.toString() ?? 'TXN-VIP-1001',
    );
  }
}

/// Ticker provider that emits a tick every second so live countdown UI refreshes automatically
final liveTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});

/// Active Pass State Notifier
final activePassProvider =
    StateNotifierProvider<ActivePassNotifier, UserPassSubscription?>((ref) {
  return ActivePassNotifier(ref);
});

class ActivePassNotifier extends StateNotifier<UserPassSubscription?> {
  static const String _storageKey = 'bee_active_vip_pass_v2';
  final Ref _ref;
  Timer? _timer;

  ActivePassNotifier(this._ref) : super(null) {
    _loadActivePass();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state != null) {
        // Force state update to trigger listener updates for live countdown
        state = state;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadActivePass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        state = UserPassSubscription.fromJson(decoded);
        return;
      }
    } catch (_) {}

    // Default to null when no active membership pass exists in local storage
    state = null;
  }

  Future<void> activatePass({
    required String passId,
    required String passName,
    required String slug,
    int? durationYears,
    DateTime? startDate,
    DateTime? expiresAt,
    double amountPaid = 2999.0,
    String? transactionId,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now;
    final end = expiresAt ?? start.add(Duration(days: 365 * (durationYears ?? 1)));
    final txn = transactionId ?? 'TXN-VIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final newPass = UserPassSubscription(
      passId: passId,
      passName: passName,
      slug: slug,
      startDate: start,
      expiresAt: end,
      amountPaid: amountPaid,
      transactionId: txn,
    );

    state = newPass;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(newPass.toJson());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}

    // Also add to membership history
    _ref.read(membershipHistoryProvider.notifier).addHistoryRecord(newPass);
  }

  Future<void> expirePassForTesting() async {
    if (state != null) {
      final expiredPass = UserPassSubscription(
        passId: state!.passId,
        passName: state!.passName,
        slug: state!.slug,
        startDate: state!.startDate,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        amountPaid: state!.amountPaid,
        transactionId: state!.transactionId,
      );
      state = expiredPass;

      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = jsonEncode(expiredPass.toJson());
        await prefs.setString(_storageKey, jsonStr);
      } catch (_) {}
    }
  }
}

/// Membership History Notifier
final membershipHistoryProvider =
    StateNotifierProvider<MembershipHistoryNotifier, List<UserPassSubscription>>((ref) {
  return MembershipHistoryNotifier();
});

class MembershipHistoryNotifier extends StateNotifier<List<UserPassSubscription>> {
  static const String _historyKey = 'bee_membership_history_v1';

  MembershipHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStrList = prefs.getStringList(_historyKey);
      if (jsonStrList != null && jsonStrList.isNotEmpty) {
        final list = jsonStrList
            .map((item) => UserPassSubscription.fromJson(jsonDecode(item)))
            .toList();
        state = list;
        return;
      }
    } catch (_) {}

    // Default to empty list when no history exists
    state = const [];
  }

  Future<void> addHistoryRecord(UserPassSubscription record) async {
    state = [record, ...state];

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStrList = state.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_historyKey, jsonStrList);
    } catch (_) {}
  }
}
