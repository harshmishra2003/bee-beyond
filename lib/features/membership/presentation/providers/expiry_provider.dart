import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/expiry_manager_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'membership_provider.dart';

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

    if (cleanPassId.isEmpty && cleanSlug.isEmpty) return false;
    if (targetId.isEmpty && targetS.isEmpty) return false;

    return (cleanPassId.isNotEmpty && cleanPassId == targetId) ||
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
    final rawPassId = json['passId']?.toString() ?? json['plan_id']?.toString() ?? json['membership_plan_id']?.toString() ?? json['id']?.toString() ?? '';
    final rawPassName = json['passName']?.toString() ?? json['plan_name']?.toString() ?? json['name']?.toString() ?? 'VIP Membership Pass';
    final rawSlug = json['slug']?.toString() ?? json['plan_slug']?.toString() ?? '';

    final rawStart = json['startDate'] ?? json['start_date'] ?? json['created_at'];
    final rawEnd = json['expiresAt'] ?? json['end_date'] ?? json['expires_at'] ?? json['valid_until'];

    final parsedStart = rawStart != null ? DateTime.tryParse(rawStart.toString()) ?? DateTime.now() : DateTime.now();
    final parsedEnd = rawEnd != null ? DateTime.tryParse(rawEnd.toString()) ?? DateTime.now().add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30));

    return UserPassSubscription(
      passId: rawPassId,
      passName: rawPassName,
      slug: rawSlug,
      startDate: parsedStart,
      expiresAt: parsedEnd,
      autoRenew: json['autoRenew'] == true || json['auto_renew'] == 1 || json['auto_renew'] == true || json['auto_renew'] == '1',
      amountPaid: double.tryParse(json['amountPaid']?.toString() ?? json['amount_paid']?.toString() ?? json['amount']?.toString() ?? '2999') ?? 2999.0,
      transactionId: json['transactionId']?.toString() ?? json['payment_id']?.toString() ?? json['transaction_id']?.toString() ?? 'TXN-VIP-1001',
    );
  }
}

/// Ticker provider that emits a tick every second so live countdown UI refreshes automatically
final liveTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});

/// Active Pass State Notifier
final StateNotifierProvider<ActivePassNotifier, UserPassSubscription?> activePassProvider =
    StateNotifierProvider<ActivePassNotifier, UserPassSubscription?>((ref) {
  final notifier = ActivePassNotifier(ref);
  ref.listen(authStateProvider, (previous, next) {
    notifier.reloadForCurrentUser();
  });
  return notifier;
});

class ActivePassNotifier extends StateNotifier<UserPassSubscription?> {
  final Ref _ref;
  Timer? _timer;

  ActivePassNotifier(this._ref) : super(null) {
    _loadActivePass();
    _startCountdownTimer();
  }

  String _getUserStorageKey(String userId) => 'bee_active_vip_pass_user_$userId';

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state != null) {
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
    final logger = Logger();
    final user = _ref.read(authStateProvider).user;

    // Purge legacy unscoped key from device
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bee_active_vip_pass_v2');
    } catch (_) {}

    if (user == null || user.id.trim().isEmpty) {
      logger.i('[MEMBERSHIP_DIAGNOSTIC] Guest or Unauthenticated User. Active pass set to NULL.');
      state = null;
      return;
    }

    final userKey = _getUserStorageKey(user.id);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(userKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        final pass = UserPassSubscription.fromJson(decoded);
        if (!pass.isExpired) {
          state = pass;
        } else {
          state = null;
        }
      } else {
        state = null;
      }
    } catch (_) {
      state = null;
    }

    // Always synchronize active membership status directly from remote MySQL DB!
    try {
      final remoteDs = _ref.read(membershipRemoteDataSourceProvider);
      final remotePass = await remoteDs.getActiveUserMembership();
      if (remotePass != null && !remotePass.isExpired) {
        logger.i('[MEMBERSHIP_DIAGNOSTIC] Synced Active Pass from Remote Backend MySQL for User (${user.id}): ${remotePass.passName}');
        state = remotePass;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(userKey, jsonEncode(remotePass.toJson()));
      } else {
        // If remote says no pass, but we have a locally active pass (e.g. just paid, replica lag), keep it!
        final isLocallyActive = state != null && !state!.isExpired;
        if (!isLocallyActive) {
          logger.w('[MEMBERSHIP_DIAGNOSTIC] Backend MySQL returned NO active membership for User (${user.id}). Setting active pass to NULL.');
          state = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(userKey);
        } else {
          logger.w('[MEMBERSHIP_DIAGNOSTIC] Backend returned NO active pass, but local is active. Preventing overwrite due to possible replica lag.');
        }
      }
    } catch (e) {
      logger.e('[MEMBERSHIP_DIAGNOSTIC] Error syncing active pass from remote backend: $e');
    }
  }

  Future<void> clearPass() async {
    final logger = Logger();
    final user = _ref.read(authStateProvider).user;
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null && user.id.trim().isEmpty) {
        await prefs.remove(_getUserStorageKey(user.id));
      }
      await prefs.remove('bee_active_vip_pass_v2'); // Clean legacy global key as well
      logger.i('[MEMBERSHIP_DIAGNOSTIC] Active pass cleared successfully on logout/reset.');
    } catch (e) {
      logger.e('[MEMBERSHIP_DIAGNOSTIC] Error clearing active pass: $e');
    }
  }

  Future<void> activatePass({
    required String passId,
    required String passName,
    required String slug,
    required DateTime startDate,
    required DateTime expiresAt,
    double amountPaid = 2999.0,
    String? transactionId,
  }) async {
    final logger = Logger();
    final user = _ref.read(authStateProvider).user;
    final txn = transactionId ?? 'TXN-VIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final newPass = UserPassSubscription(
      passId: passId,
      passName: passName,
      slug: slug,
      startDate: startDate,
      expiresAt: expiresAt,
      amountPaid: amountPaid,
      transactionId: txn,
    );

    state = newPass;
    logger.i('[MEMBERSHIP_DIAGNOSTIC] Pass Activated Successfully for User (${user?.id}): $passName (Expires: $expiresAt)');

    if (user != null && user.id.trim().isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = jsonEncode(newPass.toJson());
        await prefs.setString(_getUserStorageKey(user.id), jsonStr);
      } catch (e) {
        logger.e('[MEMBERSHIP_DIAGNOSTIC] Error saving active pass to storage: $e');
      }
    }

    _ref.read(membershipHistoryProvider.notifier).addHistoryRecord(newPass);
  }

  void reloadForCurrentUser() {
    _loadActivePass();
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
        final user = _ref.read(authStateProvider).user;
        if (user != null && user.id.trim().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final jsonStr = jsonEncode(expiredPass.toJson());
          await prefs.setString(_getUserStorageKey(user.id), jsonStr);
        }
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
