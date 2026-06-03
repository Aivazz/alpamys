import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class Ingredient {
  final String name;
  final double baseAmount;
  final String unit;

  Ingredient(this.name, this.baseAmount, this.unit);

  String displayAmount(int servings) {
    if (baseAmount == 0) return name;
    final total = baseAmount * servings;
    final formatted = total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1);
    return '$formatted $unit $name';
  }
}

class RecipeModel {
  final String id;
  final String name;
  final String category;
  final String image;
  final String calories;
  final int baseCalories;
  final String prepTime;
  final String difficulty;
  final int protein;
  final int carbs;
  final int fat;
  final String? benefit;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.calories,
    required this.baseCalories,
    required this.prepTime,
    required this.difficulty,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.benefit,
    required this.ingredients,
    required this.instructions,
  });
}

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  static final List<RecipeModel> recipes = [
    RecipeModel(
      id: 'rec_1',
      name: 'Proteinli Yulaf Krep Pizza',
      category: 'Kahvaltı',
      image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80',
      calories: '420 kcal',
      baseCalories: 420,
      prepTime: '10 dk',
      difficulty: 'Kolay',
      protein: 30,
      carbs: 35,
      fat: 16,
      benefit: 'Karmaşık karbonhidratlar ve proteinin mükemmel dengesi. Öğle yemeğine kadar tok tutar.',
      ingredients: [
        Ingredient('yulaf ezmesi', 40, 'g'),
        Ingredient('yumurta', 2, 'adet'),
        Ingredient('süt', 30, 'ml'),
        Ingredient('pişmiş tavuk göğsü filetosu', 50, 'g'),
        Ingredient('hafif peynir', 30, 'g'),
        Ingredient('domates', 0, ''),
        Ingredient('yeşillik', 0, ''),
      ],
      instructions: [
        'Yulaf ezmesi, yumurta ve sütü blender ile (veya çatalla) karıştırıp tuz ekleyin.',
        'Karışımı önceden ısıtılmış yapışmaz tavaya dökün. Kapağı kapalı olarak 3 dakika pişirin, ardından ters çevirin.',
        'Üzerine doğranmış tavuk, domates dilimleri ekleyin ve rendelenmiş peynir serpin.',
        'Peynir eriyene kadar kapağını kapatıp 2-3 dakika daha pişirin.',
      ],
    ),
    RecipeModel(
      id: 'rec_2',
      name: 'Somonlu ve Avokadolu Scramble Tost',
      category: 'Kahvaltı',
      image: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500&auto=format&fit=crop&q=80',
      calories: '480 kcal',
      baseCalories: 480,
      prepTime: '10 dk',
      difficulty: 'Kolay',
      protein: 28,
      carbs: 22,
      fat: 24,
      benefit: 'Eklemler için sağlıklı yağlar (Omega-3) ve kaliteli protein.',
      ingredients: [
        Ingredient('yumurta', 3, 'adet'),
        Ingredient('hafif tuzlu somon', 50, 'g'),
        Ingredient('avokado', 0.5, 'adet'),
        Ingredient('tam tahıllı tost ekmeği', 2, 'adet'),
        Ingredient('zeytinyağı', 0, 'damla'),
      ],
      instructions: [
        'Yumurtaları bir çimdik tuz ile çırpın. Tavayı orta ateşe koyun, bir damla yağ ile yağlayın.',
        'Yumurtaları dökün ve yumuşak, hafif nemli bir kıvam elde etmek için spatula ile yaklaşık 2-3 dakika sürekli karıştırın.',
        'Avokadoyu çatalla ezin ve kızarmış tost ekmeklerinin üzerine sürün.',
        'Üzerine çırpılmış yumurtayı (scramble) ve somon dilimlerini yerleştirin.',
      ],
    ),
    RecipeModel(
      id: 'rec_3',
      name: 'Hindistan Cevizli ve Muzlu Lor Peynirli Sufle',
      category: 'Kahvaltı',
      image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80',
      calories: '380 kcal',
      baseCalories: 380,
      prepTime: '45 dk',
      difficulty: 'Orta',
      protein: 32,
      carbs: 40,
      fat: 10,
      benefit: 'Lor peynirinden kazein proteini, minimum şeker.',
      ingredients: [
        Ingredient('lor peyniri (%2-5)', 400, 'g'),
        Ingredient('büyük muz', 1, 'adet'),
        Ingredient('yumurta', 2, 'adet'),
        Ingredient('pirinç unu', 2, 'yemek kaşığı'),
        Ingredient('hindistan cevizi rendesi', 1, 'yemek kaşığı'),
      ],
      instructions: [
        'Blenderda lor peyniri, muz ve yumurtayı pürüzsüz olana kadar karıştırın.',
        'Pirinç ununu ve hindistan cevizi rendesini ekleyip iyice karıştırın.',
        'Karışımı fırın kabına aktarın.',
        '180°C fırında üzeri altın sarısı olana kadar yaklaşık 35–40 dakika pişirin. Soğuk olarak da tüketilebilir.',
      ],
    ),
    RecipeModel(
      id: 'rec_4',
      name: 'Şakşuka',
      category: 'Kahvaltı',
      image: 'https://images.unsplash.com/photo-1590412200988-a436bb7050a8?w=500&auto=format&fit=crop&q=80',
      calories: '340 kcal',
      baseCalories: 340,
      prepTime: '15 dk',
      difficulty: 'Orta',
      protein: 22,
      carbs: 15,
      fat: 18,
      benefit: 'Antioksidan ve protein açısından zengin, canlı bir kahvaltı.',
      ingredients: [
        Ingredient('yumurta', 3, 'adet'),
        Ingredient('dolmalık biber', 1, 'adet'),
        Ingredient('soğan', 0.5, 'adet'),
        Ingredient('kendi suyunda domates (konserve)', 200, 'g'),
        Ingredient('diş sarımsak', 1, 'adet'),
        Ingredient('baharatlar (kimyon, toz biber)', 0, ''),
        Ingredient('maydanoz', 0, ''),
      ],
      instructions: [
        'Soğan, sarımsak ve biberi ince ince doğrayın. Yumuşayana kadar tavada soteleyin.',
        'Domatesleri ve baharatları ekleyin. Sos hafifçe koyulaşana kadar kısık ateşte 5–7 dakika pişirin.',
        'Sosun üzerinde kaşıkla üç delik açın ve yumurtaları buralara kırın.',
        'Yumurta aklarının üzerine tuz serpin, kapağını kapatıp aklar beyazlaşana ama sarısı akışkan kalana kadar pişirin. Üzerine maydanoz serpin.',
      ],
    ),
    RecipeModel(
      id: 'rec_5',
      name: 'Granolalı Fit Parfe',
      category: 'Kahvaltı',
      image: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80',
      calories: '290 kcal',
      baseCalories: 290,
      prepTime: '5 dk',
      difficulty: 'Kolay',
      protein: 18,
      carbs: 35,
      fat: 8,
      benefit: 'Hazırlanacak zaman yoksa hızlı ve pratik bir kahvaltı.',
      ingredients: [
        Ingredient('süzme yoğurt (%0-2)', 250, 'g'),
        Ingredient('fırınlanmış granola', 40, 'g'),
        Ingredient('taze çilek veya meyve', 100, 'g'),
        Ingredient('bal', 1, 'tatlı kaşığı'),
      ],
      instructions: [
        'Şeffaf bir bardak veya kase alın.',
        'Katmanlar halinde yerleştirin: birkaç kaşık yoğurt, bir kat granola, bir kat doğranmış meyve.',
        'Katmanları tekrarlayın. Üzerine biraz bal damlatıp taze meyvelerle süsleyin.',
      ],
    ),
    RecipeModel(
      id: 'rec_6',
      name: 'Klasik Fit Öğle Yemeği: Baharatlı Tavuk Fileto ve Yabani Pirinç',
      category: 'Öğle Yemeği',
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
      calories: '510 kcal',
      baseCalories: 510,
      prepTime: '40 dk',
      difficulty: 'Kolay',
      protein: 51,
      carbs: 52,
      fat: 8,
      benefit: 'Maksimum saf protein ve uzun süre tok tutan karmaşık karbonhidratlar.',
      ingredients: [
        Ingredient('tavuk göğsü filetosu', 200, 'g'),
        Ingredient('yabani veya esmer pirinç', 60, 'g'),
        Ingredient('brokoli', 100, 'g'),
        Ingredient('kırmızı toz biber (paprika)', 1, 'çay kaşığı'),
        Ingredient('sarımsak tozu', 1, 'çay kaşığı'),
        Ingredient('zeytinyağı', 1, 'çay kaşığı'),
      ],
      instructions: [
        'Pirinci tuzlu suda üzerindeki tarife göre haşlayın (yaklaşık 30-40 dakika).',
        'Tavuk göğsünü enlemesine dilimleyerek biftek haline getirin; tuz, toz biber ve sarımsak tozuyla ovun. Izgara veya tavada az yağ ile her iki tarafını 4-5 dakika kızartın.',
        'Brokoliyi kaynar suda 3 dakika haşlayın veya buharda pişirin.',
        'Tüm malzemeleri tabağa servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_7',
      name: 'Fırında Hindi Fileto ve Tatlı Patates',
      category: 'Öğle Yemeği',
      image: 'https://images.unsplash.com/photo-1580959375944-abd7e990f983?w=500&auto=format&fit=crop&q=80',
      calories: '440 kcal',
      baseCalories: 440,
      prepTime: '35 dk',
      difficulty: 'Kolay',
      protein: 44,
      carbs: 40,
      fat: 6,
      benefit: 'Hindi eti tavuktan daha kolay sindirilir, tatlı patates ise mükemmel glisemik indeks sağlar.',
      ingredients: [
        Ingredient('hindi fileto biftek', 200, 'g'),
        Ingredient('tatlı patates', 200, 'g'),
        Ingredient('soya sosu', 1, 'yemek kaşığı'),
        Ingredient('zeytinyağı', 1, 'çay kaşığı'),
        Ingredient('Provence otları (baharat)', 1, 'tatlı kaşığı'),
      ],
      instructions: [
        'Tatlı patatesi soyup elma dilimi şeklinde doğrayın. Üzerine zeytinyağı gezdirip Provence otları ve tuz serpin.',
        'Hindi etini soya sosu ve dilediğiniz baharatlarla 10 dakika marine edin.',
        'Hindi ve patatesleri pişirme kağıdı serili fırın tepsisine dizin.',
        '200°C fırında yaklaşık 25-30 dakika pişirin.',
      ],
    ),
    RecipeModel(
      id: 'rec_8',
      name: 'Domates Soslu Dana Köfte ve Karabuğday',
      category: 'Öğle Yemeği',
      image: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=500&auto=format&fit=crop&q=80',
      calories: '510 kcal',
      baseCalories: 510,
      prepTime: '30 dk',
      difficulty: 'Orta',
      protein: 46,
      carbs: 44,
      fat: 12,
      benefit: 'Dana etinden gelen demir ve çinko ile sporcuların vazgeçilmezi karabuğday.',
      ingredients: [
        Ingredient('yağsız dana kıyması', 200, 'g'),
        Ingredient('karabuğday', 60, 'g'),
        Ingredient('küçük soğan', 1, 'adet'),
        Ingredient('domates salçası/sosu (şekersiz)', 150, 'ml'),
        Ingredient('taze yeşillik', 0, ''),
      ],
      instructions: [
        'Kıymaya ince ince doğranmış soğan, tuz ve karabiber ekleyip küçük köfteler hazırlayın.',
        'Köfteleri tavaya dizin, üzerine biraz suyla açtığınız domates sosunu dökün. Kapağı kapalı olarak orta ateşte 20 dakika pişirin.',
        'Ayrı bir tencerede karabuğdayı haşlayın.',
        'Karabuğdayın üzerine soslu köfteleri ekleyerek servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_9',
      name: 'Ton Balıklı Makarna (Pasta)',
      category: 'Öğle Yemeği',
      image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80',
      calories: '500 kcal',
      baseCalories: 500,
      prepTime: '15 dk',
      difficulty: 'Kolay',
      protein: 34,
      carbs: 52,
      fat: 8,
      benefit: 'Ağır antrenmanlar öncesinde yüksek protein ve karbonhidrat içeren pratik bir öğün.',
      ingredients: [
        Ingredient('durum buğdayından makarna', 70, 'g'),
        Ingredient('ton balığı (kendi suyunda)', 160, 'g'),
        Ingredient('çeri domates', 6, 'adet'),
        Ingredient('diş sarımsak', 1, 'adet'),
        Ingredient('taze fesleğen', 0, ''),
      ],
      instructions: [
        'Makarnayı al dente (hafif diri) kıvamda haşlayın.',
        'Tavada ezilmiş sarımsağı yarım dakika soteleyip çıkarın. İkiye bölünmüş çeri domatesleri ekleyip hafifçe soteleyin.',
        'Suyunu süzdüğünüz ton balığını domateslere ilave edip makarnayı da tavaya aktarın.',
        'Tüm malzemeleri 1 dakika boyunca tavada karıştırın, üzerine taze fesleğen serperek servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_10',
      name: 'Kinoalı ve Karidesli Fit Salatası',
      category: 'Öğle Yemeği',
      image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&auto=format&fit=crop&q=80',
      calories: '380 kcal',
      baseCalories: 380,
      prepTime: '20 dk',
      difficulty: 'Kolay',
      protein: 32,
      carbs: 35,
      fat: 7,
      benefit: 'Kinoa tüm temel amino asitleri içerir, karides ise en saf protein kaynaklarındandır.',
      ingredients: [
        Ingredient('kinoa', 50, 'g'),
        Ingredient('temizlenmiş karides', 150, 'g'),
        Ingredient('salatalık', 1, 'adet'),
        Ingredient('çeri domates', 100, 'g'),
        Ingredient('bebek ıspanak', 1, 'avuç'),
        Ingredient('zeytinyağı', 1, 'çay kaşığı'),
        Ingredient('limon suyu', 0, ''),
      ],
      instructions: [
        'Kinoayı yıkayıp süzün, 1:2 oranında suyla 15 dakika haşlayın.',
        'Karidesleri çok az yağ ile kızgın tavada her iki tarafını 1-2 dakika soteleyin.',
        'Kasede ıspanak, doğranmış salatalık ve domatesleri karıştırın. Soğuyan kinoa ve karidesleri ekleyin.',
        'Limon suyu, zeytinyağı ve tuz gezdirip servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_11',
      name: 'Sebze Yatağında Fırınlanmış Beyaz Balık (Mezgit/Sudak)',
      category: 'Akşam Yemeği',
      image: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&auto=format&fit=crop&q=80',
      calories: '220 kcal',
      baseCalories: 220,
      prepTime: '25 dk',
      difficulty: 'Kolay',
      protein: 36,
      carbs: 10,
      fat: 2,
      benefit: 'Kolay sindirilebilir protein içeren düşük kalorili akşam yemeği. Yatmadan önce sindirim sistemini yormaz.',
      ingredients: [
        Ingredient('mezgit veya sudak filetosu', 200, 'g'),
        Ingredient('dondurulmuş karışık sebze', 200, 'g'),
        Ingredient('limon suyu', 1, 'yemek kaşığı'),
      ],
      instructions: [
        'Pişirme kabına veya alüminyum folyoya dözdürmediğiniz sebzeleri yayın ve tuz serpin.',
        'Sebzelerin üzerine balık filetosunu yerleştirin, limon suyu gezdirip balık baharatları ekleyin.',
        'Folyoyu kapatıp (veya kabın kapağını örtüp) 180°C fırında yaklaşık 20 dakika pişirin.',
      ],
    ),
    RecipeModel(
      id: 'rec_12',
      name: 'Tavuk Fileto "Caprese"',
      category: 'Akşam Yemeği',
      image: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
      calories: '350 kcal',
      baseCalories: 350,
      prepTime: '35 dk',
      difficulty: 'Kolay',
      protein: 48,
      carbs: 4,
      fat: 13,
      benefit: 'Kuru tavuk göğsüne lezzetli, sulu ve protein dolu bir alternatif.',
      ingredients: [
        Ingredient('tavuk göğsü filetosu', 200, 'g'),
        Ingredient('küçük domates', 1, 'adet'),
        Ingredient('mozzarella peyniri', 40, 'g'),
        Ingredient('taze fesleğen yaprakları', 0, ''),
      ],
      instructions: [
        'Tavuk fileto üzerinde akordeon şeklinde derin enine kesikler açın. Eti tuzlayıp karabiberleyin.',
        'Kesiklerin arasına birer dilim domates ve birer dilim peynir yerleştirin.',
        'Önceden 190°C\'ye ısıtılmış fırında 25 dakika pişirin.',
      ],
    ),
    RecipeModel(
      id: 'rec_13',
      name: 'Sıcak Dana Etli ve Taze Fasulyeli Fit Salatası',
      category: 'Akşam Yemeği',
      image: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&auto=format&fit=crop&q=80',
      calories: '290 kcal',
      baseCalories: 290,
      prepTime: '20 dk',
      difficulty: 'Kolay',
      protein: 34,
      carbs: 12,
      fat: 10,
      benefit: 'Gece saatlerinde fazla karbonhidrat tüketmeden kas liflerinin onarılmasını sağlar.',
      ingredients: [
        Ingredient('yağsız dana bonfile', 150, 'g'),
        Ingredient('taze yeşil fasulye (çalı)', 150, 'g'),
        Ingredient('karışık salata yeşilliği', 1, 'avuç'),
        Ingredient('soya sosu', 1, 'yemek kaşığı'),
        Ingredient('susam', 1, 'tatlı kaşığı'),
      ],
      instructions: [
        'Dana etini ince şeritler halinde doğrayıp yüksek ateşte 4-5 dakika soteleyin, son saniyelerde soya sosu gezdirin.',
        'Fasulyeleri kaynar suda 3 dakika haşlayın, süzüp renklerini korumaları için buzlu soğuk suya tutun.',
        'Tabağa salata yeşilliklerini, fasulyeyi ve sıcak eti ekleyip karıştırın, üzerine susam serpin.',
      ],
    ),
    RecipeModel(
      id: 'rec_14',
      name: 'Kabaklı Yumuşacık Hindi Köftesi',
      category: 'Akşam Yemeği',
      image: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=500&auto=format&fit=crop&q=80',
      calories: '450 kcal',
      baseCalories: 450,
      prepTime: '35 dk',
      difficulty: 'Kolay',
      protein: 54,
      carbs: 8,
      fat: 18,
      benefit: 'Kabak köfteleri sulu yapar ve proteinin daha iyi emilmesi için lif sağlar.',
      ingredients: [
        Ingredient('hindi kıyması', 300, 'g'),
        Ingredient('küçük kabak', 0.5, 'adet'),
        Ingredient('yumurta', 1, 'adet'),
        Ingredient('sarımsak tozu', 1, 'çay kaşığı'),
      ],
      instructions: [
        'Kabağı ince rendeleyin ve suyunu elinizle iyice sıkın.',
        'Hindi kıyması, kabak, yumurta ve baharatları karıştırın. Harcın kıvam alması için kaseye birkaç kez vurun.',
        'Köfteler şekillendirip 180°C fırında 25 dakika pişirin (veya buharda pişirin).',
      ],
    ),
    RecipeModel(
      id: 'rec_15',
      name: 'Orman Meyveli Lor Peyniri Musu (Pratik Akşam Yemeği)',
      category: 'Akşam Yemeği',
      image: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80',
      calories: '215 kcal',
      baseCalories: 215,
      prepTime: '5 dk',
      difficulty: 'Kolay',
      protein: 34,
      carbs: 12,
      fat: 4,
      benefit: 'Gece boyunca kasları besleyecek yavaş salınımlı kazein proteini kaynağı.',
      ingredients: [
        Ingredient('lor peyniri (en fazla %5 yağlı)', 200, 'g'),
        Ingredient('kefir veya doğal yoğurt', 50, 'ml'),
        Ingredient('dondurulmuş veya taze vişne/ahududu', 50, 'g'),
        Ingredient('tatlandırıcı', 0, ''),
      ],
      instructions: [
        'Lor peynirini kaba alın, kefir ve tatlandırıcı ekleyin.',
        'El blenderı yardımıyla pürüzsüz ve kremsi olana kadar iyice çekin.',
        'Meyveleri ilave edip (dondurulmuşsa mikrodalgada 30 saniye ısıtıp) karıştırın, servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_16',
      name: 'Cevizli Süzme Yoğurt',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80',
      calories: '250 kcal',
      baseCalories: 250,
      prepTime: '2 dk',
      difficulty: 'Kolay',
      protein: 12,
      carbs: 8,
      fat: 16,
      benefit: 'Süzme yoğurtta yüksek protein ve yoğun kremsi doku bulunur. Ceviz ise eklemler için mükemmel bir sağlıklı yağ kaynağıdır.',
      ingredients: [
        Ingredient('süzme yoğurt (meyvesiz)', 150, 'g'),
        Ingredient('temizlenmiş ceviz içi', 20, 'g'),
      ],
      instructions: [
        'Bir kase süzme yoğurdun içine ceviz içi ekleyip karıştırın.',
        'Dilerseniz üzerine çok az tarçın serpebilirsiniz.',
      ],
    ),
    RecipeModel(
      id: 'rec_17',
      name: 'Yer Fıstığı Ezmeli Pirinç Patlağı',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=500&auto=format&fit=crop&q=80',
      calories: '240 kcal',
      baseCalories: 240,
      prepTime: '2 dk',
      difficulty: 'Kolay',
      protein: 8,
      carbs: 18,
      fat: 14,
      benefit: 'Pirinç patlağı antrenman öncesi enerji için hızlı karbonhidrat, yer fıstığı ezmesi ise sağlıklı yağ ve protein sağlar.',
      ingredients: [
        Ingredient('pirinç patlağı', 2, 'adet'),
        Ingredient('şekersiz yer fıstığı ezmesi (%100 doğal)', 2, 'yemek kaşığı'),
      ],
      instructions: [
        'Pirinç patlaklarının üzerine eşit miktarda yer fıstığı ezmesi sürün.',
        'İsteğe göre üzerini muz dilimleriyle süsleyebilirsiniz.',
      ],
    ),
    RecipeModel(
      id: 'rec_18',
      name: 'Züber Fındıklı/Fıstıklı Hurma Barı',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80',
      calories: '140 kcal',
      baseCalories: 140,
      prepTime: '1 dk',
      difficulty: 'Kolay',
      protein: 5,
      carbs: 22,
      fat: 4,
      benefit: 'İlave şekersiz doğal hurma barı. Antrenman çantasında taşımak için son derece pratik ve temiz bir enerji kaynağı.',
      ingredients: [
        Ingredient('Züber hurma barı (veya protein barı)', 1, 'adet'),
      ],
      instructions: [
        'Paketi açıp doğrudan tüketin.',
        'Yanında bir fincan sade kahve ile harika bir ara öğün alternatifi.',
      ],
    ),
    RecipeModel(
      id: 'rec_19',
      name: 'Kefir ve Muz İkilisi',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
      calories: '210 kcal',
      baseCalories: 210,
      prepTime: '1 dk',
      difficulty: 'Kolay',
      protein: 8,
      carbs: 30,
      fat: 4,
      benefit: 'Kefir probiyotik ve kalsiyum desteği sunar, muz ise potasyum seviyenizi yükselterek kas kramplarını önler.',
      ingredients: [
        Ingredient('sade kefir', 200, 'ml'),
        Ingredient('muz', 1, 'adet'),
      ],
      instructions: [
        'Kefiri sallayıp bardağa doldurun.',
        'Muzun kabuğunu soyup kefir ile birlikte tüketin.',
      ],
    ),
    RecipeModel(
      id: 'rec_20',
      name: 'Çiğ Kuruyemiş ve Kuru Meyve Kokteyli',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1596560548464-f010687714b5?w=500&auto=format&fit=crop&q=80',
      calories: '220 kcal',
      baseCalories: 220,
      prepTime: '1 dk',
      difficulty: 'Kolay',
      protein: 6,
      carbs: 18,
      fat: 15,
      benefit: 'Doğal ve hızlı enerji deposu. Önemli olan porsiyon kontrolünü (yaklaşık 30-40 g) korumaktır.',
      ingredients: [
        Ingredient('çiğ badem', 15, 'g'),
        Ingredient('çiğ fındık', 15, 'g'),
        Ingredient('kuru incir veya kuru kayısı', 2, 'adet'),
      ],
      instructions: [
        'Çiğ kuruyemişleri ve kuru meyveleri kasede birleştirip porsiyon halinde tüketin.',
      ],
    ),
    RecipeModel(
      id: 'rec_21',
      name: 'Ev Yapımı Protein Topları',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80',
      calories: '180 kcal',
      baseCalories: 180,
      prepTime: '15 dk',
      difficulty: 'Kolay',
      protein: 10,
      carbs: 20,
      fat: 6,
      benefit: 'Kahvenin yanına kasları besleyen ve tatlı krizlerini önleyen doğal bir protein bombası.',
      ingredients: [
        Ingredient('çekirdeksiz hurma', 100, 'g'),
        Ingredient('yulaf ezmesi', 2, 'yemek kaşığı'),
        Ingredient('kakao veya protein tozu', 1, 'ölçek'),
        Ingredient('çiğ fındık veya ceviz', 30, 'g'),
        Ingredient('hindistan cevizi rendesi (bulamak için)', 1, 'yemek kaşığı'),
      ],
      instructions: [
        'Hurmaları yumuşaması için 5 dakika sıcak suda bekletin, ardından suyunu süzün.',
        'Hurma, yulaf, kakao (veya protein tozu) ve kuruyemişleri mutfak robotuna atıp yapışkan bir hamur kıvamına gelene kadar çekin.',
        'Karışımdan küçük toplar yuvarlayıp hindistan cevizi rendesine bulayın.',
        'Buzdolabında 15-20 dakika dinlendirip servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_22',
      name: 'Ton Balıklı Fit Dürüm / Sandviç',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=500&auto=format&fit=crop&q=80',
      calories: '320 kcal',
      baseCalories: 320,
      prepTime: '10 dk',
      difficulty: 'Kolay',
      protein: 26,
      carbs: 28,
      fat: 7,
      benefit: 'Yüksek protein ve lif içeren, akşam yemeği yerine bile geçebilecek doyurucu bir ara öğün.',
      ingredients: [
        Ingredient('tam tahıllı lavaş veya ekmek', 1, 'adet'),
        Ingredient('süzülmüş konserve ton balığı (kendi suyunda)', 80, 'g'),
        Ingredient('haşlanmış mısır', 2, 'yemek kaşığı'),
        Ingredient('taze salatalık', 1, 'adet'),
        Ingredient('süzme yoğurt (mayonez yerine)', 1, 'yemek kaşığı'),
      ],
      instructions: [
        'Ton balığını süzme yoğurt ile karıştırıp çatal yardımıyla ezin.',
        'İçine haşlanmış mısır ve doğranmış salatalığı ekleyip karıştırın.',
        'Karışımı lavaşın içine yayıp rulo şeklinde sararak dürüm yapın.',
      ],
    ),
    RecipeModel(
      id: 'rec_23',
      name: 'Fırınlanmış Baharatlı Nohut Cipsi',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&auto=format&fit=crop&q=80',
      calories: '210 kcal',
      baseCalories: 210,
      prepTime: '30 dk',
      difficulty: 'Kolay',
      protein: 10,
      carbs: 30,
      fat: 5,
      benefit: 'Cipse sağlıklı ve çıtır bir alternatif. Bitkisel protein ve karmaşık karbonhidrat bakımından zengindir.',
      ingredients: [
        Ingredient('haşlanmış nohut (süzülmüş)', 1, 'kutu'),
        Ingredient('zeytinyağı', 1, 'çay kaşığı'),
        Ingredient('kırmızı toz biber', 1, 'tatlı kaşığı'),
        Ingredient('sarımsak tozu', 1, 'çay kaşığı'),
      ],
      instructions: [
        'Nohutları yıkayıp süzün. Çıtır olabilmeleri için kağıt havlu yardımıyla iyice kurutun.',
        'Nohutları zeytinyağı ve baharatlarla karıştırın.',
        'Fırın tepsisine yayıp 200°C fırında ara sıra karıştırarak 20-25 dakika çıtırlaşana kadar pişirin.',
      ],
    ),
    RecipeModel(
      id: 'rec_24',
      name: 'Dereotlu Lor Peynirli Kıtır Ekmek Tostu',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1541532713592-79a0317b6b77?w=500&auto=format&fit=crop&q=80',
      calories: '190 kcal',
      baseCalories: 190,
      prepTime: '5 dk',
      difficulty: 'Kolay',
      protein: 16,
      carbs: 22,
      fat: 3,
      benefit: 'Lor peyniri bol miktarda peynir altı suyu proteini içerir, yağ oranı çok düşüktür.',
      ingredients: [
        Ingredient('kıtır ekmek veya tam buğday tostu', 2, 'adet'),
        Ingredient('lor peyniri', 4, 'yemek kaşığı'),
        Ingredient('dereotu veya maydanoz', 1, 'tutam'),
        Ingredient('karabiber', 1, 'çimdik'),
      ],
      instructions: [
        'Lor peynirini kıyılmış dereotu ve karabiber ile karıştırın (yumuşatmak için birkaç damla zeytinyağı ekleyebilirsiniz).',
        'Karışımı kıtır ekmeklerin üzerine sürerek servis edin.',
      ],
    ),
    RecipeModel(
      id: 'rec_25',
      name: 'Sebzeli ve Yumurtalı Fit Muffin (Mafile)',
      category: 'Atıştırmalık',
      image: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=500&auto=format&fit=crop&q=80',
      calories: '160 kcal',
      baseCalories: 160,
      prepTime: '20 dk',
      difficulty: 'Kolay',
      protein: 14,
      carbs: 4,
      fat: 10,
      benefit: 'Pratikçe hazırlayıp 3 gün boyunca saklayabileceğiniz, protein deposu taşınabilir ara öğün.',
      ingredients: [
        Ingredient('yumurta', 4, 'adet'),
        Ingredient('süt', 50, 'ml'),
        Ingredient('ıspanak', 1, 'avuç'),
        Ingredient('dolmalık biber', 0.5, 'adet'),
        Ingredient('hafif kaşar peyniri (rendelenmiş)', 30, 'g'),
      ],
      instructions: [
        'Yumurtaları süt, tuz ve karabiber ile iyice çırpın.',
        'İnce kıyılmış ıspanak ve biberi muffin kalıplarına paylaştırın.',
        'Üzerine çırpılmış yumurta karışımını dökün ve kaşar rendesi serpin.',
        '180°C fırında 15 dakika pişirin.',
      ],
    ),
  ];

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  final Set<String> _favoriteIds = {};

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF262626) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3D3D3D) : const Color(0xFFE5E7EB)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.black : (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey.shade500),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    final isFav = _favoriteIds.contains(recipe.id);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              recipe: recipe,
              isFavorite: isFav,
              onFavoriteToggled: () => _toggleFavorite(recipe.id),
            ),
          ),
        );
      },
      child: Builder(builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFEAEFF3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Image.network(
                    recipe.image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(Icons.restaurant_rounded, color: Color(0xFF94A3B8), size: 40),
                        ),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(recipe.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : const Color(0xFF64748B),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        recipe.category,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          recipe.calories,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, color: Colors.grey.shade400, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            recipe.prepTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(Icons.bar_chart_rounded, color: Colors.grey.shade400, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            recipe.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildMacroCapsule('${recipe.protein}g P', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                          const SizedBox(width: 4),
                          _buildMacroCapsule('${recipe.carbs}g K', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                          const SizedBox(width: 4),
                          _buildMacroCapsule('${recipe.fat}g Y', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      }),
    );
  }

  Widget _buildMacroCapsule(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: topPadding + 68,
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
            left: 20.0,
            right: 20.0,
            top: topPadding + 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (Navigator.canPop(context))
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
                        'TARİFLER',
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
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = RecipesScreen.recipes.where((recipe) {
      final matchesCategory = _selectedCategory == 'Tümü' || recipe.category == _selectedCategory;
      final matchesSearch = recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.01),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Tarif ara...',
                                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCategoryChip('Tümü'),
                              _buildCategoryChip('Kahvaltı'),
                              _buildCategoryChip('Öğle Yemeği'),
                              _buildCategoryChip('Akşam Yemeği'),
                              _buildCategoryChip('Atıştırmalık'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        filteredRecipes.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(40),
                                child: const Text(
                                  'Bu kategoride tarif bulunamadı.',
                                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredRecipes.length,
                                itemBuilder: (context, index) {
                                  return _buildRecipeCard(filteredRecipes[index]);
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAILED RECIPE SCREEN WITH INTERACTIVE PORTION ADJUSTER & CHECKLIST
// ─────────────────────────────────────────────────────────────────────────────

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;
  final bool isFavorite;
  final VoidCallback onFavoriteToggled;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteToggled,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _servings = 1;
  late List<bool> _checkedIngredients;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _checkedIngredients = List<bool>.filled(widget.recipe.ingredients.length, false);
  }

  void _toggleFavLocal() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteToggled();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalCalories = widget.recipe.baseCalories * _servings;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable body
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
                Hero(
                  tag: widget.recipe.id,
                  child: Image.network(
                    widget.recipe.image,
                    height: 360,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 360,
                        width: double.infinity,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(Icons.restaurant_rounded, color: Color(0xFF94A3B8), size: 48),
                        ),
                      );
                    },
                  ),
                ),
                
                // Overlapping Sheet
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.recipe.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Title
                        Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Prep Time & Difficulty Row
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: Colors.grey.shade400, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              widget.recipe.prepTime,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 18),
                            Icon(Icons.bar_chart_rounded, color: Colors.grey.shade400, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              widget.recipe.difficulty,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Benefit Card (Зачем / Польза)
                        if (widget.recipe.benefit != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FEE7), // Soft lime-green background
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                              border: Border(
                                left: BorderSide(color: AppColors.primary, width: 4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TARİFLERİN FAYDALARI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF4D7C0F),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.recipe.benefit!,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF3F6212),
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Interactive Dashboard Card (Servings & Nutrition)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131313), // Dark charcoal matching App theme
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Servings selector row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Porsiyon Sayısı',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Malzemeler güncellenecektir',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (_servings > 1) {
                                            setState(() {
                                              _servings--;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.remove_rounded, size: 16, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        '$_servings',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _servings++;
                                          });
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(color: Colors.white12, height: 1),
                              const SizedBox(height: 20),
                              
                              // Macros & Calories row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMacroItem('Kalori', '$totalCalories', 'kcal', AppColors.primary),
                                  _buildMacroItem('Protein', '${widget.recipe.protein * _servings}', 'g', const Color(0xFF86EFAC)),
                                  _buildMacroItem('Karbonhidrat', '${widget.recipe.carbs * _servings}', 'g', const Color(0xFF93C5FD)),
                                  _buildMacroItem('Yağ', '${widget.recipe.fat * _servings}', 'g', const Color(0xFFFDBA74)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Ingredients Section
                        const Text(
                          'MALZEMELER',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.recipe.ingredients.length,
                          itemBuilder: (context, index) {
                            final ing = widget.recipe.ingredients[index];
                            final isChecked = _checkedIngredients[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _checkedIngredients[index] = !isChecked;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isChecked ? const Color(0xFFF8FAFC) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isChecked ? const Color(0xFFE2E8F0) : const Color(0xFFEDF2F7),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isChecked ? AppColors.primary : Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isChecked ? Colors.transparent : const Color(0xFFCBD5E1),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isChecked
                                          ? const Center(
                                              child: Icon(Icons.check_rounded, color: Colors.black, size: 14),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        ing.displayAmount(_servings),
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          color: isChecked ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                          fontWeight: isChecked ? FontWeight.normal : FontWeight.w600,
                                          decoration: isChecked ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Step Stepper Section
                        const Text(
                          'HAZIRLANIŞI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.recipe.instructions.length,
                          itemBuilder: (context, index) {
                            final isLast = index == widget.recipe.instructions.length - 1;
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF131313),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: const Color(0xFFE2E8F0),
                                            margin: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ADIM ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF64748B),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.recipe.instructions[index],
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              color: Color(0xFF334155),
                                              height: 1.55,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Pinned Floating Action Bar (Back / Fav)
          Positioned(
            top: topPadding + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _toggleFavLocal,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 1),
            Text(
              unit,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
