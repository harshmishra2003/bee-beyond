import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'upi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Checkout & Payment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Address', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            const AppTextField(label: 'Full Name', hint: 'Aarav Sharma'),
            const SizedBox(height: 12),
            const AppTextField(label: 'Phone Number', hint: '+91 9876543210'),
            const SizedBox(height: 12),
            const AppTextField(label: 'Delivery Address', hint: 'House No, Street, Landmark', maxLines: 2),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: AppTextField(label: 'City', hint: 'Mumbai')),
                SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'PIN Code', hint: '400001')),
              ],
            ),
            const SizedBox(height: 24),
            Text('Select Payment Method', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('UPI / Google Pay / PhonePe'),
                    value: 'upi',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                    activeColor: AppColors.primary,
                  ),
                  RadioListTile<String>(
                    title: const Text('Credit / Debit Card / NetBanking'),
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Cash on Delivery (COD)'),
                    value: 'cod',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Pay & Confirm Order',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully!')),
                );
                context.go(RoutePaths.orders);
              },
            ),
          ],
        ),
      ),
    );
  }
}
