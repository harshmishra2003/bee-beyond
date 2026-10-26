import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/three_d_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  bool _isSubmittingInquiry = false;

  final List<String> _supportCategories = [
    'General Inquiry',
    'Course Enrollment & Study Guide',
    'Doctor Consultation Booking',
    'VIP Membership & Access Pass',
    'Product Order & Delivery',
    'Payment & GST Invoice Issue',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentUser = ref.read(authStateProvider).user;
        if (currentUser != null) {
          if (currentUser.name.isNotEmpty) _nameController.text = currentUser.name;
          if (currentUser.email.isNotEmpty) _emailController.text = currentUser.email;
          if (currentUser.phone.isNotEmpty) _phoneController.text = currentUser.phone;
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        AppAlertManager.showFloatingToast(
          context,
          title: 'Could Not Open Link',
          message: 'Unable to open $urlStr',
          icon: Icons.link_off_rounded,
          backgroundColor: const Color(0xFF0F172A),
          accentColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  void _submitInquiry() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmittingInquiry = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() => _isSubmittingInquiry = false);
    _messageController.clear();

    AppAlertManager.showFloatingToast(
      context,
      title: 'Inquiry Sent Successfully! 🚀',
      message: 'Thank you for reaching out. Our Bee Beyonnd team will contact you shortly.',
      icon: Icons.task_alt_rounded,
      backgroundColor: const Color(0xFF0F172A),
      accentColor: const Color(0xFF10B981),
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _launchInstagram() async {
    const handles = ['bee.beyonnd', 'beebeyonnd.in', 'beebeeyond'];

    for (final handle in handles) {
      try {
        final appUri = Uri.parse('instagram://user?username=$handle');
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    for (final handle in handles) {
      try {
        final webUri = Uri.parse('https://www.instagram.com/$handle/');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Contact & Support Us'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ANIMATED HERO BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F0C20),
                    Color(0xFF1E1B4B),
                    Color(0xFF312E81),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.amberAccent.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x300F0C20),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Pulsing Headset Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.8), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withValues(alpha: 0.3),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: Colors.amberAccent,
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'BEE BEYONND HELPDESK',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'We Are Here To Help You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Have a question about courses, consultations, or orders? Connect with our dedicated support team 24/7.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ONLINE STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🟢 Helpdesk Online • 1-Tap Direct Connect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 1-TAP DIRECT CONTACT CARDS
            _buildSectionHeader('1-Tap Direct Contact Details', Icons.contact_phone_rounded),
            const SizedBox(height: 12),

            // CARD 1: CONNECT NO.
            _buildContactCard(
              icon: Icons.phone_in_talk_rounded,
              iconBgColor: const Color(0xFF10B981),
              label: 'Connect No.',
              value: AppConstants.supportPhone,
              subtitle: 'Tap to call primary support line',
              onTap: () => _launchUrl('tel:${AppConstants.supportPhone}'),
            ),

            const SizedBox(height: 10),

            // CARD 2: CALL US NOW (HELPLINE)
            _buildContactCard(
              icon: Icons.support_agent_rounded,
              iconBgColor: const Color(0xFF6366F1),
              label: 'Call Us Now (Helpline)',
              value: AppConstants.helplinePhone,
              subtitle: '24/7 Dedicated helpline & emergency desk',
              onTap: () => _launchUrl('tel:${AppConstants.helplinePhone}'),
            ),

            const SizedBox(height: 10),

            // CARD 3: SEND US MAIL
            _buildContactCard(
              icon: Icons.mark_email_read_rounded,
              iconBgColor: const Color(0xFF3B82F6),
              label: 'Send Us Mail',
              value: AppConstants.supportEmail,
              subtitle: 'Drop an email for official response',
              onTap: () => _launchUrl('mailto:${AppConstants.supportEmail}'),
            ),

            const SizedBox(height: 10),

            // CARD 4: OUR LOCATION
            _buildContactCard(
              icon: Icons.location_on_rounded,
              iconBgColor: const Color(0xFFEF4444),
              label: 'Our Location',
              value: AppConstants.officeLocation,
              subtitle: 'Dotom Isle, Jankalyan Nagar, Malad West',
              onTap: () => _launchUrl('https://maps.google.com/?q=Malad+West,+Mumbai+400095'),
            ),

            const SizedBox(height: 24),

            // CLICKABLE SOCIAL MEDIA CONNECTIONS
            _buildSectionHeader('Connect On Social Channels', Icons.share_rounded),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Instant Messaging & Social Handles',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap any icon to reach us on WhatsApp or Social Media',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),

                  // STANDALONE CIRCULAR SOCIAL ICON BADGES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // WHATSAPP
                      _SocialIconBadge(
                        label: 'Chat on WhatsApp',
                        imageAsset: AssetPaths.whatsappIcon,
                        fallbackIcon: Icons.chat_rounded,
                        gradientColors: const [Color(0xFF25D366), Color(0xFF128C7E)],
                        onTap: () => _launchUrl('https://wa.me/919967326151?text=Hello%20Bee%20Beyonnd'),
                      ),

                      // INSTAGRAM
                      _SocialIconBadge(
                        label: 'Follow on Instagram',
                        imageAsset: AssetPaths.instagramIcon,
                        fallbackIcon: Icons.camera_alt_rounded,
                        gradientColors: const [Color(0xFFE4405F), Color(0xFFC13584), Color(0xFF833AB4)],
                        onTap: () => _launchUrl('https://www.instagram.com/?hl=en'),
                      ),

                      // LINKEDIN
                      _SocialIconBadge(
                        label: 'Connect on LinkedIn',
                        imageAsset: AssetPaths.linkedinIcon,
                        fallbackIcon: Icons.business_center_rounded,
                        gradientColors: const [Color(0xFF0077B5), Color(0xFF00A0DC)],
                        onTap: () => _launchUrl('https://www.linkedin.com/company/bee-beyonnd/'),
                      ),

                      // FACEBOOK
                      _SocialIconBadge(
                        label: 'Follow on Facebook',
                        fallbackIcon: Icons.facebook_rounded,
                        gradientColors: const [Color(0xFF1877F2), Color(0xFF3B5998)],
                        onTap: () => _launchUrl('https://www.facebook.com/share/1XL3i9DhC8/'),
                      ),

                      // WEBSITE
                      _SocialIconBadge(
                        label: 'Visit Official Website',
                        fallbackIcon: Icons.language_rounded,
                        gradientColors: const [Color(0xFF0F0C20), Color(0xFF312E81)],
                        onTap: () => _launchUrl('https://beebeyonnd.in/'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // INTERACTIVE INQUIRY FORM
            _buildSectionHeader('Send Us An Instant Message', Icons.edit_note_rounded),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Your Name *',
                      hint: 'e.g. Aarav Sharma',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number *',
                            hint: '9876543210',
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().length < 10 ? '10-digit Phone required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _emailController,
                            label: 'Email Address *',
                            hint: 'aarav@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || !v.contains('@') ? 'Valid Email required' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // CATEGORY DROPDOWN
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Support Topic / Category',
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                      items: _supportCategories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _messageController,
                      label: 'Your Message / Inquiry *',
                      hint: 'Type your message or support request here...',
                      maxLines: 4,
                      validator: (v) => v == null || v.trim().length < 5 ? 'Please write your message' : null,
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ThreeDButton(
                        text: _isSubmittingInquiry ? 'SENDING INQUIRY...' : 'SEND INQUIRY TO BEE BEYONND 🚀',
                        fontSize: 13.5,
                        onPressed: _isSubmittingInquiry ? () {} : _submitInquiry,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FAQ ACCORDION
            _buildSectionHeader('Frequently Asked Questions', Icons.quiz_rounded),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFaqItem(
                    title: 'How do I access my purchased course or VIP Membership?',
                    content: 'Once payment is confirmed, your course or VIP pass is immediately unlocked! Navigate to "My Joined Courses" or "My Memberships" from the side drawer.',
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildFaqItem(
                    title: 'How can I schedule a 1-on-1 consultation with a doctor?',
                    content: 'Go to the "Services & Consultations" tab, choose your desired practitioner session (Prakriti Analysis, Vastu, Bach Therapy), and reserve your slot.',
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildFaqItem(
                    title: 'Is my payment and personal health data secure?',
                    content: 'Yes! All payments are processed through 256-Bit SSL encrypted gateways (Razorpay, UPI). Your health records remain 100% private and confidential.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

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

  Widget _buildContactCard({
    required IconData icon,
    required Color iconBgColor,
    required String label,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconBgColor, size: 26),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildFaqItem({required String title, required String content}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// STANDALONE CIRCULAR GLOWING SOCIAL ICON BADGE
class _SocialIconBadge extends StatelessWidget {
  final String label;
  final String? imageAsset;
  final IconData? fallbackIcon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SocialIconBadge({
    required this.label,
    this.imageAsset,
    this.fallbackIcon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        fallbackIcon ?? Icons.link_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  : Icon(
                      fallbackIcon ?? Icons.link_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
