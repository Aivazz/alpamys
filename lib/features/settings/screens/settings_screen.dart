import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/edit_profile_screen.dart';
import 'security_screen.dart';
import 'privacy_policy_screen.dart';
import '../../../core/theme/theme_provider.dart';
import 'location_setting_screen.dart';
import 'add_address_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 20.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.grey : Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final profileProvider = ProfileProvider();
    final themeProvider = ThemeProvider();

    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, child) {
        final isDark = themeProvider.isDarkMode;

        return ListenableBuilder(
          listenable: profileProvider,
          builder: (context, child) {
            final profileData = profileProvider.profileData;
            final name = profileData['name']?.toString() ?? '';
            final email = profileData['email']?.toString() ?? '';
            final location = profileData['location']?.toString() ?? 'Almatı';

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (scrolls with the page, centered title)
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: topPadding + 80,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
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
                                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      UIcons.regularRounded.angle_left,
                                      size: 16,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'AYARLAR',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. User Profile Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Profile Photo with edit button overlay
                        Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                                image: DecorationImage(
                                  image: profileProvider.getAvatarImage(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EditProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    UIcons.regularRounded.edit,
                                    size: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Name and info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isNotEmpty ? name : 'Yükleniyor...',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email.isNotEmpty ? email : 'E-posta yükleniyor...',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Sections of Settings
                _buildSectionHeader('Hesap', isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: UIcons.regularRounded.user,
                        title: 'Kişisel Bilgiler',
                        subtitle: 'Profil detayları ve antrenman seviyesi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _SettingsTile(
                        icon: UIcons.regularRounded.lock,
                        title: 'Güvenlik ve Şifre',
                        subtitle: 'Şifre sıfırlama ve hesap koruması',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecurityScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _SettingsTile(
                        icon: UIcons.regularRounded.marker,
                        title: 'Adres Ekle',
                        subtitle: 'Gönderim adresi ekleme ve yönetimi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddAddressScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader('Uygulama Tercihleri', isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: UIcons.regularRounded.eye,
                        title: 'Karanlık Mod',
                        subtitle: 'Gece antrenmanları için koyu tasarım',
                        trailing: Switch.adaptive(
                          value: isDark,
                          onChanged: (val) {
                            themeProvider.toggleTheme(val);
                            CustomFeedback.show(
                              context,
                              val ? 'Karanlık mod aktif edildi!' : 'Aydınlık moda geçildi!',
                              type: FeedbackType.info,
                            );
                          },
                          activeColor: isDark ? Colors.white : Colors.black,
                          activeTrackColor: AppColors.primary,
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),
                      _SettingsTile(
                        icon: UIcons.regularRounded.marker,
                        title: 'Konum Bilgisi',
                        subtitle: location,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationSettingScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader('Destek & Yasal', isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: UIcons.regularRounded.interrogation,
                        title: 'Yardım ve Destek',
                        subtitle: 'Sıkça sorulan sorular ve bize ulaşın',
                        onTap: () => _showHelpBottomSheet(context, isDark),
                      ),
                      const SizedBox(height: 10),
                      _SettingsTile(
                        icon: UIcons.regularRounded.document,
                        title: 'Gizlilik Politikası',
                        subtitle: 'Kişisel verilerinizin korunması',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Version info & trademark
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Alpamys AI v1.0.0',
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2026 Alpamys. Tüm Hakları Saklıdır.',
                        style: TextStyle(
                          color: isDark ? Colors.grey.withOpacity(0.6) : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        );
      },
    );
  },
);
}

  void _showHelpBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131313) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 24),
              // Header title
              Text(
                'YARDIM VE DESTEK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Alpamys ekibi 7/24 hizmetinizde. Bize aşağıdaki kanallardan ulaşabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Interactive Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // WhatsApp
                    _buildSupportCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF25D366),
                      title: 'WhatsApp Canlı Destek',
                      subtitle: 'Anında mesajlaşma ve hızlı çözüm',
                      trailing: 'BAĞLAN',
                      isDark: isDark,
                      onTap: () {
                        CustomFeedback.show(context, 'WhatsApp hattına yönlendiriliyorsunuz...', type: FeedbackType.info);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email Support
                    _buildSupportCard(
                      icon: Icons.mail_outline_rounded,
                      color: const Color(0xFF3B82F6),
                      title: 'E-posta İletişim',
                      subtitle: 'destek@alpamys.kz',
                      trailing: 'KOPYALA',
                      isDark: isDark,
                      onTap: () {
                        CustomFeedback.show(context, 'E-posta adresi kopyalandı!', type: FeedbackType.success);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Direct Call
                    _buildSupportCard(
                      icon: Icons.phone_forwarded_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Çağrı Merkezi',
                      subtitle: '+7 (700) 000-00-00',
                      trailing: 'ARA',
                      isDark: isDark,
                      onTap: () {
                        CustomFeedback.show(context, 'Müşteri hizmetleri aranıyor...', type: FeedbackType.info);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // FAQ Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SIKÇA SORULAN SORULAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick FAQs
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFAQCard(
                      question: 'Şifremi Nasıl Değiştiririm?',
                      answer: 'Güvenlik ve Şifre bölümünden anında yeni bir şifre talep edebilirsiniz.',
                      isDark: isDark,
                    ),
                    _buildFAQCard(
                      question: 'Abonelik İptali Nasıl Yapılır?',
                      answer: 'Profil / Aboneliklerim ekranından dilediğiniz an iptal edebilirsiniz.',
                      isDark: isDark,
                    ),
                    _buildFAQCard(
                      question: 'Yapay Zeka Nasıl Çalışır?',
                      answer: 'Gelişmiş algoritmalarımız form durumunuza göre antrenman yazar.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String trailing,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailing,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing
            trailing ?? Icon(
              UIcons.regularRounded.angle_right,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
