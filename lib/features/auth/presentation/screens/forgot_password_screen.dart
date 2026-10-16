import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background_wrapper.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      
      // Show Smart Loading Dialog
      AppAlertManager.showLoading(context, message: "Sending reset link...");
      
      try {
        await ref.read(authStateProvider.notifier).forgotPassword(_emailController.text.trim());
        
        // Pop the loading dialog
        if (mounted) {
           Navigator.of(context, rootNavigator: true).pop();
        }
        if (!mounted) return;

        setState(() {
          _isSubmitted = true;
        });
        
        AppAlertManager.showSuccess(
          context,
          title: 'Link Sent!',
          description: 'A password reset link has been sent to your email address.',
          autoDismissAfter: const Duration(seconds: 3),
        );
      } catch (e) {
        // Pop the loading dialog
        if (mounted) {
           Navigator.of(context, rootNavigator: true).pop();
        }
        if (!mounted) return;

        AppAlertManager.showError(context, e, customTitle: "Request Failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x30E0E0FF), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 24,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Top Lock Badge with Radiating Rays
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE7F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 32,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E1C59),
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                "No worries! Enter your email address\nand we'll send you a reset link.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757295),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 24),

              // Email Address Input
              _buildCustomTextField(
                controller: _emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Gradient Send Reset Link Button
              _buildGradientButton(
                text: 'Send Reset Link',
                onTap: _onSendResetLink,
              ),

              const SizedBox(height: 20),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE2E0EE))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'OR',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9E9BBD),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE2E0EE))),
                ],
              ),

              const SizedBox(height: 18),

              // Back to Login Link
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: Color(0xFF673AB7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back to Login',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF673AB7),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isSubmitted) ...[
                const SizedBox(height: 24),

                // Inbox Check Card Illustration Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2DDFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          color: Color(0xFF673AB7),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Check your inbox. The reset link will be sent shortly to your email address.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF5E5A80),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF2E1C59)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9E9BBD)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF7B61FF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF7F6FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE8E5FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7B1FA2),
            Color(0xFFC2185B),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x337B1FA2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
