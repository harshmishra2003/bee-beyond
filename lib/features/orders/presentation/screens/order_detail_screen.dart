import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Order Details'),
      body: orderAsync.when(
        data: (order) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.orderId}', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text('Status: ${order.status}', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      Text('Placed On: ${AppDateUtils.formatDateTime(order.orderDate)}', style: AppTextStyles.bodyMedium),
                      const Divider(height: 24),
                      Text('Amount Paid: ${CurrencyUtils.formatINR(order.totalAmount)}', style: AppTextStyles.titleLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
