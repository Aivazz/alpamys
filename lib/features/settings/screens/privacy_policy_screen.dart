import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.65,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
      body: Column(
        children: [
          // Header (Premium Dark Top Bar)
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
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: topPadding + 12.0),
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
                          'GİZLİLİK POLİTİKASI',
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hukuki Mukaddeme (Lawyer intro card)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7).withOpacity(isDark ? 0.15 : 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Yasal Bilgilendirme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'İşbu Gizlilik Politikası, Alpamys AI platformu (bundan böyle "Platform" olarak anılacaktır) tarafından toplanan kişisel verilerin korunması, işlenmesi ve imha edilmesi süreçlerini KVKK (Kişisel Verilerin Korunması Kanunu) ve yürürlükteki uluslararası hukuk normlarına tam uyum içerisinde düzenlemek amacıyla akdedilmiştir.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildSection(
                    '1. Veri Sorumlusunun Kimliği',
                    'Alpamys AI, veri sorumlusu sıfatıyla hareket ederek, platform üyelerinin kişisel verilerini yasal sınırlar ve hukuki sınırlar dairesinde işlemektedir. Verileriniz, son derece güvenlikli dijital altyapılarda şifrelenmiş olarak saklanmakta ve kesinlikle üçüncü taraflara ticari bir meta olarak aktarılmamaktadır.',
                    isDark,
                  ),
                  _buildSection(
                    '2. Toplanan ve İşlenen Kişisel Veriler',
                    'Platformu kullanımınız kapsamında; Ad Soyad, E-posta adresi, Telefon numarası, Yaş, Boy, Kilo ve Antrenman verileri gibi doğrudan üyeliğin tesisi ve kişiselleştirilmiş hizmet sunulması amacıyla elzem olan veriler yasal rızanız doğrultusunda işlenmektedir.',
                    isDark,
                  ),
                  _buildSection(
                    '3. Veri İşleme Amaçları ve Hukuki Sebepler',
                    'Kişisel verileriniz, tarafınıza sunulan yapay zeka destekli antrenman ve sağlıklı beslenme rehberliği hizmetinin tam teşekküllü olarak ifa edilebilmesi, kullanıcı deneyiminin optimize edilmesi ve yasal mevzuattan kaynaklanan bilgi saklama yükümlülüklerimizin yerine getirilmesi amacıyla işlenmektedir.',
                    isDark,
                  ),
                  _buildSection(
                    '4. Veri Güvenliği ve Saklama Süresi',
                    'Alpamys AI, kişisel verilerinizin yetkisiz kişilerce erişilmesini, kaybolmasını veya zarar görmesini önlemek amacıyla endüstri standardı şifreleme yöntemlerini ve güvenlik duvarlarını kullanmaktadır. Verileriniz, yasal üyelik süreniz boyunca ve yasal saklama süreleri elverdiği ölçüde muhafaza edilir.',
                    isDark,
                  ),
                  _buildSection(
                    '5. İlgili Kişi Olarak Haklarınız',
                    'Kanunun ilgili maddeleri uyarınca dilediğiniz zaman; kişisel verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, eksik veya yanlış işlenmişse düzeltilmesini isteme ve sistemden verilerinizin tamamen silinmesini (Unutulma Hakkı) talep etme hakkına sahipsiniz. Başvurularınızı yasal kanallar aracılığıyla tarafımıza iletebilirsiniz.',
                    isDark,
                  ),

                  // Legal signature placeholder
                  const SizedBox(height: 12),
                  Divider(color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Alpamys AI Hukuk Departmanı',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yürürlük Tarihi: 01.06.2026',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
