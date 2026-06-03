import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Local active plan state
  String _activeWorkoutPlanId = 'ppl';
  String _activeNutritionPlanId = 'weight_loss';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFutureFeatureDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(UIcons.regularRounded.sparkles, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sleek, Premium Dark Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF131313),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 24),
            child: Column(
              children: [
                SizedBox(
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
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'PLANLARIM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hedefinize en uygun antrenman ve beslenme programını seçin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Custom Segments / Tab Bar (Sleek Capsule Design)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                tabs: const [
                  Tab(text: 'Antrenman Splitleri'),
                  Tab(text: 'Beslenme & Makro'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWorkoutPlansTab(),
                _buildNutritionPlansTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlansTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // AI Premium Smart Plan Card
        _buildAICoachCard(
          title: 'Akıllı Yapay Zeka Planı',
          description: 'Metabolizmanıza ve hedeflerinize göre tamamen size özel antrenman şeması ve set/tekrar sayıları oluşturur.',
          buttonText: 'Yapay Zeka ile Plan Yap',
          icon: UIcons.regularRounded.sparkles,
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            _showFutureFeatureDialog(
              context,
              'Yapay Zeka Antrenör Planı',
              'Gelecek Fonksiyon: Bu tuş, AI asistanı ile özel bir diyaloğu başlatarak size özel set, tekrar ve dinlenme sürelerine sahip kişiselleştirilmiş 7 günlük bir antrenman takvimi oluşturacaktır.',
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HAZIR PROGRAMLAR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF9CA3AF),
                letterSpacing: 1.0,
              ),
            ),
            Icon(Icons.tune_rounded, size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
        const SizedBox(height: 12),

        // Plan Card: PPL Split
        _buildWorkoutPlanCard(
          id: 'ppl',
          title: 'Push-Pull-Legs (İtiş-Çekiş-Bacak)',
          subtitle: 'Klasik Hacim ve Güç Spliti',
          description: 'Haftada 3 gün antrenman yaparak kas gruplarının dinlenmesine fırsat veren, bilimsel olarak en verimli bölünme.',
          daysText: 'Haftada 3 Gün',
          levelText: 'Orta / İleri Seviye',
          isActive: _activeWorkoutPlanId == 'ppl',
          onActivate: () {
            setState(() {
              _activeWorkoutPlanId = 'ppl';
            });
            CustomFeedback.show(context, 'PPL Split antrenman planı aktif edildi!', type: FeedbackType.success);
          },
          onDetails: () {
            _showFutureFeatureDialog(
              context,
              'PPL Split Detayları',
              'Gelecek Fonksiyon: Günlük itiş (göğüs, omuz, arka kol), çekiş (sırt, ön kol) ve bacak/karın egzersizlerinin tam gelişim grafikleri ve set geçmişi detayları gösterilecektir.',
            );
          },
        ),

        const SizedBox(height: 16),

        // Plan Card: Full Body
        _buildWorkoutPlanCard(
          id: 'full_body',
          title: 'Full Body (Tüm Vücut) Güç',
          subtitle: 'Tüm Vücut Egzersiz Şeması',
          description: 'Her antrenmanda tüm ana kas gruplarını temel birleşik hareketlerle çalıştırarak maksimum kalori yakımı sağlar.',
          daysText: 'Haftada 2-3 Gün',
          levelText: 'Yeni Başlayanlar / Öğrenciler',
          isActive: _activeWorkoutPlanId == 'full_body',
          onActivate: () {
            setState(() {
              _activeWorkoutPlanId = 'full_body';
            });
            CustomFeedback.show(context, 'Full Body antrenman planı aktif edildi!', type: FeedbackType.success);
          },
          onDetails: () {
            _showFutureFeatureDialog(
              context,
              'Full Body Detayları',
              'Gelecek Fonksiyon: Squat, Deadlift ve Bench Press gibi temel güç egzersizlerinde maksimum tek tekrar (1RM) hedefleri ve haftalık ağırlık artış şablonları yüklenecektir.',
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNutritionPlansTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // AI Premium Nutrition Plan Card
        _buildAICoachCard(
          title: 'Akıllı Beslenme Danışmanı',
          description: 'Kilo hedefinize göre günlük kalori ihtiyacınızı hesaplar ve size özel makroları böler.',
          buttonText: 'Hedeften Kalori Hesapla',
          icon: UIcons.regularRounded.sparkles,
          gradient: const LinearGradient(
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            _showFutureFeatureDialog(
              context,
              'Yapay Zeka Beslenme Planı',
              'Gelecek Fonksiyon: Bu buton, boy, kilo, metabolizma hızı ve aktivite düzeyinizi girmenizi sağlayan bir form açacak ve ardından günlük protein, yağ, karbonhidrat hedefinizi otomatik güncelleyecektir.',
            );
          },
        ),

        const SizedBox(height: 20),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DİYET VE BESLENME ŞABLONLARI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF9CA3AF),
                letterSpacing: 1.0,
              ),
            ),
            Icon(Icons.restaurant_menu_rounded, size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
        const SizedBox(height: 12),

        // Plan Card: Fat Loss
        _buildNutritionPlanCard(
          id: 'weight_loss',
          title: 'Kilo Verme ve Yağ Yakımı',
          subtitle: 'Kalori Açığı & Yüksek Protein',
          description: 'Kas kaybını önlemek için yüksek protein oranına sahip, gün boyu zinde kalmanızı sağlayan düşük karbonhidratlı diyet planı.',
          kcalText: '1800 kcal / Gün',
          macroSplitText: 'Yüksek Protein, Düşük Karbonhidrat',
          proteinPercent: 0.35,
          carbPercent: 0.40,
          fatPercent: 0.25,
          isActive: _activeNutritionPlanId == 'weight_loss',
          onActivate: () {
            setState(() {
              _activeNutritionPlanId = 'weight_loss';
            });
            CustomFeedback.show(context, 'Kilo verme beslenme planı aktif edildi!', type: FeedbackType.success);
          },
          onDetails: () {
            _showFutureFeatureDialog(
              context,
              'Yağ Yakımı Diyeti Detayları',
              'Gelecek Fonksiyon: Günlük 4 öğünlük yemek önerisi listesi (yumurta beyazı, yulaf ezmesi, tavuk göğsü, pirinç pilavı) ve öğün makro oranları detaylandırılacaktır.',
            );
          },
        ),

        const SizedBox(height: 16),

        // Plan Card: Clean Bulk
        _buildNutritionPlanCard(
          id: 'clean_bulk',
          title: 'Temiz Hacim Kazanma (Clean Bulk)',
          subtitle: 'Maksimum Kas Gelişimi Diyet Şablonu',
          description: 'Minimum yağ alımı ile kaliteli kas kütlesi eklemek için tasarlanmış, kompleks karbonhidrat ağırlıklı beslenme.',
          kcalText: '2800 kcal / Gün',
          macroSplitText: 'Yüksek Kompleks Karbonhidrat',
          proteinPercent: 0.30,
          carbPercent: 0.50,
          fatPercent: 0.20,
          isActive: _activeNutritionPlanId == 'clean_bulk',
          onActivate: () {
            setState(() {
              _activeNutritionPlanId = 'clean_bulk';
            });
            CustomFeedback.show(context, 'Temiz bulk beslenme planı aktif edildi!', type: FeedbackType.success);
          },
          onDetails: () {
            _showFutureFeatureDialog(
              context,
              'Clean Bulk Diyeti Detayları',
              'Gelecek Fonksiyon: Fıstık ezmesi, kırmızı et, pirinç kreması gibi yüksek kalorili temiz besin kaynaklarının porsiyon hesaplayıcısı aktif hale gelecektir.',
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAICoachCard({
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors[0].withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              width: 120,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(UIcons.regularRounded.sparkles, color: AppColors.primary, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          buttonText,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPlanCard({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required String daysText,
    required String levelText,
    required bool isActive,
    required VoidCallback onActivate,
    required VoidCallback onDetails,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.04 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isActive ? AppColors.primary.withOpacity(0.7) : const Color(0xFFE5E7EB),
          width: isActive ? 2.0 : 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Left Status Accent Bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(
                color: isActive ? AppColors.primary : Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
                              SizedBox(width: 4),
                              Text(
                                'KULLANIMDA',
                                style: TextStyle(
                                  color: Color(0xFF059669),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mini Chips with Icons
                  Row(
                    children: [
                      _buildMiniChip(Icons.calendar_today_rounded, daysText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniChip(Icons.fitness_center_rounded, levelText),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Layout
                  _buildActionButtons(isActive, onActivate, onDetails),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionPlanCard({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required String kcalText,
    required String macroSplitText,
    required double proteinPercent,
    required double carbPercent,
    required double fatPercent,
    required bool isActive,
    required VoidCallback onActivate,
    required VoidCallback onDetails,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.04 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isActive ? const Color(0xFF10B981).withOpacity(0.7) : const Color(0xFFE5E7EB),
          width: isActive ? 2.0 : 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Left Status Accent Bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(
                color: isActive ? const Color(0xFF10B981) : Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
                              SizedBox(width: 4),
                              Text(
                                'KULLANIMDA',
                                style: TextStyle(
                                  color: Color(0xFF059669),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📊 Premium Macro Segments Visualizer
                  const Text(
                    'MAKRO DAĞILIMI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildMacroLabel(const Color(0xFFEF4444), 'Protein', '${(proteinPercent * 100).toInt()}%'),
                      const SizedBox(width: 12),
                      _buildMacroLabel(const Color(0xFFF59E0B), 'Karbonhidrat', '${(carbPercent * 100).toInt()}%'),
                      const SizedBox(width: 12),
                      _buildMacroLabel(const Color(0xFF3B82F6), 'Yağ', '${(fatPercent * 100).toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Segmented Progress Bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (proteinPercent * 100).toInt(),
                            child: Container(color: const Color(0xFFEF4444)),
                          ),
                          Expanded(
                            flex: (carbPercent * 100).toInt(),
                            child: Container(color: const Color(0xFFF59E0B)),
                          ),
                          Expanded(
                            flex: (fatPercent * 100).toInt(),
                            child: Container(color: const Color(0xFF3B82F6)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mini Chips with Icons
                  Row(
                    children: [
                      _buildMiniChip(Icons.local_fire_department_rounded, kcalText, iconColor: const Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniChip(Icons.restaurant_menu_rounded, macroSplitText, iconColor: const Color(0xFF10B981)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Layout
                  _buildActionButtons(isActive, onActivate, onDetails),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChip(IconData icon, String text, {Color iconColor = const Color(0xFF4B5563)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLabel(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isActive, VoidCallback onActivate, VoidCallback onDetails) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 44),
            ),
            onPressed: onDetails,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Planı İncele',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_right_rounded, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? const Color(0xFFE5E7EB) : Colors.black,
              foregroundColor: isActive ? const Color(0xFF9CA3AF) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 44),
            ),
            onPressed: isActive ? null : onActivate,
            child: Text(
              isActive ? 'Aktif' : 'Aktif Plan Yap',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
