import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../routing/route_paths.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background_wrapper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String? _selectedGender;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7B1FA2),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1C59),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _onRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions and Privacy Policy')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Show Smart Loading Dialog
      AppAlertManager.showLoading(context, message: "Creating Account...");

      try {
        await ref.read(authStateProvider.notifier).register(
          name: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          dob: _dobController.text.trim(),
          gender: _selectedGender,
        );

        // Pop the loading dialog
        if (mounted) {
           Navigator.of(context, rootNavigator: true).pop();
        }

        if (!mounted) return;

        // Show Success Dialog -> Directly Navigate to ONBOARDING for new registered users!
        AppAlertManager.showSuccess(
          context,
          title: 'Account Created!',
          description: 'Your Bee Beyonnd account has been created successfully. Welcome to a healthier journey!',
          autoDismissAfter: const Duration(seconds: 2),
          onAction: () {
            context.go(RoutePaths.onboarding);
          },
        );
      } catch (e) {
        // Pop the loading dialog
        if (mounted) {
           Navigator.of(context, rootNavigator: true).pop();
        }
        if (!mounted) return;

        // Show Smart Error Dialog
        AppAlertManager.showError(context, e, customTitle: "Registration Failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
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
              // Title
              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E1C59),
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Join Bee Beyonnd and take the first step\ntowards a healthier and happier you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757295),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 20),

              // 1. Full Name
              _buildCustomTextField(
                controller: _fullNameController,
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty ? 'Full Name is required' : null,
              ),

              const SizedBox(height: 12),

              // 2. Email Address
              _buildCustomTextField(
                controller: _emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.trim().isEmpty ? 'Email Address is required' : null,
              ),

              const SizedBox(height: 12),

              // 3. Phone Number
              _buildCustomTextField(
                controller: _phoneController,
                hintText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'Phone Number is required' : null,
              ),

              const SizedBox(height: 12),

              // 4. Password
              _buildCustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF5E5A80),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
              ),

              const SizedBox(height: 12),

              // 5. Confirm Password
              _buildCustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF5E5A80),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (val) {
                  if (val != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 6. Date of Birth
              GestureDetector(
                onTap: _selectDateOfBirth,
                child: AbsorbPointer(
                  child: _buildCustomTextField(
                    controller: _dobController,
                    hintText: 'Date of Birth (Optional)',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF7B61FF), size: 20),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 7. Select Gender Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  hintText: 'Select Gender (Optional)',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9E9BBD)),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF7B61FF), size: 20),
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
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5E5A80)),
                items: _genderOptions
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g, style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF2E1C59))),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedGender = val;
                  });
                },
              ),

              const SizedBox(height: 14),

              // Terms & Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 22,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: const Color(0xFF7B1FA2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          _agreedToTerms = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5E5A80)),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF673AB7)),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF673AB7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Gradient Register Button
              _buildGradientButton(
                text: 'Register',
                onTap: _onRegister,
              ),

              const SizedBox(height: 18),

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

              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF5E5A80),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.login),
                    child: Row(
                      children: [
                        Text(
                          'Login ',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF673AB7),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Color(0xFF673AB7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF2E1C59)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9E9BBD)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF7B61FF), size: 20),
        suffixIcon: suffixIcon,
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
