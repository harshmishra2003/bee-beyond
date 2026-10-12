import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Change Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppTextField(label: 'Current Password', obscureText: true),
            const SizedBox(height: 16),
            const AppTextField(label: 'New Password', obscureText: true),
            const SizedBox(height: 16),
            const AppTextField(label: 'Confirm New Password', obscureText: true),
            const SizedBox(height: 32),
            AppButton(
              text: 'Update Password',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
