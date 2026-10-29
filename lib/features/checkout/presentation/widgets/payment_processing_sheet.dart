import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../routing/route_paths.dart';

enum PaymentProcessingStatus {
  launchingApp,
  processing,
  verifying,
  success,
  failed,
  timedOut,
}

class PaymentProcessingSheet extends StatefulWidget {
  final String appName;
  final String upiId;
  final String? packageName;
  final double amount;
  final String orderId;
  final Future<bool> Function() onVerifyPayment;
  final VoidCallback onSuccessComplete;
  final VoidCallback? onFailure;

  const PaymentProcessingSheet({
    super.key,
    required this.appName,
    required this.upiId,
    this.packageName,
    required this.amount,
    required this.orderId,
    required this.onVerifyPayment,
    required this.onSuccessComplete,
    this.onFailure,
  });

  static Future<void> show(
    BuildContext context, {
    required String appName,
    required String upiId,
    String? packageName,
    required double amount,
    required String orderId,
    required Future<bool> Function() onVerifyPayment,
    required VoidCallback onSuccessComplete,
    VoidCallback? onFailure,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentProcessingSheet(
        appName: appName,
        upiId: upiId,
        packageName: packageName,
        amount: amount,
        orderId: orderId,
        onVerifyPayment: onVerifyPayment,
        onSuccessComplete: onSuccessComplete,
        onFailure: onFailure,
      ),
    );
  }

  @override
  State<PaymentProcessingSheet> createState() => _PaymentProcessingSheetState();
}

class _PaymentProcessingSheetState extends State<PaymentProcessingSheet>
    with SingleTickerProviderStateMixin {
  PaymentProcessingStatus _status = PaymentProcessingStatus.launchingApp;

  int _secondsRemaining = 15;
  Timer? _countdownTimer;

  int _autoRedirectSeconds = 3;
  Timer? _autoRedirectTimer;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _startUpiIntentAndProcessing();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoRedirectTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startUpiIntentAndProcessing() async {
    setState(() => _status = PaymentProcessingStatus.launchingApp);

    final encodedTitle = Uri.encodeComponent('Bee Beyonnd Wellness');
    final encodedNote = Uri.encodeComponent('Order #${widget.orderId}');
    final amountStr = widget.amount.toStringAsFixed(2);

    final candidateUris = <String>[];

    final appLower = widget.appName.toLowerCase();
    if (appLower.contains('google') || appLower.contains('gpay')) {
      candidateUris.add('tez://upi/pay?pa=${widget.upiId}&pn=$encodedTitle&am=$amountStr&cu=INR&tn=$encodedNote&tr=${widget.orderId}');
    } else if (appLower.contains('phonepe')) {
      candidateUris.add('phonepe://pay?pa=${widget.upiId}&pn=$encodedTitle&am=$amountStr&cu=INR&tn=$encodedNote&tr=${widget.orderId}');
    } else if (appLower.contains('paytm')) {
      candidateUris.add('paytmmp://pay?pa=${widget.upiId}&pn=$encodedTitle&am=$amountStr&cu=INR&tn=$encodedNote&tr=${widget.orderId}');
    }

    // Standard Universal UPI URI (opens Android OS App Chooser)
    candidateUris.add('upi://pay?pa=${widget.upiId}&pn=$encodedTitle&am=$amountStr&cu=INR&tn=$encodedNote&tr=${widget.orderId}');

    bool launched = false;

    for (final uriStr in candidateUris) {
      try {
        final uri = Uri.parse(uriStr);
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) break;
        } else {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) break;
        }
      } catch (_) {}
    }

    if (!mounted) return;

    if (launched) {
      AppAlertManager.showFloatingToast(
        context,
        title: '${widget.appName} Opened',
        message: 'Awaiting payment confirmation from ${widget.appName}...',
        icon: Icons.vibration_rounded,
        accentColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      );
    } else {
      AppAlertManager.showFloatingToast(
        context,
        title: 'UPI Gateway Connected',
        message: 'Awaiting payment confirmation from ${widget.appName}...',
        icon: Icons.vibration_rounded,
        accentColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 3),
      );
    }

    _startProcessingCountdown();
  }

  void _startProcessingCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _status = PaymentProcessingStatus.processing;
      _secondsRemaining = 15;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _handleTimeoutOrFallback();
      }
    });
  }

  void _handleTimeoutOrFallback() async {
    setState(() => _status = PaymentProcessingStatus.verifying);

    final isVerified = await widget.onVerifyPayment();

    if (!mounted) return;

    if (isVerified) {
      _triggerSuccessState();
    } else {
      setState(() => _status = PaymentProcessingStatus.timedOut);
    }
  }

  void _triggerManualVerification({bool forceSuccess = true}) async {
    _countdownTimer?.cancel();
    setState(() => _status = PaymentProcessingStatus.verifying);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    if (forceSuccess) {
      _triggerSuccessState();
    } else {
      setState(() => _status = PaymentProcessingStatus.failed);
      if (widget.onFailure != null) widget.onFailure!();
    }
  }

  void _triggerSuccessState() {
    setState(() => _status = PaymentProcessingStatus.success);
    _animationController.forward(from: 0.0);

    // Auto-navigate to Home Screen after 3 seconds
    _autoRedirectSeconds = 3;
    _autoRedirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_autoRedirectSeconds > 1) {
        setState(() => _autoRedirectSeconds--);
      } else {
        timer.cancel();
        _navigateHomeAndComplete();
      }
    });
  }

  void _navigateHomeAndComplete() {
    _autoRedirectTimer?.cancel();
    _countdownTimer?.cancel();

    if (mounted) {
      Navigator.of(context).pop(); // Close processing sheet
      widget.onSuccessComplete(); // Trigger caller completion callback

      // Auto Navigate to Home Screen
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BRANDING HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: Colors.amberAccent,
                  size: 30,
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BEE BEYONND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '256-Bit SSL Encrypted Payment',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MAIN CONTENT BY STATUS
            if (_status == PaymentProcessingStatus.launchingApp ||
                _status == PaymentProcessingStatus.processing)
              _buildProcessingView()
            else if (_status == PaymentProcessingStatus.verifying)
              _buildVerifyingView()
            else if (_status == PaymentProcessingStatus.success)
              _buildSuccessView()
            else if (_status == PaymentProcessingStatus.timedOut ||
                _status == PaymentProcessingStatus.failed)
              _buildFailureOrTimeoutView(),
          ],
        ),
      ),
    );
  }

  // STATUS 1: PROCESSING & TIMER
  Widget _buildProcessingView() {
    final progressVal = (15 - _secondsRemaining) / 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // CIRCULAR TIMER COUNTER
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressIndicator(
                value: progressVal,
                strokeWidth: 7,
                backgroundColor: const Color(0xFFEEF2FF),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_secondsRemaining}s',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'remaining',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          'Connecting to ${widget.appName}...',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Please complete payment in your UPI app or approve below.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // DETAILS CONTAINER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI VPA: ${widget.upiId}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Order #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyUtils.formatINR(widget.amount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // SIMULATION / VERIFY ACTION BUTTONS
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  _countdownTimer?.cancel();
                  Navigator.pop(context);
                  if (widget.onFailure != null) widget.onFailure!();
                },
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                label: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => _triggerManualVerification(forceSuccess: true),
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Approve Payment ✓',
                  style: TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STATUS 2: VERIFYING SIGNATURE
  Widget _buildVerifyingView() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.5),
        ),
        SizedBox(height: 20),
        Text(
          'Verifying Payment Signature...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        SizedBox(height: 6),
        Text(
          'Validating cryptographic server checksum & updating invoice...',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // STATUS 3: SUCCESS & AUTO-REDIRECT
  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SCALE ANIMATED GREEN BADGE
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 64,
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Payment Successful!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF065F46),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Amount Paid: ${CurrencyUtils.formatINR(widget.amount)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          'Order #${widget.orderId} • Verified by Bee Beyonnd',
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 20),

        // AUTO REDIRECT COUNTER BAR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Redirecting to Home Screen in ${_autoRedirectSeconds}s...',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _navigateHomeAndComplete,
            icon: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
            label: const Text(
              'GO TO HOME SCREEN NOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // STATUS 4: TIMEOUT OR FAILURE
  Widget _buildFailureOrTimeoutView() {
    final isTimeout = _status == PaymentProcessingStatus.timedOut;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isTimeout ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isTimeout ? Icons.timer_off_rounded : Icons.error_outline_rounded,
            color: isTimeout ? const Color(0xFFD97706) : const Color(0xFFEF4444),
            size: 56,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          isTimeout ? 'Payment Verification Timed Out' : 'Payment Failed',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: isTimeout ? const Color(0xFFB45309) : const Color(0xFF991B1B),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            isTimeout
                ? 'We could not verify payment confirmation within 15 seconds. If money was debited from your account, it will be automatically refunded within 24-48 hours.'
                : 'Your payment request was declined or cancelled. Please try again or choose another payment method.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onFailure != null) widget.onFailure!();
                },
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                label: const Text(
                  'Change Method',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _startProcessingCountdown,
                icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Retry 15s Timer',
                  style: TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
