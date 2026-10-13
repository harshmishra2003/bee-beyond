import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../providers/order_provider.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Delivered', 'Processing', 'Cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Orders & Transactions'),
      body: ordersAsync.when(
        data: (allOrders) {
          final filteredOrders = allOrders.where((order) {
            // Category filter
            if (_selectedFilter != 'All' &&
                order.status.toLowerCase() != _selectedFilter.toLowerCase()) {
              return false;
            }
            // Search query filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              return order.orderId.toLowerCase().contains(query) ||
                  order.status.toLowerCase().contains(query);
            }
            return true;
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 12),

              // 1. SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID or status...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textHint),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. MULTI-FILTER CHIPS
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(60),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          filter == 'All' ? 'All Orders' : filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // LIST COUNT HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Orders History (${filteredOrders.length})',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. ORDERS LIST
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final isDelivered = order.status == 'Delivered';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C4B489B),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => context.push('${RoutePaths.orderDetail}?id=${order.orderId}'),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                AssetPaths.beeBeyondImage2,
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.spa_rounded, color: AppColors.primary, size: 18),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                order.orderId,
                                                style: AppTextStyles.titleMedium.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDelivered ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: isDelivered ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                                            ),
                                            child: Text(
                                              order.status.toUpperCase(),
                                              style: TextStyle(
                                                color: isDelivered ? const Color(0xFF059669) : const Color(0xFFD97706),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 9.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      Text(
                                        'Placed On: ${AppDateUtils.formatDate(order.orderDate)} • ${order.totalItems} Item${order.totalItems > 1 ? 's' : ''}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),

                                      const Divider(height: 20, color: AppColors.divider),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('AMOUNT PAID', style: TextStyle(fontSize: 9, color: AppColors.textHint, fontWeight: FontWeight.bold)),
                                              Text(
                                                CurrencyUtils.formatINR(order.totalAmount),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              const Text(
                                                'View Details & Tracking',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error loading orders: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
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
                border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.5),
              ),
              child: const Icon(Icons.local_shipping_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Orders Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'No orders match your search or filter query.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
