import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Dummy database of WhatsApp Group URLs per Course
  static const Map<String, String> _courseWhatsAppGroups = {
    'jc_1': 'https://chat.whatsapp.com/ExampleBreathworkGroup', // Valid group link example
    'jc_2': '', // Empty link -> triggers "Group Not Available" dialog
    'jc_3': 'https://chat.whatsapp.com/ExampleVastuGroup', // Valid group link example
    'oc_1': 'https://chat.whatsapp.com/ExampleBreathworkGroup',
  };

  /// Main method to launch or handle WhatsApp group redirection safely
  static Future<void> joinWhatsAppGroup({
    required BuildContext context,
    required String courseId,
    required String courseTitle,
    String? customGroupUrl,
  }) async {
    try {
      final groupUrl = customGroupUrl ?? _courseWhatsAppGroups[courseId] ?? '';

      // Case 1: Group URL is empty or not created yet by owner
      if (groupUrl.trim().isEmpty) {
        if (context.mounted) {
          _showGroupNotAvailableDialog(context, courseTitle);
        }
        return;
      }

      final Uri uri = Uri.parse(groupUrl);

      // Case 2: Check if link can be launched
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched && context.mounted) {
          _showWhatsAppErrorDialog(
            context,
            'Could not launch WhatsApp application. Please verify WhatsApp is installed on your device.',
            groupUrl,
          );
        }
      } else {
        if (context.mounted) {
          _showWhatsAppErrorDialog(
            context,
            'Invalid or unhandled URL format: $groupUrl',
            groupUrl,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showWhatsAppErrorDialog(
          context,
          'An unexpected error occurred: ${e.toString()}',
          customGroupUrl ?? _courseWhatsAppGroups[courseId] ?? '',
        );
      }
    }
  }

  /// Dialog shown when WhatsApp group is not created yet
  static void _showGroupNotAvailableDialog(BuildContext context, String courseTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.forum_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WhatsApp Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Study Group Status',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_rounded, size: 14, color: Color(0xFF4338CA)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      courseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF312E81),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'Group Not Created Yet',
              style: TextStyle(
                color: Color(0xFF1E1B4B),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),

            const Text(
              'The course owner/instructor has not published the official WhatsApp study group link for this course yet. Please check back soon or contact support for assistance.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF312E81),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Go Back',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog shown when WhatsApp launch encounters a dynamic error
  static void _showWhatsAppErrorDialog(
    BuildContext context,
    String errorMessage,
    String linkUrl,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 26),
            SizedBox(width: 10),
            Text(
              'Connection Error',
              style: TextStyle(
                color: Color(0xFF1E1B4B),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to redirect to WhatsApp group link:',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Error Detail Box
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (linkUrl.isNotEmpty) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: linkUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group link copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF25D366)),
                label: const Text(
                  'Copy Link to Clipboard',
                  style: TextStyle(color: Color(0xFF128C7E), fontSize: 11.5),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
