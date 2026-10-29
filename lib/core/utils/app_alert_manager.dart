import 'package:flutter/material.dart';
import '../errors/error_handler.dart';
import '../errors/failures.dart';
import '../widgets/status_dialog.dart';

/// A centralized manager to show smart, context-aware human-readable dialogue boxes.
class AppAlertManager {
  
  /// Intercepts any error/exception, converts it into a typed [Failure], 
  /// and shows a beautifully formatted [StatusDialog].
  static void showError(
    BuildContext context, 
    dynamic error, {
    VoidCallback? onRetry,
    String? customTitle,
    String? customMessage,
  }) {
    final failure = ErrorHandler.handleException(error);
    
    // Default Fallbacks
    String title = customTitle ?? "Oops! Something went wrong";
    String description = customMessage ?? failure.message;
    String actionText = "Okay";
    VoidCallback? action = onRetry;

    // Smart Mapping based on Failure Types
    if (failure is NetworkFailure) {
      title = customTitle ?? "No Internet Connection";
      description = customMessage ?? "Please check your Wi-Fi or mobile data and try again.";
      actionText = "Retry";
      action = onRetry;

    } else if (failure is TimeoutFailure) {
      title = customTitle ?? "Request Timed Out";
      description = customMessage ?? "The server took too long to respond. Please try again later.";
      actionText = "Retry";
      action = onRetry;

    } else if (failure is AuthFailure) {
      title = customTitle ?? "Authentication Error";
      description = failure.message.isNotEmpty 
          ? failure.message 
          : (customMessage ?? "Please check your email and password.");
      actionText = "Okay";
      action = onRetry;

    } else if (failure is ConflictFailure) {
      title = customTitle ?? "Already Exists";
      description = customMessage ?? failure.message;
      actionText = "Okay";

    } else if (failure is NotFoundFailure) {
      title = customTitle ?? "Not Found";
      description = customMessage ?? "The requested resource could not be found.";
      actionText = "Okay";

    } else if (failure is ValidationFailure) {
      title = customTitle ?? "Invalid Input";
      description = customMessage ?? failure.message;
      actionText = "Check Again";

    } else if (failure is PermissionFailure) {
      title = customTitle ?? "Permission Denied";
      description = customMessage ?? "We need certain permissions to complete this action.";
      actionText = "Okay"; 
      
    } else if (failure is PaymentFailure) {
      title = customTitle ?? "Payment Failed";
      description = customMessage ?? "We couldn't process your payment. Please check your card details.";
      actionText = "Try Another Method";
    }

    // Show the Dialog
    StatusDialog.show(
      context,
      title: title,
      description: description,
      isSuccess: false,
      isLoading: false,
      actionText: actionText,
      onAction: action,
    );
  }

  /// Quickly show a success dialog anywhere in the app.
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String description,
    String? actionText,
    VoidCallback? onAction,
    Duration? autoDismissAfter,
  }) {
    StatusDialog.show(
      context,
      title: title,
      description: description,
      isSuccess: true,
      isLoading: false,
      actionText: actionText ?? "Great!",
      onAction: onAction,
      autoDismissAfter: autoDismissAfter,
      // If autoDismissAfter is provided, we must map the onAction to onDismiss 
      // so it triggers automatically when the timer runs out!
      onDismiss: autoDismissAfter != null ? onAction : null,
    );
  }

  /// Show a loading dialog that prevents user interaction until popped.
  static void showLoading(BuildContext context, {String message = "Please wait..."}) {
    StatusDialog.show(
      context,
      title: "Processing",
      description: message,
      isSuccess: true, // Color theme fallback
      isLoading: true, // Triggers the loading indicator instead of icon
    );
  }

  /// Shows a sleek, modern floating toast with custom title, message, icon, optional action button,
  /// and a working dismiss/close button.
  static void showFloatingToast(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.task_alt_rounded,
    Color backgroundColor = const Color(0xFF0F172A),
    Color accentColor = const Color(0xFF10B981),
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Title & Description Text Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Button (e.g. PRINT / VIEW)
              if (actionLabel != null && onAction != null) ...[
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onAction();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Working Cancel / Dismiss Close Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
