import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/status_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Controllers
  final _fullNameController = TextEditingController(text: 'Aarav Sharma');
  final _dobController = TextEditingController(text: '15/08/1996');

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';

  // Contact Controllers
  final _emailController = TextEditingController(text: 'aarav.sharma@example.com');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _altPhoneController = TextEditingController(text: '+91 91234 56789');

  // Wellness Profile
  String _selectedHealthInterest = 'Bach Flower Therapy';
  String _selectedOccupation = 'Working Professional';

  // Residence Address
  String _selectedState = 'Maharashtra';
  String _selectedCity = 'Mumbai';
  final _addressController = TextEditingController(text: 'Flat 302, Green Heights, MG Road');
  final _pincodeController = TextEditingController(text: '400001');

  bool _agreeToPrivacyRules = true;
  bool _isSaving = false;

  final Map<String, List<String>> _indiaStateCityData = const {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Aurangabad', 'Solapur'],
    'Delhi (NCT)': ['New Delhi', 'Central Delhi', 'East Delhi', 'North Delhi', 'South Delhi'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Varanasi', 'Agra', 'Noida', 'Ghaziabad'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur'],
  };

  final List<String> _healthInterests = [
    'Bach Flower Therapy',
    'Ayurveda & Prakriti',
    'Vastu Shastra Consultation',
    'Mindfulness & Breathwork',
    'Herbal Remedies & Nutrition',
  ];

  final List<String> _occupations = [
    'Working Professional',
    'Student',
    'Practitioner / Doctor',
    'Homemaker',
    'Business Owner',
    'Other',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // DatePicker for DOB
  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1940),
      lastDate: now,
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

  // Image Picker BottomSheet Modal
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Profile Picture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Take Photo via Camera'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera opened! Photo updated.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery opened! Photo updated.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Searchable State Modal
  void _showStatePickerModal() {
    final states = _indiaStateCityData.keys.toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Select State / Territory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: states.length,
              itemBuilder: (ctx, i) {
                final st = states[i];
                return ListTile(
                  title: Text(st, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: st == _selectedState ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedState = st;
                      _selectedCity = _indiaStateCityData[st]!.first;
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Searchable City Modal
  void _showCityPickerModal() {
    final cities = _indiaStateCityData[_selectedState] ?? ['Mumbai'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Select City ($_selectedState)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (ctx, i) {
                final ct = cities[i];
                return ListTile(
                  title: Text(ct, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: ct == _selectedCity ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedCity = ct;
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSaveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the validation errors in the form.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreeToPrivacyRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Data Privacy & Wellness Rules.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSaving = false);

      StatusDialog.show(
        context,
        title: 'Profile Updated Successfully!',
        description: 'Your student profile & wellness preferences have been updated in the Bee Beyond database.',
        isSuccess: true,
        autoDismissAfter: const Duration(seconds: 2),
        onDismiss: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: const CustomAppBar(title: 'Edit Student Profile'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR & STUDENT ID BANNER
              _buildAvatarSection(),

              const SizedBox(height: 20),

              // SECTION 1: PERSONAL INFORMATION
              _buildSectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF6366F1),
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name *',
                    hint: 'e.g. Aarav Sharma',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Full Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: _buildInputDecoration('Gender *'),
                          items: ['Male', 'Female', 'Other']
                              .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedGender = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedBloodGroup,
                          decoration: _buildInputDecoration('Blood Group'),
                          items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                              .map((bg) => DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedBloodGroup = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dobController,
                        label: 'Date of Birth *',
                        hint: 'DD/MM/YYYY',
                        suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Date of Birth is required' : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 2: CONTACT & AUTH DETAILS
              _buildSectionCard(
                title: 'Contact & Verification',
                icon: Icons.contact_phone_outlined,
                iconColor: const Color(0xFF10B981),
                children: [
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address *',
                    hint: 'aarav@example.com',
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
                    validator: (v) => v == null || !v.contains('@') ? 'Valid Email required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Mobile Phone Number *',
                    hint: '+91 9876543210',
                    keyboardType: TextInputType.phone,
                    suffixIcon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                    validator: (v) => v == null || v.trim().length < 10 ? 'Valid Phone required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _altPhoneController,
                    label: 'Alternate Contact Number (Optional)',
                    hint: '+91 9123456789',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 3: WELLNESS & HOLISTIC PREFERENCES
              _buildSectionCard(
                title: 'Wellness Profile & Preferences',
                icon: Icons.spa_outlined,
                iconColor: const Color(0xFFD97706),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedHealthInterest,
                    decoration: _buildInputDecoration('Primary Wellness Interest *'),
                    items: _healthInterests
                        .map((hi) => DropdownMenuItem(value: hi, child: Text(hi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedHealthInterest = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedOccupation,
                    decoration: _buildInputDecoration('Profession / Occupation'),
                    items: _occupations
                        .map((occ) => DropdownMenuItem(value: occ, child: Text(occ, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedOccupation = v!),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 4: RESIDENTIAL ADDRESS & LOCATION
              _buildSectionCard(
                title: 'Residential Address & Location',
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF0288D1),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showStatePickerModal,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: TextEditingController(text: _selectedState),
                              label: 'State *',
                              suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showCityPickerModal,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: TextEditingController(text: _selectedCity),
                              label: 'City *',
                              suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _addressController,
                    label: 'Flat No, Street, Landmark Address *',
                    hint: 'House No, Building, Street',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _pincodeController,
                    label: 'PIN Code *',
                    hint: '400001',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().length < 6 ? '6-digit PIN Code required' : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // RULES, REGULATIONS & PRIVACY DISCLAIMER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreeToPrivacyRules,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _agreeToPrivacyRules = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'I confirm that all personal and health profile details provided above are accurate and I agree to the Bee Beyond Data Privacy Guidelines & Terms.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _onSaveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SAVE PROFILE CHANGES',
                              style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // AVATAR & ID SECTION
  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x204B489B), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    AssetPaths.userAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person_rounded, size: 58, color: AppColors.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Aarav Sharma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Text('STUDENT ID: BY-2025-8821 • VERIFIED PROFILE ✓', style: TextStyle(color: Color(0xFF059669), fontSize: 9.5, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // REUSABLE SECTION CARD
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
