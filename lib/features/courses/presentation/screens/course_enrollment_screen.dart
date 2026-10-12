import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../../routing/route_paths.dart';
import '../providers/course_provider.dart';

class CountryPhoneRule {
  final String name;
  final String flag;
  final String code;
  final int minDigits;
  final int maxDigits;
  final String hintPattern;

  const CountryPhoneRule({
    required this.name,
    required this.flag,
    required this.code,
    required this.minDigits,
    required this.maxDigits,
    required this.hintPattern,
  });
}

class CourseEnrollmentScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseEnrollmentScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseEnrollmentScreen> createState() => _CourseEnrollmentScreenState();
}

class _CourseEnrollmentScreenState extends ConsumerState<CourseEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile Picture
  String? _selectedProfilePic;

  // Personal Fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _parentNameController = TextEditingController();

  String? _selectedGender;
  String? _selectedQualification;

  // Contact Fields
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Address Fields
  final _flatNoController = TextEditingController();
  final _street1Controller = TextEditingController();
  final _street2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _extraActivityController = TextEditingController();

  String? _selectedNationality;

  // Country Code Rules
  static const List<CountryPhoneRule> countryRules = [
    CountryPhoneRule(name: 'India', flag: '🇮🇳', code: '+91', minDigits: 10, maxDigits: 10, hintPattern: '9876543210'),
    CountryPhoneRule(name: 'USA / Canada', flag: '🇺🇸', code: '+1', minDigits: 10, maxDigits: 10, hintPattern: '2025550143'),
    CountryPhoneRule(name: 'United Kingdom', flag: '🇬🇧', code: '+44', minDigits: 10, maxDigits: 11, hintPattern: '7911123456'),
    CountryPhoneRule(name: 'UAE', flag: '🇦🇪', code: '+971', minDigits: 9, maxDigits: 9, hintPattern: '501234567'),
    CountryPhoneRule(name: 'Australia', flag: '🇦🇺', code: '+61', minDigits: 9, maxDigits: 9, hintPattern: '412345678'),
    CountryPhoneRule(name: 'Singapore', flag: '🇸🇬', code: '+65', minDigits: 8, maxDigits: 8, hintPattern: '81234567'),
    CountryPhoneRule(name: 'Germany', flag: '🇩🇪', code: '+49', minDigits: 10, maxDigits: 11, hintPattern: '15123456789'),
  ];

  late CountryPhoneRule _selectedCountry;
  late CountryPhoneRule _selectedAltCountry;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _qualificationOptions = [
    'High School',
    'Undergraduate',
    'Postgraduate',
    'Diploma',
    'Doctorate',
    'Other',
  ];
  final List<String> _nationalityOptions = [
    'Indian',
    'American',
    'British',
    'Emirati',
    'Australian',
    'Canadian',
    'German',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = countryRules.first;
    _selectedAltCountry = countryRules.first;
    _selectedGender = _genderOptions.first;
    _selectedQualification = 'Undergraduate';
    _selectedNationality = 'Indian';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _parentNameController.dispose();

    _phoneController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();

    _flatNoController.dispose();
    _street1Controller.dispose();
    _street2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _extraActivityController.dispose();
    super.dispose();
  }

  // Profile Picture Selector Dialog
  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Student Profile Picture', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF2F0FC), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedProfilePic = AssetPaths.userAvatar;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera photo captured successfully!'), backgroundColor: AppColors.primary),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF2F0FC), shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              ),
              title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedProfilePic = AssetPaths.userAvatar;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile image selected from gallery!'), backgroundColor: AppColors.primary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Date Picker
  Future<void> _selectDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
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

  // Mobile Validation Logic
  String? _validatePhone(String? value, CountryPhoneRule rule, {bool isOptional = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isOptional) return null;
      return 'Mobile number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (rule.code == '+91' && !RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Indian numbers must be 10 digits starting with 6-9';
    }

    if (digits.length < rule.minDigits || digits.length > rule.maxDigits) {
      return '${rule.name} phone number must be ${rule.minDigits == rule.maxDigits ? rule.minDigits : "${rule.minDigits}-${rule.maxDigits}"} digits';
    }
    return null;
  }

  // Submit Enrollment
  void _submitEnrollment(dynamic course) {
    if (_formKey.currentState?.validate() ?? false) {
      // Create Enrollment Data
      final studentName = '${_firstNameController.text.trim()} ${_middleNameController.text.trim()} ${_lastNameController.text.trim()}'.replaceAll('  ', ' ');
      final enrollmentId = 'ENR-2025-${(1000 + (widget.courseId.hashCode % 8999)).abs()}';

      // Navigate to Enrollment Confirmation Receipt Screen
      context.push(
        RoutePaths.enrollmentReceipt,
        extra: {
          'enrollmentId': enrollmentId,
          'studentName': studentName,
          'courseTitle': course.title,
          'courseCategory': course.category,
          'coursePrice': course.price,
          'email': _emailController.text.trim(),
          'phone': '${_selectedCountry.code} ${_phoneController.text.trim()}',
          'address': '${_flatNoController.text.trim()}, ${_street1Controller.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pincodeController.text.trim()}',
          'profilePic': _selectedProfilePic,
          'date': DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Course Enrollment Form'),
      body: courseAsync.when(
        data: (course) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Course Information Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x184B489B),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${course.duration} • ${CurrencyUtils.formatINR(course.price)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Student Profile Picture Upload Section
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF2F0FC),
                          border: Border.all(color: AppColors.primary, width: 2.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x144B489B),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _selectedProfilePic != null
                            ? ClipOval(
                                child: Image.asset(
                                  _selectedProfilePic!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.person_rounded,
                                    size: 54,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                size: 54,
                                color: AppColors.primary,
                              ),
                      ),
                      InkWell(
                        onTap: _showImagePickerModal,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Upload Student Profile Photo',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 1: PERSONAL DETAILS
                _buildSectionHeader('1. Personal Details', Icons.person_outline_rounded),
                const SizedBox(height: 12),

                _buildTextField(controller: _firstNameController, label: 'First Name *', hint: 'e.g. Rahul', validator: (v) => v == null || v.trim().isEmpty ? 'First Name is required' : null),
                const SizedBox(height: 12),

                _buildTextField(controller: _middleNameController, label: 'Middle Name (Optional)', hint: 'e.g. Kumar'),
                const SizedBox(height: 12),

                _buildTextField(controller: _lastNameController, label: 'Last Name *', hint: 'e.g. Sharma', validator: (v) => v == null || v.trim().isEmpty ? 'Last Name is required' : null),
                const SizedBox(height: 12),

                // Gender Dropdown
                _buildDropdown(
                  label: 'Gender *',
                  value: _selectedGender,
                  items: _genderOptions,
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
                const SizedBox(height: 12),

                // Date of Birth Field
                GestureDetector(
                  onTap: _selectDOB,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dobController,
                      label: 'Date of Birth (DOB) *',
                      hint: 'Select Date (dd/mm/yyyy)',
                      suffixIcon: Icons.calendar_month_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Date of Birth is required' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildTextField(controller: _parentNameController, label: "Parent / Guardian's Name *", hint: "Father / Mother's Name", validator: (v) => v == null || v.trim().isEmpty ? "Parent's Name is required" : null),
                const SizedBox(height: 12),

                // Qualification Dropdown
                _buildDropdown(
                  label: 'Educational Qualification *',
                  value: _selectedQualification,
                  items: _qualificationOptions,
                  onChanged: (v) => setState(() => _selectedQualification = v),
                ),

                const SizedBox(height: 24),

                // SECTION 2: CONTACT INFORMATION
                _buildSectionHeader('2. Contact Information', Icons.phone_android_rounded),
                const SizedBox(height: 12),

                // Primary Mobile Number with Country Code
                _buildPhoneFieldWithCountry(
                  label: 'Mobile Number *',
                  controller: _phoneController,
                  selectedRule: _selectedCountry,
                  onCountryChanged: (rule) => setState(() => _selectedCountry = rule!),
                  validator: (v) => _validatePhone(v, _selectedCountry),
                ),
                const SizedBox(height: 12),

                // Alternative Mobile Number
                _buildPhoneFieldWithCountry(
                  label: 'Alternative Mobile Number (Optional)',
                  controller: _altPhoneController,
                  selectedRule: _selectedAltCountry,
                  onCountryChanged: (rule) => setState(() => _selectedAltCountry = rule!),
                  validator: (v) => _validatePhone(v, _selectedAltCountry, isOptional: true),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address *',
                  hint: 'e.g. student@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email Address is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email address';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // SECTION 3: ADDRESS DETAILS
                _buildSectionHeader('3. Address & Nationality', Icons.location_on_outlined),
                const SizedBox(height: 12),

                _buildTextField(controller: _flatNoController, label: 'Flat / House / Building No. *', hint: 'e.g. Flat 302, Green Heights', validator: (v) => v == null || v.trim().isEmpty ? 'Building No. is required' : null),
                const SizedBox(height: 12),

                _buildTextField(controller: _street1Controller, label: 'Street Address 1 *', hint: 'e.g. MG Road, Near Central Park', validator: (v) => v == null || v.trim().isEmpty ? 'Street Address is required' : null),
                const SizedBox(height: 12),

                _buildTextField(controller: _street2Controller, label: 'Street Address 2 (Optional)', hint: 'Landmark / Area'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _cityController, label: 'City *', hint: 'e.g. Mumbai', validator: (v) => v == null || v.trim().isEmpty ? 'City is required' : null)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(controller: _stateController, label: 'State *', hint: 'e.g. Maharashtra', validator: (v) => v == null || v.trim().isEmpty ? 'State is required' : null)),
                  ],
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode / Postal Code *',
                  hint: 'e.g. 400001',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().length < 4 ? 'Enter a valid Pincode' : null,
                ),
                const SizedBox(height: 12),

                _buildDropdown(
                  label: 'Nationality *',
                  value: _selectedNationality,
                  items: _nationalityOptions,
                  onChanged: (v) => setState(() => _selectedNationality = v),
                ),
                const SizedBox(height: 12),

                _buildTextField(controller: _extraActivityController, label: 'Extra Curricular Activities / Hobbies (Optional)', hint: 'Yoga, Music, Reading, etc.'),

                const SizedBox(height: 28),

                // 3D Submit Enrollment Button
                ThreeDButton(
                  text: 'Submit & Complete Registration →',
                  fontSize: 15,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  onPressed: () => _submitEnrollment(course),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // Section Header Builder
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Custom Form TextField Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.primary, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
    );
  }

  // Dropdown Field Builder
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // Phone Field with Country Code Picker
  Widget _buildPhoneFieldWithCountry({
    required String label,
    required TextEditingController controller,
    required CountryPhoneRule selectedRule,
    required ValueChanged<CountryPhoneRule?> onCountryChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Selector
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle, width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CountryPhoneRule>(
                  value: selectedRule,
                  items: countryRules
                      .map((rule) => DropdownMenuItem(
                            value: rule,
                            child: Row(
                              children: [
                                Text(rule.flag, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(rule.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: onCountryChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Number Text Field
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                validator: validator,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: selectedRule.hintPattern,
                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
