import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildSection(String title, String content) {
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.65,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Header (Premium Dark Top Bar)
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
                          'GİZLİLİK POLİTİKASI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                      boxShadow: [
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
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Yasal Bilgilendirme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'İşbu Gizlilik Politikası, Alpamys AI platformu (bundan böyle "Platform" olarak anılacaktır) tarafından toplanan kişisel verilerin korunması, işlenmesi ve imha edilmesi süreçlerini KVKK (Kişisel Verilerin Korunması Kanunu) ve yürürlükteki uluslararası hukuk normlarına tam uyum içerisinde düzenlemek amacıyla akdedilmiştir.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildSection(
                    '1. Veri Sorumlusunun Kimliği',
                    'Alpamys AI, veri sorumlusu sıfatıyla hareket ederek, platform üyelerinin kişisel verilerini yasal sınırlar ve hukuki sınırlar dairesinde işlemektedir. Verileriniz, son derece güvenlikli dijital altyapılarda şifrelenmiş olarak saklanmakta ve kesinlikle üçüncü taraflara ticari bir meta olarak aktarılmamaktadır.',
                  ),
                  _buildSection(
                    '2. Toplanan ve İşlenen Kişisel Veriler',
                    'Platformu kullanımınız kapsamında; Ad Soyad, E-posta adresi, Telefon numarası, Yaş, Boy, Kilo ve Antrenman verileri gibi doğrudan üyeliğin tesisi ve kişiselleştirilmiş hizmet sunulması amacıyla elzem olan veriler yasal rızanız doğrultusunda işlenmektedir.',
                  ),
                  _buildSection(
                    '3. Veri İşleme Amaçları ve Hukuki Sebepler',
                    'Kişisel verileriniz, tarafınıza sunulan yapay zeka destekli antrenman ve sağlıklı beslenme rehberliği hizmetinin tam teşekküllü olarak ifa edilebilmesi, kullanıcı deneyiminin optimize edilmesi ve yasal mevzuattan kaynaklanan bilgi saklama yükümlülüklerimizin yerine getirilmesi amacıyla işlenmektedir.',
                  ),
                  _buildSection(
                    '4. Veri Güvenliği ve Saklama Süresi',
                    'Alpamys AI, kişisel verilerinizin yetkisiz kişilerce erişilmesini, kaybolmasını veya zarar görmesini önlemek amacıyla endüstri standardı şifreleme yöntemlerini ve güvenlik duvarlarını kullanmaktadır. Verileriniz, yasal üyelik süreniz boyunca ve yasal saklama süreleri elverdiği ölçüde muhafaza edilir.',
                  ),
                  _buildSection(
                    '5. İlgili Kişi Olarak Haklarınız',
                    'Kanunun ilgili maddeleri uyarınca dilediğiniz zaman; kişisel verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, eksik veya yanlış işlenmişse düzeltilmesini isteme ve sistemden verilerinizin tamamen silinmesini (Unutulma Hakkı) talep etme hakkına sahipsiniz. Başvurularınızı yasal kanallar aracılığıyla tarafımıza iletebilirsiniz.',
                  ),

                  // Legal signature placeholder
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Alpamys AI Hukuk Departmanı',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yürürlük Tarihi: 01.06.2026',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
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
