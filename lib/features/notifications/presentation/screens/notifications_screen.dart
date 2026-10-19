import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'All';

  int getUnreadCount(List<NotificationItem> notifications) {
    return notifications.where((n) => n.isUnread).length;
  }

  List<NotificationItem> getFilteredNotifications(List<NotificationItem> notifications) {
    if (_selectedFilter == 'Unread') {
      return notifications.where((n) => n.isUnread).toList();
    } else if (_selectedFilter == 'Courses') {
      return notifications.where((n) => n.category == 'courses').toList();
    } else if (_selectedFilter == 'Orders') {
      return notifications.where((n) => n.category == 'orders').toList();
    } else if (_selectedFilter == 'Offers') {
      return notifications.where((n) => n.category == 'promos').toList();
    }
    return notifications;
  }

  void _markAllAsRead() {
    ref.read(notificationsProvider.notifier).markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read ✓'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _clearAllNotifications(List<NotificationItem> currentList) {
    if (currentList.isEmpty) return;

    final backup = List<NotificationItem>.from(currentList);
    ref.read(notificationsProvider.notifier).clearAll();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications cleared'),
        backgroundColor: const Color(0xFF312E81),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () {
            ref.read(notificationsProvider.notifier).restoreBackup(backup);
          },
        ),
      ),
    );
  }

  void _removeNotification(NotificationItem item) {
    final currentList = ref.read(notificationsProvider);
    final index = currentList.indexWhere((n) => n.id == item.id);
    if (index == -1) return;

    ref.read(notificationsProvider.notifier).removeNotification(item.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.title}" removed'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () {
            final backup = List<NotificationItem>.from(ref.read(notificationsProvider));
            backup.insert(index, item);
            ref.read(notificationsProvider.notifier).restoreBackup(backup);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final list = getFilteredNotifications(notifications);
    final groups = ['Today', 'Yesterday', 'Earlier'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF1E1B4B),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount NEW',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              tooltip: 'Mark All Read',
              icon: const Icon(Icons.done_all_rounded, color: Color(0xFF059669), size: 22),
              onPressed: _markAllAsRead,
            ),
            IconButton(
              tooltip: 'Clear All',
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 22),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Notifications?'),
                    content: const Text('Are you sure you want to delete all notifications?'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearAllNotifications(notifications);
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    count: notifications.length,
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Unread',
                    count: unreadCount,
                    isSelected: _selectedFilter == 'Unread',
                    onTap: () => setState(() => _selectedFilter = 'Unread'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Courses 🎓',
                    count: notifications.where((n) => n.category == 'courses').length,
                    isSelected: _selectedFilter == 'Courses',
                    onTap: () => setState(() => _selectedFilter = 'Courses'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Orders 📦',
                    count: notifications.where((n) => n.category == 'orders').length,
                    isSelected: _selectedFilter == 'Orders',
                    onTap: () => setState(() => _selectedFilter = 'Orders'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Offers 🏷️',
                    count: notifications.where((n) => n.category == 'promos').length,
                    isSelected: _selectedFilter == 'Offers',
                    onTap: () => setState(() => _selectedFilter = 'Offers'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Notifications List
          Expanded(
            child: list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, gIndex) {
                      final groupName = groups[gIndex];
                      final groupItems = list.where((n) => n.group == groupName).toList();

                      if (groupItems.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                            child: Row(
                              children: [
                                Text(
                                  groupName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ...groupItems.map(
                            (item) => Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                                    SizedBox(width: 6),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (_) => _removeNotification(item),
                              child: _NotificationCard(
                                item: item,
                                onTap: () {
                                  ref.read(notificationsProvider.notifier).toggleExpandAndRead(item.id);
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEEF2FF),
                border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A6366F1),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 46,
                color: Color(0xFF4338CA),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Caught Up!',
              style: TextStyle(
                color: Color(0xFF1E1B4B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have no notifications matching this filter at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF312E81),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.home);
                }
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 16),
              label: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF312E81),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                });
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Show All Notifications',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF312E81) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF312E81) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF312E81).withAlpha(76),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amberAccent : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1E1B4B) : const Color(0xFF334155),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final styleProps = _getStyleProps(item.category);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isUnread ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isExpanded
              ? AppColors.primary
              : (item.isUnread ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0)),
          width: item.isExpanded || item.isUnread ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isExpanded
                ? AppColors.primary.withAlpha(30)
                : (item.isUnread ? const Color(0x184338CA) : const Color(0x0A000000)),
            blurRadius: item.isExpanded || item.isUnread ? 8 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon Avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: styleProps.gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: styleProps.primaryColor.withAlpha(90),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(styleProps.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),

                    // Content Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Notification Title
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: item.isExpanded ? null : 1,
                                  overflow: item.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color(0xFF1E1B4B),
                                    fontSize: 13.5,
                                    fontWeight: item.isUnread || item.isExpanded ? FontWeight.w900 : FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Time Stamp & Expand Arrow Icon
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      color: item.isUnread ? const Color(0xFF4338CA) : const Color(0xFF94A3B8),
                                      fontSize: 10.5,
                                      fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    item.isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Notification Message
                          Text(
                            item.message,
                            maxLines: item.isExpanded ? null : 2,
                            overflow: item.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: TextStyle(
                              color: item.isUnread ? const Color(0xFF334155) : const Color(0xFF64748B),
                              fontSize: 12.5,
                              height: 1.35,
                              fontWeight: item.isUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Unread Dot Indicator
                    if (item.isUnread) ...[
                      const SizedBox(width: 6),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6366F1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // EXPANDED METADATA DETAIL FOOTER
                if (item.isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: styleProps.primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            color: styleProps.primaryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textHint),
                          SizedBox(width: 4),
                          Text(
                            'In-App Alert • Tap to collapse',
                            style: TextStyle(fontSize: 10, color: AppColors.textHint, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _NotificationCategoryStyle _getStyleProps(String category) {
    switch (category) {
      case 'courses':
        return const _NotificationCategoryStyle(
          icon: Icons.school_rounded,
          primaryColor: Color(0xFF6366F1),
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
        );
      case 'orders':
        return const _NotificationCategoryStyle(
          icon: Icons.local_shipping_rounded,
          primaryColor: Color(0xFF10B981),
          gradient: LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
        );
      case 'promos':
        return const _NotificationCategoryStyle(
          icon: Icons.local_offer_rounded,
          primaryColor: Color(0xFFF59E0B),
          gradient: LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
        );
      case 'community':
        return const _NotificationCategoryStyle(
          icon: Icons.chat_bubble_rounded,
          primaryColor: Color(0xFF0288D1),
          gradient: LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF0277BD)],
          ),
        );
      case 'live':
        return const _NotificationCategoryStyle(
          icon: Icons.live_tv_rounded,
          primaryColor: Color(0xFFEF4444),
          gradient: LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
        );
      default:
        return const _NotificationCategoryStyle(
          icon: Icons.notifications_rounded,
          primaryColor: AppColors.primary,
          gradient: AppColors.primaryGradient,
        );
    }
  }
}

class _NotificationCategoryStyle {
  final IconData icon;
  final Color primaryColor;
  final LinearGradient gradient;

  const _NotificationCategoryStyle({
    required this.icon,
    required this.primaryColor,
    required this.gradient,
  });
}
