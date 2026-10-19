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
    final isFiltered = _selectedFilter != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
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
                size: 40,
                color: Color(0xFF4338CA),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No Filtered Notifications' : 'All Caught Up!',
              style: const TextStyle(
                color: Color(0xFF1E1B4B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'You have no notifications matching the "$_selectedFilter" filter.'
                  : 'You have no new notifications at the moment.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFiltered) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      side: const BorderSide(color: Color(0xFF312E81), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF312E81), size: 15),
                    label: const Text(
                      'Show All',
                      style: TextStyle(color: Color(0xFF312E81), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF312E81),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 15),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF312E81) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF312E81) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withAlpha(50) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 9.5,
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

  Color _getCategoryColor() {
    switch (item.category) {
      case 'courses':
        return const Color(0xFF6366F1);
      case 'orders':
        return const Color(0xFF10B981);
      case 'promos':
        return const Color(0xFFF59E0B);
      case 'live':
        return const Color(0xFFEF4444);
      case 'community':
        return const Color(0xFF25D366);
      default:
        return const Color(0xFF312E81);
    }
  }

  IconData _getCategoryIcon() {
    switch (item.category) {
      case 'courses':
        return Icons.school_rounded;
      case 'orders':
        return Icons.local_shipping_rounded;
      case 'promos':
        return Icons.local_offer_rounded;
      case 'live':
        return Icons.live_tv_rounded;
      case 'community':
        return Icons.forum_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isUnread ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isUnread ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
          width: item.isUnread ? 1.5 : 1.0,
        ),
        boxShadow: item.isUnread
            ? const [
                BoxShadow(
                  color: Color(0x0C6366F1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon Circle
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: catColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getCategoryIcon(), color: catColor, size: 20),
                    ),
                    const SizedBox(width: 10),

                    // Title & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: const Color(0xFF1E1B4B),
                                    fontWeight: item.isUnread ? FontWeight.w900 : FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              if (item.isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.time,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message Text (Expandable)
                Text(
                  item.message,
                  maxLines: item.isExpanded ? null : 2,
                  overflow: item.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
