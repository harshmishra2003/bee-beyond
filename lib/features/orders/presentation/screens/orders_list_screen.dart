import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alert_manager.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../routing/route_paths.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';
import 'receipt_preview_screen.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final Set<String> _expandedOrderIds = {};

  final List<String> _filters = [
    'All',
    'Delivered',
    'In Transit',
    'Digital Access',
    'Processing'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String orderId) {
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
      } else {
        _expandedOrderIds.add(orderId);
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppAlertManager.showFloatingToast(
      context,
      title: 'Order ID Copied',
      message: 'ID "$text" copied to clipboard',
      icon: Icons.content_copy_rounded,
      backgroundColor: const Color(0xFF0F172A),
      accentColor: const Color(0xFF10B981),
    );
  }

  void _openReceiptPreview(OrderEntity order) {
    context.push('${RoutePaths.receiptPreview}?id=${order.orderId}');
  }

  List<OrderEntity> _getFallbackOrders() {
    final now = DateTime.now();
    return [
      OrderEntity(
        orderId: 'ORD-446F8D',
        status: 'Delivered',
        totalAmount: 8496.0,
        orderDate: now.subtract(const Duration(days: 3)),
        totalItems: 1,
        title: 'Ayurvedic Wellness Herbal Kit',
        imageUrl: AssetPaths.ancientHealing,
        paymentStatus: 'PAID',
        paymentMethod: 'Razorpay UPI / Online',
        subtotalAmount: 9440.0,
        discountAmount: 944.0,
        shippingFee: 0.0,
        taxAmount: 0.0,
      ),
      OrderEntity(
        orderId: 'ORD-882A1C',
        status: 'In Transit',
        totalAmount: 2150.0,
        orderDate: now.subtract(const Duration(hours: 5)),
        totalItems: 2,
        title: 'Bach Flower Rescue Remedy Set',
        imageUrl: AssetPaths.bachFlower,
        paymentStatus: 'PAID',
        paymentMethod: 'Prepaid Razorpay',
        subtotalAmount: 2400.0,
        discountAmount: 250.0,
        shippingFee: 0.0,
        taxAmount: 0.0,
      ),
      OrderEntity(
        orderId: 'ORD-771B98',
        status: 'Digital Access',
        totalAmount: 14999.0,
        orderDate: now.subtract(const Duration(days: 12)),
        totalItems: 1,
        title: 'Vastu Shastra & Geometry Diploma',
        imageUrl: AssetPaths.vastu,
        paymentStatus: 'PAID',
        paymentMethod: 'Online Bank Transfer',
        subtotalAmount: 16999.0,
        discountAmount: 2000.0,
        shippingFee: 0.0,
        taxAmount: 0.0,
      ),
      OrderEntity(
        orderId: 'ORD-312E55',
        status: 'Processing',
        totalAmount: 3450.0,
        orderDate: now.subtract(const Duration(hours: 2)),
        totalItems: 1,
        title: 'Tibetan Singing Bowl Kit',
        imageUrl: AssetPaths.placeholder,
        paymentStatus: 'PAID',
        paymentMethod: 'Razorpay Cards',
        subtotalAmount: 3800.0,
        discountAmount: 350.0,
        shippingFee: 0.0,
        taxAmount: 0.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RoutePaths.home);
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4982A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'BEE BEYONND WELLNESS',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF6845C4),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4982A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'My Orders & Transactions',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF006A37)),
                    tooltip: 'All Receipts',
                    onPressed: () {
                      context.push(RoutePaths.receipts);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ordersAsync.when(
        skipLoadingOnRefresh: true,
        data: (apiOrders) {
          final allOrders = apiOrders.isNotEmpty ? apiOrders : _getFallbackOrders();

          final filteredOrders = allOrders.where((order) {
            if (_selectedFilter != 'All') {
              final sel = _selectedFilter.toLowerCase();
              final status = order.status.toLowerCase();
              if (sel == 'delivered' && !status.contains('deliver') && !status.contains('success')) {
                return false;
              }
              if (sel == 'in transit' && !status.contains('transit') && !status.contains('ship') && !status.contains('out')) {
                return false;
              }
              if (sel == 'digital access' && !status.contains('access') && !status.contains('unlock') && !status.contains('course')) {
                return false;
              }
              if (sel == 'processing' && !status.contains('process') && !status.contains('pend')) {
                return false;
              }
            }

            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              return order.orderId.toLowerCase().contains(query) ||
                  order.status.toLowerCase().contains(query) ||
                  order.title.toLowerCase().contains(query);
            }
            return true;
          }).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(ordersListProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'Search orders, courses, remedies...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        else
                          const Icon(Icons.tune_rounded, color: Color(0xFF94A3B8), size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. STATUS FILTER CHIPS ROW
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;

                        int count = allOrders.length;
                        if (filter != 'All') {
                          count = allOrders.where((o) {
                            final status = o.status.toLowerCase();
                            final f = filter.toLowerCase();
                            if (f == 'delivered') return status.contains('deliver') || status.contains('success');
                            if (f == 'in transit') return status.contains('transit') || status.contains('ship') || status.contains('out');
                            if (f == 'digital access') return status.contains('access') || status.contains('unlock');
                            if (f == 'processing') return status.contains('process');
                            return false;
                          }).length;
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6845C4) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6845C4) : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF6845C4).withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                if (filter == 'Delivered')
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF059669),
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else if (filter == 'In Transit')
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD97706),
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else if (filter == 'Digital Access')
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF7C3AED),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Text(
                                  filter,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. BEE NECTAR REWARDS BANNER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD97706),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.hive_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Bee Nectar',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '850 Pts',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            AppAlertManager.showFloatingToast(
                              context,
                              title: 'Bee Nectar Rewards',
                              message: 'You have 850 points available for checkout discount!',
                              icon: Icons.card_giftcard_rounded,
                              backgroundColor: const Color(0xFF78350F),
                              accentColor: const Color(0xFFF59E0B),
                            );
                          },
                          child: Text(
                            'Redeem >',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. ORDERS HISTORY SECTION HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Orders History',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${filteredOrders.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6845C4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_rounded,
                              color: Color(0xFF059669),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Live Courier Sync',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 5. ORDERS LIST CARDS
                  if (filteredOrders.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final isExpanded = _expandedOrderIds.contains(order.orderId);
                        return _buildExpandableOrderCard(order, isExpanded);
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => _buildEmptyState(),
      ),
    );
  }

  Widget _buildExpandableOrderCard(OrderEntity order, bool isExpanded) {
    final statusLower = order.status.toLowerCase();

    Color topAccentColor = const Color(0xFF059669);
    Color statusBadgeBg = const Color(0xFFECFDF5);
    Color statusBadgeText = const Color(0xFF059669);
    IconData statusIcon = Icons.check_circle_rounded;
    String statusDisplay = 'DELIVERED';

    if (statusLower.contains('transit') || statusLower.contains('out') || statusLower.contains('ship')) {
      topAccentColor = const Color(0xFFF59E0B);
      statusBadgeBg = const Color(0xFFFEF3C7);
      statusBadgeText = const Color(0xFFB45309);
      statusIcon = Icons.local_shipping_rounded;
      statusDisplay = 'OUT FOR DELIVERY';
    } else if (statusLower.contains('access') || statusLower.contains('unlock') || statusLower.contains('digital')) {
      topAccentColor = const Color(0xFF7C3AED);
      statusBadgeBg = const Color(0xFFF3E8FF);
      statusBadgeText = const Color(0xFF6D28D9);
      statusIcon = Icons.verified_rounded;
      statusDisplay = 'ACCESS UNLOCKED';
    } else if (statusLower.contains('process') || statusLower.contains('pend')) {
      topAccentColor = const Color(0xFF0288D1);
      statusBadgeBg = const Color(0xFFE0F2FE);
      statusBadgeText = const Color(0xFF0288D1);
      statusIcon = Icons.sync_rounded;
      statusDisplay = 'PROCESSING';
    }

    final itemTitle = order.title.isNotEmpty ? order.title : 'Ayurvedic Wellness Herbal Kit';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Accent Color Strip
          Container(
            height: 3.5,
            decoration: BoxDecoration(
              color: topAccentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Order ID & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.orderId,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _copyToClipboard(order.orderId),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBadgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 12, color: statusBadgeText),
                          const SizedBox(width: 4),
                          Text(
                            statusDisplay,
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: statusBadgeText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Main Info Row: Thumbnail Image + Title & Meta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Thumbnail
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: topAccentColor.withValues(alpha: 0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: topAccentColor.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: order.imageUrl.isNotEmpty
                            ? Image.asset(
                                order.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackThumbnail(topAccentColor),
                              )
                            : _buildFallbackThumbnail(topAccentColor),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Placed ${AppDateUtils.formatDate(order.orderDate)} • ${order.totalItems} Item${order.totalItems > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price & Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyUtils.formatINR(order.totalAmount),
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),

                    Row(
                      children: [
                        // Invoice Button
                        OutlinedButton(
                          onPressed: () => _openReceiptPreview(order),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Invoice',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Dropdown Arrow Expand Button
                        ElevatedButton(
                          onPressed: () => _toggleExpand(order.orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6845C4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isExpanded ? 'Hide Details' : 'Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // EXPANDABLE BREAKDOWN PANEL (In-Place Dropdown)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Paid Status Header Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDER BREAKDOWN & BILLING',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: order.paymentStatus.contains('PAID')
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    order.paymentStatus.contains('PAID')
                                        ? Icons.verified_rounded
                                        : Icons.pending_rounded,
                                    size: 11,
                                    color: order.paymentStatus.contains('PAID')
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB45309),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.paymentStatus,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: order.paymentStatus.contains('PAID')
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 16, color: Color(0xFFE2E8F0)),

                        // Price Items Breakdown
                        _buildBreakdownRow(
                          label: 'Items Subtotal',
                          value: CurrencyUtils.formatINR(
                            order.subtotalAmount > 0
                                ? order.subtotalAmount
                                : order.totalAmount,
                          ),
                        ),
                        if (order.discountAmount > 0)
                          _buildBreakdownRow(
                            label: 'Discount / Coupon',
                            value: '- ${CurrencyUtils.formatINR(order.discountAmount)}',
                            valueColor: const Color(0xFF059669),
                          ),
                        _buildBreakdownRow(
                          label: 'Delivery / Shipping Fee',
                          value: order.shippingFee > 0
                              ? CurrencyUtils.formatINR(order.shippingFee)
                              : 'FREE',
                          valueColor: order.shippingFee == 0 ? const Color(0xFF059669) : null,
                        ),
                        if (order.taxAmount > 0)
                          _buildBreakdownRow(
                            label: 'Taxes & Charges',
                            value: CurrencyUtils.formatINR(order.taxAmount),
                          ),

                        const Divider(height: 16, color: Color(0xFFE2E8F0)),

                        _buildBreakdownRow(
                          label: 'Grand Total Amount',
                          value: CurrencyUtils.formatINR(order.totalAmount),
                          isBold: true,
                        ),

                        const SizedBox(height: 6),

                        // Payment Method & Date Note
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payment_rounded, size: 14, color: Color(0xFF6845C4)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Payment via ${order.paymentMethod}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(Color accentColor) {
    return Container(
      color: accentColor.withValues(alpha: 0.12),
      child: Center(
        child: Icon(Icons.inventory_2_rounded, size: 26, color: accentColor),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 12 : 11.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 13 : 11.5,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: valueColor ?? (isBold ? const Color(0xFF0F172A) : const Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF2F0FC),
                border: Border.all(color: const Color(0xFF6845C4).withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.local_shipping_outlined,
                  size: 44, color: Color(0xFF6845C4)),
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your completed course enrollments, VIP membership subscriptions, and product orders will appear here dynamically.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go(RoutePaths.courses);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6845C4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Explore Courses & Remedies →',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
