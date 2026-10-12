import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Your privacy is important to us. Bee Beyond collects only essential user information to provide course access, process orders, and improve your holistic wellness experience.',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
