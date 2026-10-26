import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/receipt_pdf_service.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/receipt_entity.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  ReceiptEntity _getReceiptForOrder(WidgetRef ref, OrderEntity order) {
    final currentUser = ref.watch(authStateProvider).user;
    final name = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Customer';
    final phone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : 'Customer Portal';
    final email = currentUser?.email.isNotEmpty == true ? currentUser!.email : 'customer@beebeyonnd.com';

    final subtotal = order.totalAmount / 1.18;
    return ReceiptEntity(
      receiptId: 'REC-2025-${order.orderId.replaceAll("ORD-", "")}',
      orderId: order.orderId,
      title: 'Order ${order.orderId}',
      type: 'PRODUCT',
      customerName: name,
      customerPhone: phone,
      customerEmail: email,
      deliveryAddress: 'Delivery Address on File (${order.orderId})',
      items: [
        ReceiptItem(
          name: 'Bee Beyonnd Order (${order.totalItems} Items)',
          quantity: order.totalItems,
          unitPrice: subtotal / (order.totalItems > 0 ? order.totalItems : 1),
        ),
      ],
      subtotal: subtotal,
      gstRate: 0.18,
      deliveryFee: 0.0,
      discount: 0.0,
      paymentMethod: 'UPI / Online Portal',
      date: order.orderDate,
    );
  }

  void _downloadInvoice(BuildContext context, WidgetRef ref, OrderEntity order) {
    ReceiptPdfService.downloadAndSaveReceiptPdf(context, _getReceiptForOrder(ref, order));
  }

  void _shareInvoice(BuildContext context, WidgetRef ref, OrderEntity order) {
    ReceiptPdfService.shareReceipt(context, _getReceiptForOrder(ref, order));
  }

  void _contactSupport(BuildContext context, OrderEntity order) {
    WhatsAppService.launchSupportChat(
      context: context,
      message: 'Hello Bee Beyonnd Support, I need assistance regarding my Order ${order.orderId}.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: CustomAppBar(
        title: 'Order Details & Tracking',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            onPressed: () {
              final order = orderAsync.value;
              if (order != null) _downloadInvoice(context, ref, order);
            },
            tooltip: 'Download Invoice',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            onPressed: () {
              final order = orderAsync.value;
              if (order != null) _shareInvoice(context, ref, order);
            },
            tooltip: 'Share Receipt',
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) {
          final isDelivered = order.status == 'Delivered';
          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate);
          final subtotal = order.totalAmount / 1.18;
          final totalGst = order.totalAmount - subtotal;
          final cgst = totalGst / 2;
          final sgst = totalGst / 2;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BRAND HEADER & ORDER OVERVIEW BANNER
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x204B489B),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.amberAccent,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.orderId,
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDelivered ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(
                                      color: isDelivered ? const Color(0xFF059669) : const Color(0xFFD97706),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Placed On: $formattedDate',
                              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total Paid: ${CurrencyUtils.formatINR(order.totalAmount)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. INTERACTIVE DELIVERY TRACKING PROGRESS STEPPER
                _buildDeliveryTrackingCard(order),

                const SizedBox(height: 18),

                // 3. PURCHASED ITEMS BREAKDOWN
                _buildPurchasedItemsCard(order),

                const SizedBox(height: 18),

                // 4. SHIPPING & DELIVERY ADDRESS CARD
                _buildShippingAddressCard(ref, order),

                const SizedBox(height: 18),

                // 5. BILLING & FINANCIAL SUMMARY
                _buildBillingSummaryCard(
                  subtotal: subtotal,
                  cgst: cgst,
                  sgst: sgst,
                  totalAmount: order.totalAmount,
                ),

                const SizedBox(height: 24),

                // 6. ACTION BUTTONS TOOLBAR
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () => _downloadInvoice(context, ref, order),
                        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                        label: const Text('DOWNLOAD INVOICE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 22),
                      onPressed: () => _contactSupport(context, order),
                      tooltip: 'Customer Support',
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error loading order details: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  // STEPPER TRACKING CARD
  Widget _buildDeliveryTrackingCard(OrderEntity order) {
    final isDelivered = order.status == 'Delivered';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DELIVERY TRACKING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 0.8)),
              Text(
                'Courier: BlueDart • AWB: BD-998241IN',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper Items
          _buildTrackingStep(title: 'Order Placed', subtitle: 'Order received & confirmed by seller', isCompleted: true, isLast: false),
          _buildTrackingStep(title: 'Processing & Packed', subtitle: 'Inspected and packaged at Mumbai Hub', isCompleted: true, isLast: false),
          _buildTrackingStep(title: 'Out for Delivery', subtitle: 'Handed over to courier delivery agent', isCompleted: true, isLast: false),
          _buildTrackingStep(
            title: isDelivered ? 'Delivered' : 'Estimated Delivery',
            subtitle: isDelivered ? 'Package delivered to recipient' : 'Expected delivery in 1-2 business days',
            isCompleted: isDelivered,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.circle_outlined,
                color: Colors.white,
                size: 13,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isCompleted ? AppColors.textPrimary : AppColors.textHint)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // PURCHASED ITEMS CARD
  Widget _buildPurchasedItemsCard(OrderEntity order) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ITEMS IN THIS ORDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 0.8)),
              Text('${order.totalItems} Items', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),

          _buildItemTile('Original Bach Rescue Remedy Drops (20ml)', '2x Qty • ₹450.00 each', '₹900.00'),
          const Divider(height: 16, color: AppColors.divider),
          _buildItemTile('Aura Cleansing Essential Healing Oil (50ml)', '1x Qty • ₹398.00 each', '₹398.00'),
        ],
      ),
    );
  }

  Widget _buildItemTile(String name, String qtyAndPrice, String total) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(qtyAndPrice, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Text(total, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  // ADDRESS CARD
  Widget _buildShippingAddressCard(WidgetRef ref, OrderEntity order) {
    final currentUser = ref.watch(authStateProvider).user;
    final name = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'Customer';
    final phone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : '';
    final email = currentUser?.email.isNotEmpty == true ? currentUser!.email : '';

    return Container(
      width: double.infinity,
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
          const Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('$phone ${email.isNotEmpty ? "• $email" : ""}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Registered Delivery Address for Order ${order.orderId}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3)),
        ],
      ),
    );
  }

  // BILLING SUMMARY CARD
  Widget _buildBillingSummaryCard({
    required double subtotal,
    required double cgst,
    required double sgst,
    required double totalAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Items Subtotal', CurrencyUtils.formatINR(subtotal)),
          const SizedBox(height: 6),
          _buildSummaryRow('CGST (9%)', CurrencyUtils.formatINR(cgst)),
          const SizedBox(height: 6),
          _buildSummaryRow('SGST (9%)', CurrencyUtils.formatINR(sgst)),
          const SizedBox(height: 6),
          _buildSummaryRow('Delivery Charges', 'FREE'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL AMOUNT PAID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text(
                CurrencyUtils.formatINR(totalAmount),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
