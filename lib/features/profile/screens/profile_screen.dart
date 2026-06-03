import 'package:flutter/material.dart';
import '../../../common_widgets/icons/uicons.dart';
import '../../../common_widgets/media/cached_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/profile_provider.dart';
import '../services/order_history_service.dart';
import '../services/gym_visit_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPress;

  const ProfileScreen({
    super.key,
    this.onBackPress,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileProvider().fetchProfile();
      OrderHistoryService().load();
      GymVisitService().load();
    });
  }

  Widget _buildStatItem(String val, String unit, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: R.sp(12),
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: R.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: R.sp(12),
            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'in_transit':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'delivered':
        return 'Teslim Edildi';
      case 'in_transit':
        return 'Yolda';
      default:
        return 'Hazırlanıyor';
    }
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildOrdersSection(bool isDark) {
    return ListenableBuilder(
      listenable: OrderHistoryService(),
      builder: (context, _) {
        final orders = OrderHistoryService().orders;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('SİPARİŞLERİM', isDark),
            if (orders.isEmpty)
              _buildEmptyCard(
                icon: Icons.shopping_bag_outlined,
                message: 'Henüz hiç sipariş vermediniz.\nMarketten ürün ekleyerek başlayabilirsiniz.',
                isDark: isDark,
              )
            else
              ...orders.take(3).map((order) => _buildOrderCard(order, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(OrderItem order, bool isDark) {
    final statusColor = _statusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Product image
            CachedImage(
              url: order.productImage,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(12),
              errorChild: Icon(Icons.shopping_bag_outlined,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 28),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (order.size.isNotEmpty) ...[
                        Text(
                          order.size,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '  •  ',
                          style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                        ),
                      ],
                      Text(
                        '${order.quantity}x ${order.price}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _statusLabel(order.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _relativeDate(order.orderedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymVisitsSection(bool isDark) {
    return ListenableBuilder(
      listenable: GymVisitService(),
      builder: (context, _) {
        final visits = GymVisitService().visits;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('SON GİRİŞ YAPILAN SALONLAR', isDark),
            if (visits.isEmpty)
              _buildEmptyCard(
                icon: Icons.fitness_center_outlined,
                message: 'Henüz hiçbir salona giriş yapmadınız.\nAlpamys Pass ile salona girince burada görünecek.',
                isDark: isDark,
              )
            else
              ...visits.take(3).map((visit) => _buildGymVisitCard(visit, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildGymVisitCard(GymVisit visit, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Gym image
            CachedImage(
              url: visit.gymImage,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(12),
              errorChild: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.gymName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Success badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Giriş Başarılı',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _relativeDate(visit.visitedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String message,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    R.init(context);
    final profileProvider = ProfileProvider();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: profileProvider,
      builder: (context, child) {
        final profileData = profileProvider.profileData;
        final name = profileData['name']?.toString() ?? '';
        final weight = profileData['weight']?.toString() ?? '75';
        final weightUnit = profileData['weightUnit']?.toString() ?? 'KG';
        final height = profileData['height']?.toString() ?? '175';
        final heightUnit = profileData['heightUnit']?.toString() ?? 'CM';
        final age = profileData['age']?.toString() ?? '25';

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
          body: SafeArea(
            child: profileProvider.isLoading && name.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: R.screenPaddingH, vertical: R.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PROFİL',
                              style: TextStyle(
                                fontSize: R.sp(17),
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            IconButton(
                              icon: UIconEdit(size: 24, color: isDark ? Colors.white : Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Profile Image & Info
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 54,
                                backgroundImage: profileProvider.getAvatarImage(),
                                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name.isNotEmpty ? name : 'Yükleniyor...',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: _buildStatItem(weight, weightUnit.toLowerCase(), 'Kilo', isDark)),
                              Container(
                                width: 1,
                                height: 36,
                                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                              ),
                              Expanded(child: _buildStatItem(height, heightUnit.toLowerCase(), 'Boy', isDark)),
                              Container(
                                width: 1,
                                height: 36,
                                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                              ),
                              Expanded(child: _buildStatItem(age, 'yaş', 'Yaş', isDark)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Orders Section ──────────────────────────
                        _buildOrdersSection(isDark),
                        const SizedBox(height: 28),

                        // ── Gym Visits Section ──────────────────────
                        _buildGymVisitsSection(isDark),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
