import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif_1',
      title: 'Antrenman Zamanı!',
      message: 'Bugünkü PPL Split (İtiş) antrenmanını tamamlamayı unutma. Gelişimini kaydet!',
      time: '10 dk önce',
      icon: Icons.fitness_center_rounded,
      iconColor: AppColors.primary,
      isRead: false,
    ),
    AppNotification(
      id: 'notif_2',
      title: 'Su İçme Hatırlatıcısı 💧',
      message: 'Hedefine ulaşmak için bir bardak su daha iç. Vücudunu susuz bırakma!',
      time: '2 saat önce',
      icon: Icons.local_drink_rounded,
      iconColor: Colors.blue,
      isRead: false,
    ),
    AppNotification(
      id: 'notif_3',
      title: 'Yeni Yemek Tarifi Eklendi 🥗',
      message: 'Diyet planına yüksek proteinli fırında sebzeli tavuk tarifi eklendi. Şimdi incele!',
      time: 'Dün',
      icon: Icons.restaurant_menu_rounded,
      iconColor: Colors.green,
      isRead: true,
    ),
    AppNotification(
      id: 'notif_4',
      title: 'Haftalık Başarı Özeti 🏆',
      message: 'Tebrikler! Geçen hafta hedeflenen tüm antrenmanları başarıyla tamamladın.',
      time: '3 gün önce',
      icon: Icons.emoji_events_rounded,
      iconColor: Colors.amber,
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
    CustomFeedback.show(context, 'Tüm bildirimler okundu işaretlendi', type: FeedbackType.success);
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    CustomFeedback.show(context, 'Tüm bildirimler temizlendi', type: FeedbackType.info);
  }

  void _toggleRead(AppNotification notification) {
    setState(() {
      notification.isRead = !notification.isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // 1. Dark Top Header (Matches Settings & Plans screen style exactly)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: topPadding + 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF131313),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: topPadding + 12.0),
                child: SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                UIcons.regularRounded.angle_left,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'BİLDİRİMLER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (_notifications.isNotEmpty)
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: _clearAll,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Temizle',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Subtitle Status Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unreadCount > 0 
                      ? '$unreadCount okunmamış bildirim'
                      : 'Tümünü okudunuz',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_notifications.isNotEmpty)
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: Row(
                      children: [
                        Icon(Icons.done_all_rounded, size: 14, color: AppColors.textPrimary),
                        const SizedBox(width: 4),
                        const Text(
                          'Hepsini Okundu Yap',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Notification Cards List
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return GestureDetector(
                        onTap: () => _toggleRead(notification),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: notification.isRead ? AppColors.surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: notification.isRead 
                                  ? AppColors.surfaceLight 
                                  : AppColors.primary.withOpacity(0.8),
                              width: notification.isRead ? 1.0 : 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(notification.isRead ? 0.01 : 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon Box
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: notification.iconColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    notification.icon,
                                    color: notification.iconColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Message Text Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            notification.title,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            notification.time,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Unread Green dot
                                if (!notification.isRead)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8, top: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 44,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hiç bildiriminiz bulunmuyor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              width: 140,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Geri Dön',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
