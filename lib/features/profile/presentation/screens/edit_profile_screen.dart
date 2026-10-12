import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppTextField(label: 'Full Name', hint: 'Aarav Sharma'),
            const SizedBox(height: 16),
            const AppTextField(label: 'Email Address', hint: 'aarav.sharma@example.com'),
            const SizedBox(height: 16),
            const AppTextField(label: 'Phone Number', hint: '+91 98765 43210'),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Changes',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
