import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../../core/constants/app_colors.dart';
import '../../cart/services/cart_service.dart';
import '../../favorites/services/favorites_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize;
  String _selectedFlavor = '';
  bool _isDescriptionExpanded = false;

  final List<String> _sizes = [];

  @override
  void initState() {
    super.initState();
    final name     = widget.product['name']?.toString() ?? '';
    final category = widget.product['category']?.toString() ?? '';
    final desc     = widget.product['desc']?.toString() ?? '';

    // Initialize flavor selection
    final rawFlavors = widget.product['flavors'];
    if (rawFlavors is List && rawFlavors.isNotEmpty) {
      _selectedFlavor = rawFlavors.first.toString();
    }

    if (category == 'Protein' || name.contains('Protein') || name.contains('Whey')) {
      _sizes.addAll(['500 g', '1 kg', '2.27 kg']);
    } else if (category == 'Gainer' || name.contains('Gainer') || name.contains('Mass')) {
      _sizes.addAll(['1.5 kg', '3 kg', '5 kg']);
    } else if (category == 'Kreatin' || name.contains('Creatine')) {
      _sizes.addAll(['150 g', '300 g', '500 g']);
    } else if (category == 'Vitaminler' || name.contains('Vitamin') || name.contains('Omega') || name.contains('ZMA')) {
      _sizes.addAll(['30 Kapsül', '60 Kapsül', '120 Kapsül']);
    } else if (desc.contains('Kapsül') || desc.contains('Tablet')) {
      _sizes.addAll(['30 Kapsül', '60 Kapsül', '120 Kapsül']);
    } else {
      _sizes.addAll(['250 g', '500 g', '1 kg']);
    }
    _selectedSize = _sizes[1];
  }

  String _getProductDescription(String name, String category) {
    if (category == 'Protein' || name.contains('Protein') || name.contains('Whey')) {
      return 'Alpamys Nutrition Whey Gold Protein, yüksek kaliteli whey konsantrat ve izolat karışımıyla antrenman sonrası kaslarınızın hızlıca toparlanmasını sağlar. Servis başına 24 g protein, düşük karbonhidrat ve yağ içeriğiyle lean kazanım için idealdir. Kolay çözünür formülü sayesinde su veya sütle rahatlıkla karıştırılabilir.';
    }
    if (category == 'Gainer' || name.contains('Gainer') || name.contains('Mass')) {
      return 'Mass Gainer Pro, zorlu antrenmanlarda yeterli kalori ve protein alamayan sporcular için geliştirilmiştir. Servis başına 1250 kcal, 50 g protein ve 250 g kompleks karbonhidrat sağlayan bu ürün; hacim ve kilo kazanımı hedefleyen sporcuların ilk tercihi olacak. Vitaminler ve mineraller eklenmiştir.';
    }
    if (category == 'Kreatin' || name.contains('Creatine')) {
      return 'Alpamys Nutrition Creatine Monohydrate, bilimsel olarak en çok araştırılmış spor besin maddesidir. Saf mikronize kreatin monohidrat içeriğiyle kas gücünü, patlayıcı kuvveti ve egzersiz kapasitesini artırır. Günlük 3-5 g kullanım önerilir. Aromasız versiyonu protein tozu ya da meyve suyu ile kolayca karıştırılabilir.';
    }
    if (name.contains('Vitamin A')) {
      return 'Vitamin A (Retinol), göz sağlığı, bağışıklık sistemi ve deri sağlığı için vazgeçilmez bir yağda çözünen vitamindir. Günlük 5000 IU alım eksikliği önlerken hücre yenilenmesini destekler. Yemeklerle birlikte alınması önerilir.';
    }
    if (name.contains('Vitamin B') || name.contains('B Kompleks')) {
      return 'Vitamin B Kompleks; B1 (Tiamin), B2 (Riboflavin), B3 (Niasin), B5 (Pantotenik Asit), B6 (Piridoksin), B7 (Biotin), B9 (Folik Asit) ve B12 (Kobalamin) içerir. Enerji metabolizması, sinir sistemi sağlığı ve kırmızı kan hücresi üretimini destekler. Sporcularda günlük B vitamini ihtiyacını tek tablette karşılar.';
    }
    if (name.contains('Vitamin C')) {
      return 'Vitamin C (Askorbik Asit), güçlü bir antioksidan olarak serbest radikallere karşı hücreleri korur. Bağışıklık sistemini güçlendirir, kolajen sentezini destekler ve demir emilimini artırır. 1000 mg yüksek doz formülü, antrenman sonrası toparlanmayı hızlandırır ve hastalıklara karşı direnci artırır.';
    }
    if (name.contains('Vitamin D')) {
      return 'Vitamin D3 (Kolekalsiferol), kemik ve diş sağlığını desteklemek için kalsiyum emilimini artırır. Bağışıklık sistemi, kas fonksiyonu ve ruh hali üzerinde kritik rol oynar. Özellikle kış aylarında güneş ışığından yeterli D vitamini alamayanlarda takviye zorunlu hale gelir. K2 vitaminiyle birlikte kullanım önerilir.';
    }
    if (name.contains('Vitamin E')) {
      return 'Vitamin E, hücre zarlarını oksidatif hasara karşı koruyan güçlü bir antioksidandır. Egzersiz sonrası kas hasarını azaltır, cilt sağlığını destekler ve bağışıklık sistemini güçlendirir. 400 IU alfa-tokoferol formu, en biyoyararlanabilir Vitamin E versiyonudur.';
    }
    if (name.contains('Vitamin K')) {
      return 'Vitamin K2 (MK-7), kan pıhtılaşması ve kemik mineralizasyonu için hayati öneme sahiptir. D3 vitaminiyle sinerjik çalışarak kalsiyumun doğru hedeflere (kemikler) yönlendirilmesini sağlar ve damar sertliğini önler. Uzun etki süresiyle MK-7 formu en etkili K2 versiyonudur.';
    }
    if (name.contains('L-Valine') || name.contains('L-Isoleucine') || name.contains('L-Leucine')) {
      return '$name, BCAA (Dallı Zincirli Amino Asitler) kompleksinin temel bileşenlerinden biridir. Kas protein sentezini uyarır, antrenman sırasında kas yıkımını önler ve toparlanmayı hızlandırır. Saf toz formülü herhangi bir içeceğe kolayca eklenebilir. Antrenman öncesi veya sırasında tüketim önerilir.';
    }
    if (name.contains('L-Lysine')) return 'L-Lizin, vücudun üretemediği zorunlu bir amino asittir. Kolajen sentezi, kalsiyum emilimi ve büyüme hormonu üretimini destekler. Bağışıklık sistemini güçlendirir. Sporcularda günlük 1-3 g alım önerilir.';
    if (name.contains('L-Methionine')) return 'L-Metiyonin, karaciğer sağlığını koruyan ve detoksifikasyonu destekleyen kükürtlü zorunlu bir amino asittir. Kreatin, karnitin ve sistein sentezi için gereklidir. Antioksidan glutatyon üretimini artırır.';
    if (name.contains('L-Threonine')) return 'L-Treonin, kolajen ve elastin sentezi için gerekli zorunlu bir amino asittir. Bağırsak mukozasını korur, bağışıklık sistemini destekler ve protein metabolizmasında kritik rol oynar.';
    if (name.contains('L-Tryptophan')) return 'L-Triptofan, mutluluk hormonu serotonin ve uyku hormonu melatoninin öncüsüdür. Ruh halini iyileştirir, uyku kalitesini artırır ve iştah düzenlemesine yardımcı olur. Yatmadan 30-60 dakika önce alım önerilir.';
    if (name.contains('L-Phenylalanine')) return 'L-Fenilalanin, tirozin, dopamin ve norepinefrinin sentezi için gerekli zorunlu bir amino asittir. Odaklanmayı artırır, ağrı eşiğini yükseltir ve ruh halini olumlu etkiler.';
    if (name.contains('L-Arginine')) return 'L-Arginin, nitrik oksit (NO) sentezinin temel yapı taşıdır. Kan damarlarını genişleterek kan akışını ve pompa hissini artırır. Büyüme hormonu salgısını uyarır ve yara iyileşmesini hızlandırır. Antrenman öncesi 3-6 g dozaj önerilir.';
    if (name.contains('L-Glutamine')) return 'L-Glutamin, vücutta en bol bulunan amino asit olup yoğun antrenmanlarda tükenir. Bağırsak sağlığını korur, bağışıklık sistemini güçlendirir ve kas glikojen sentezini destekler. Antrenman sonrası 5-10 g kullanım toparlanmayı hızlandırır.';
    if (name.contains('L-Tyrosine')) return 'L-Tirozin, dopamin, norepinefrin ve tiroid hormonlarının öncüsüdür. Stres altında odaklanmayı ve zihinsel performansı artırır. Antrenman öncesi alındığında enerji ve motivasyonu yükseltir.';
    if (name.contains('L-Cysteine')) return 'L-Sistein, güçlü antioksidan glutatyonun yapı taşıdır. Saç, tırnak ve deri sağlığı için kükürt kaynağı sağlar. Karaciğer detoksifikasyonunu destekler.';
    if (name.contains('L-Histidine')) return 'L-Histidin, karnosin sentezi için gerekli bir amino asittir. Karnosin antrenman sırasında kas asidozunu tamponlayarak yorgunluğu geciktirir. Sinir kılıfı oluşumuna katkıda bulunur.';
    if (name.contains('L-Proline')) return 'L-Prolin, kolajen yapısının yaklaşık yüzde onbeşini oluşturur. Eklem sağlığı, tendon ve kıkırdak tamiri için kritiktir. Yaralanma sonrası doku yenilenmesini hızlandırır. C vitaminiyle birlikte alındığında kolajen sentezi artar.';
    if (name.contains('L-Alanine')) return 'L-Alanin, glikoz-alanin döngüsü aracılığıyla karaciğerde enerji üretimine katkıda bulunur. Kan şekerinin dengelenmesine yardımcı olur ve bağışıklık sistemini destekler.';
    if (name.contains('L-Asparagine')) return 'L-Asparagin, sinir sistemi sağlığı ve beyin fonksiyonu için önemli bir amino asittir. Hücre metabolizmasında nitrojen taşıyıcısı olarak görev yapar ve enerji üretim süreçlerine katkıda bulunur.';
    if (name.contains('L-Aspartic Acid')) return 'L-Aspartik Asit, Krebs döngüsünde enerji metabolizmasında rol alır ve mineral taşınmasına yardımcı olur. Testosteron seviyelerini desteklediğine dair araştırmalar mevcuttur.';
    if (name.contains('L-Glutamic Acid')) return 'L-Glutamik Asit, beyindeki en önemli uyarıcı nörotransmitterdir. Bilişsel fonksiyon, bellek ve öğrenmeyi destekler. Glutaminin öncü maddesidir ve GABA sentezi için gereklidir.';
    if (name.contains('L-Glycine')) return 'L-Glisin, uyku kalitesini artırdığı bilimsel olarak kanıtlanmış bir amino asittir. Kolajen yapısının üçte birini oluşturur ve kreatin sentezi için gereklidir. Yatmadan önce 3 g alım önerilir.';
    if (name.contains('L-Serine')) return 'L-Serin, hücre zarı fosfolipidlerinin yapı taşıdır. Beyin fonksiyonu ve sinir kılıfı oluşumu için gereklidir. Fosfoserin formu zihinsel yorgunluğu azaltır ve kortizol seviyelerini düşürür.';
    if (category == 'Amino Asitler') {
      return '$name, Alpamys Nutrition saf formülüyle üretilmiş premium amino asit takviyesidir. Yüksek saflık derecesiyle kas sentezi, toparlanma ve genel sağlık için destek sağlar.';
    }
    return 'Alpamys Nutrition tarafından geliştirilen premium formül, antrenman performansınızı zirveye taşımak için en yüksek standartlarda üretilmiştir. Saf içerik ve üstün kalite anlayışıyla sporcuların ihtiyaçlarını karşılar.';
  }

  @override
  Widget build(BuildContext context) {
    final name     = widget.product['name']?.toString() ?? '';
    final category = widget.product['category']?.toString() ?? '';
    final desc = _getProductDescription(name, category);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Product Image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: AspectRatio(
                      aspectRatio: 1.35,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            widget.product['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF1F3F5),
                                child: Center(
                                  child: Icon(
                                    UIcons.regularRounded.picture,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title, Subtitle, Badges & Rating Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.product['brand'] as String? ?? 'Alpamys Nutrition',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ListenableBuilder(
                              listenable: FavoritesService(),
                              builder: (context, child) {
                                final isFav = FavoritesService().isFavorite(widget.product);
                                return GestureDetector(
                                  onTap: () {
                                    FavoritesService().toggleFavorite(widget.product);
                                    CustomFeedback.show(
                                      context,
                                      isFav ? '$name favorilerden çıkarıldı!' : '$name favorilere eklendi!',
                                      type: FeedbackType.success,
                                    );
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isFav ? Icons.favorite : Icons.favorite_border,
                                        size: 20,
                                        color: isFav ? const Color(0xFFED5151) : AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Rating row
                        Row(
                          children: [
                            Icon(
                              UIcons.regularRounded.star,
                              color: const Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.product['rating']?.toString() ?? '4.8',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(230)',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE5E7EB), height: 1),
                        const SizedBox(height: 16),

                        // Description Section
                        const Text(
                          'Açıklama',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: _isDescriptionExpanded
                                      ? desc
                                      : (desc.length > 100 ? '${desc.substring(0, 100)}... ' : desc),
                                ),
                                if (desc.length > 100)
                                  TextSpan(
                                    text: _isDescriptionExpanded ? ' Kapat' : 'Devamını Oku',
                                    style: const TextStyle(
                                      color: Color(0xFFA3CB24), // Lime Green
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Aroma Seçimi (only when product has flavors) ──
                        Builder(builder: (context) {
                          final rawFlavors = widget.product['flavors'];
                          if (rawFlavors is! List || rawFlavors.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final flavors = rawFlavors.map((f) => f.toString()).toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aroma',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: flavors.map((flavor) {
                                  final isSelected = _selectedFlavor == flavor;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedFlavor = flavor),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFF1F3F5) : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFA3CB24) : const Color(0xFFE5E7EB),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        flavor,
                                        style: TextStyle(
                                          color: isSelected ? Colors.black : AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),

                        // Size Section

                        const Text(
                          'Boyut / Paket',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: _sizes.map((size) {
                            final isSelected = _selectedSize == size;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF1F3F5) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFA3CB24) : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Bar containing Price & Buy Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
              border: const Border(
                top: BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Fiyat',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product['price'] as String? ?? '0 TL',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        CartService().addItem(widget.product, _selectedSize);
                        CustomFeedback.show(
                          context,
                          '$name ($_selectedSize) sepetinize eklendi!',
                          type: FeedbackType.success,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Satın Al',
                            style: TextStyle(
                              color: Color(0xFFA3CB24), // Lime Green
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
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
    ),
  );
}
}
