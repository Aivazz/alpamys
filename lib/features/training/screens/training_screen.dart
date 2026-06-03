// lib/features/training/screens/training_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';
import '../presentation/bloc/training_bloc.dart';
import '../presentation/bloc/training_event.dart';
import '../presentation/bloc/training_state.dart';
import '../data/training_repository.dart';
import 'workout_detail_screen.dart';

// ─── Все виды тренировок (оставляем как есть, меняем только UI) ───────────────
const List<Map<String, dynamic>> kTrainingTypes = [
  {
    'title': 'Full Body',
    'subtitle': 'Tüm Vücut Antrenmanı',
    'desc': 'Her seansta tüm kas gruplarını çalıştırırsın. Başlangıç ve orta seviye için ideal.',
    'icon': Icons.accessibility_new_rounded,
    'color': Color(0xFF6C63FF),
    'tag': 'Haftada 3 Gün',
    'level': 'Başlangıç',
    'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Barbell Squat', 'sets': '4x10', 'desc': 'Bacak ve kalça gücü.', 'duration': '6 dk'},
      {'name': 'Bench Press', 'sets': '4x10', 'desc': 'Göğüs ve omuz gücü.', 'duration': '6 dk'},
      {'name': 'Barbell Row', 'sets': '4x8', 'desc': 'Sırt çekiş gücü.', 'duration': '5 dk'},
      {'name': 'Overhead Press', 'sets': '3x10', 'desc': 'Omuz itiş.', 'duration': '5 dk'},
      {'name': 'Romanian Deadlift', 'sets': '3x12', 'desc': 'Hamstring ve bel.', 'duration': '5 dk'},
    ],
  },
  {
    'title': 'PPL Split',
    'subtitle': 'Push / Pull / Legs',
    'desc': 'İtiş, çekiş ve bacak günleriyle kas gruplarını izole çalıştırırsın.',
    'icon': Icons.splitscreen_rounded,
    'color': Color(0xFFFF6584),
    'tag': 'Haftada 6 Gün',
    'level': 'Orta',
    'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Incline Dumbbell Press', 'sets': '4x12', 'desc': 'Üst göğüs.', 'duration': '6 dk'},
      {'name': 'Cable Fly', 'sets': '3x15', 'desc': 'Göğüs izolasyon.', 'duration': '4 dk'},
      {'name': 'Lat Pulldown', 'sets': '4x12', 'desc': 'Sırt genişliği.', 'duration': '5 dk'},
      {'name': 'Face Pull', 'sets': '3x20', 'desc': 'Arka omuz.', 'duration': '4 dk'},
      {'name': 'Leg Press', 'sets': '5x15', 'desc': 'Quads ve kalça.', 'duration': '7 dk'},
    ],
  },
  {
    'title': 'Powerlifting',
    'subtitle': 'Güç Antrenmanı',
    'desc': 'Squat, Bench Press ve Deadlift — maksimum kaldırma gücüne odaklanırsın.',
    'icon': Icons.fitness_center_rounded,
    'color': Color(0xFFFF8C42),
    'tag': 'Haftada 4 Gün',
    'level': 'İleri',
    'image': 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Back Squat', 'sets': '5x5', 'desc': 'Düşük tekrar, yüksek ağırlık.', 'duration': '10 dk'},
      {'name': 'Bench Press', 'sets': '5x5', 'desc': 'Ana itiş kuvveti.', 'duration': '10 dk'},
      {'name': 'Conventional Deadlift', 'sets': '3x3', 'desc': 'Maksimum yük kaldırma.', 'duration': '10 dk'},
      {'name': 'Close Grip Bench', 'sets': '4x6', 'desc': 'Bench desteği.', 'duration': '6 dk'},
    ],
  },
  {
    'title': 'Bodybuilding',
    'subtitle': 'Hipertrofi & Estetik',
    'desc': 'Kas hacmini ve simetrisini artırmak için orta ağırlık, yüksek tekrar.',
    'icon': Icons.self_improvement_rounded,
    'color': Color(0xFF43B89C),
    'tag': 'Haftada 5 Gün',
    'level': 'Orta / İleri',
    'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Dumbbell Curl', 'sets': '4x12', 'desc': 'Biceps hacmi.', 'duration': '5 dk'},
      {'name': 'Tricep Pushdown', 'sets': '4x15', 'desc': 'Triceps izolasyon.', 'duration': '5 dk'},
      {'name': 'Cable Lateral Raise', 'sets': '4x20', 'desc': 'Omuz genişliği.', 'duration': '4 dk'},
      {'name': 'Leg Extension', 'sets': '4x15', 'desc': 'Quad izolasyon.', 'duration': '5 dk'},
      {'name': 'Leg Curl', 'sets': '4x15', 'desc': 'Hamstring izolasyon.', 'duration': '5 dk'},
    ],
  },
  {
    'title': 'Strongman',
    'subtitle': 'En Güçlü Adam',
    'desc': 'Araç itme, kütük taşıma, atlas taşı gibi fonksiyonel güç yarışmaları.',
    'icon': Icons.sports_mma_rounded,
    'color': Color(0xFF8B5CF6),
    'tag': 'Haftada 3-4 Gün',
    'level': 'İleri',
    'image': 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Tire Flip', 'sets': '5x5 tekrar', 'desc': 'Patlayıcı güç.', 'duration': '8 dk'},
      {'name': 'Farmer\'s Walk', 'sets': '4x40m', 'desc': 'Tutuş ve core.', 'duration': '6 dk'},
      {'name': 'Log Press', 'sets': '4x6', 'desc': 'Omuz kuvveti.', 'duration': '7 dk'},
      {'name': 'Atlas Stone', 'sets': '3x3', 'desc': 'Fonksiyonel kuvvet.', 'duration': '8 dk'},
    ],
  },
  {
    'title': 'Olimpik Halter',
    'subtitle': 'Snatch & Clean & Jerk',
    'desc': 'Snatch ve Temiz-Silkme hareketleriyle patlayıcı güç и koordinasyon.',
    'icon': Icons.emoji_events_rounded,
    'color': Color(0xFFF59E0B),
    'tag': 'Haftada 5 Gün',
    'level': 'İleri',
    'image': 'https://images.unsplash.com/photo-1549576490-b0b4831ef60a?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Power Snatch', 'sets': '5x3', 'desc': 'Patlayıcı çekiş.', 'duration': '10 dk'},
      {'name': 'Clean & Jerk', 'sets': '5x2', 'desc': 'Tam olimpik hareket.', 'duration': '12 dk'},
      {'name': 'Front Squat', 'sets': '4x5', 'desc': 'Temiz pozisyon desteği.', 'duration': '7 dk'},
      {'name': 'Snatch Pull', 'sets': '4x4', 'desc': 'Çekiş kuvveti.', 'duration': '6 dk'},
    ],
  },
  {
    'title': 'CrossFit',
    'subtitle': 'WOD & Fonksiyonel',
    'desc': 'Yüksek yoğunluklu, çeşitli fonksiyonel hareketleri birleştiren dayanıklılık antrenmanı.',
    'icon': Icons.bolt_rounded,
    'color': Color(0xFFEF4444),
    'tag': 'Haftada 5 Gün',
    'level': 'Orta / İleri',
    'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Thruster', 'sets': '21-15-9', 'desc': 'Squat + Press.', 'duration': '8 dk'},
      {'name': 'Pull-up / Kipping', 'sets': '21-15-9', 'desc': 'Sırt ve tutuş.', 'duration': '6 dk'},
      {'name': 'Box Jump', 'sets': '4x10', 'desc': 'Patlayıcı bacak.', 'duration': '5 dk'},
      {'name': 'Kettlebell Swing', 'sets': '4x20', 'desc': 'Kalça ve core.', 'duration': '5 dk'},
    ],
  },
  {
    'title': 'Fonksiyonel',
    'subtitle': 'Fonksiyonel Güç',
    'desc': 'Günlük hayata aktarılan çok eklemli, doğal hareket kalıplarına dayalı antrenman.',
    'icon': Icons.directions_run_rounded,
    'color': Color(0xFF059669),
    'tag': 'Haftada 4 Gün',
    'level': 'Başlangıç / Orta',
    'image': 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=500&auto=format&fit=crop&q=80',
    'exercises': [
      {'name': 'Goblet Squat', 'sets': '4x12', 'desc': 'Derin squat mekaniği.', 'duration': '5 dk'},
      {'name': 'Single-Leg RDL', 'sets': '3x10', 'desc': 'Denge ve hamstring.', 'duration': '5 dk'},
      {'name': 'TRX Row', 'sets': '4x15', 'desc': 'Sırt ve core.', 'duration': '4 dk'},
      {'name': 'Pallof Press', 'sets': '3x12', 'desc': 'Anti-rotasyon core.', 'duration': '4 dk'},
      {'name': 'Sled Push', 'sets': '4x20m', 'desc': 'Bacak kondisyonu.', 'duration': '6 dk'},
    ],
  },
];

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String _selectedLevel = 'Hepsi';

  Future<void> _onRefresh(BuildContext context) async {
    context.read<TrainingBloc>().add(FetchWorkoutPlanEvent());
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrainingBloc>(
      create: (context) =>
          TrainingBloc(repository: TrainingRepository())
            ..add(FetchWorkoutPlanEvent()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildCategoryChips(),
                    _buildPersonalPlanSection(),
                    _buildTrainingTypesSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dark Top Background Block (just like in the market!)
        Container(
          width: double.infinity,
          height: topPadding + 220,
          decoration: const BoxDecoration(
            color: Color(0xFF131313),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        // Header Content
        Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: topPadding + 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation row
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
                    
                    // Center title badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(UIcons.regularRounded.gym, color: AppColors.primary, size: 12),
                            const SizedBox(width: 6),
                            const Text(
                              'ANTRENMAN PLANLARI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sınırlarını Zorla,\nHedefine Ulaş',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Uzmanlar tarafından hazırlanan profesyonel programlarla gücünü ve dayanıklılığını keşfet.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final chips = ['Hepsi', 'Başlangıç', 'Orta', 'İleri'];
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        itemBuilder: (context, i) {
          final chipName = chips[i];
          final isSelected = _selectedLevel == chipName;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLevel = chipName;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black
                    : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F3F5)),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  chipName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : const Color(0xFF7B8085),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalPlanSection() {
    final hideSection = DateTime.now().year >= 2026;
    if (hideSection) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        if (state is TrainingLoadingState) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _SectionTitle(title: 'Kişisel Planım', subtitle: 'Hazırlanıyor...'),
          );
        }
        if (state is! TrainingLoadedState || state.workoutDays.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _SectionTitle(
                title: 'Kişisel Planım',
                subtitle: 'Senin hedeflerine ve seviyene özel',
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.workoutDays.length,
                itemBuilder: (context, i) => _PersonalPlanCard(
                  workout: state.workoutDays[i],
                  trainingState: state,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildTrainingTypesSection() {
    final filteredTypes = kTrainingTypes.where((t) {
      if (_selectedLevel == 'Hepsi') return true;
      final level = t['level'] as String;
      return level.toLowerCase().contains(_selectedLevel.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: _SectionTitle(
            title: 'Antrenman Programları',
            subtitle: 'Kategorilere göre özel program listesi',
          ),
        ),
        ...filteredTypes.map((type) => _TrainingTypeCard(data: type)),
      ],
    );
  }
}

// ─── Kişisel Plan Kartı (Yatay Kaydırma) ─────────────────────────────────────
class _PersonalPlanCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final TrainingLoadedState trainingState;

  const _PersonalPlanCard({required this.workout, required this.trainingState});

  @override
  Widget build(BuildContext context) {
    final imgUrl = workout['image'] as String? ?? '';
    final title = workout['title'] as String? ?? '';
    final level = workout['level'] as String? ?? '';
    final exercises = workout['exercises'] as List<dynamic>? ?? [];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(
            workoutData: workout,
            parentState: trainingState,
            onToggleCompletion: (name) {
              context.read<TrainingBloc>().add(
                ToggleExerciseCompletionEvent(exerciseName: name),
              );
            },
          ),
        ),
      ),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Фоновая картинка
              if (imgUrl.isNotEmpty)
                Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(color: const Color(0xFF1E1E2E)),
                )
              else
                Container(color: const Color(0xFF1E1E2E)),

              // Градиентная маска
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Контент карточки
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge уровня
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        level.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Название
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Кол-во упражнений
                    Row(
                      children: [
                        Icon(UIcons.regularRounded.gym, color: Colors.white60, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          '${exercises.length} Egzersiz',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

// ─── Большой Карт Тренировки (Абсолютно Новый Premium Дизайн) ────────────────
class _TrainingTypeCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _TrainingTypeCard({required this.data});

  @override
  State<_TrainingTypeCard> createState() => _TrainingTypeCardState();
}

class _TrainingTypeCardState extends State<_TrainingTypeCard> {
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  @override
  void didUpdateWidget(covariant _TrainingTypeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadRating();
  }

  Future<void> _loadRating() async {
    final title = widget.data['title'] as String;
    try {
      final prefs = await SharedPreferences.getInstance();
      final r = prefs.getInt('workout_rating_$title') ?? 0;
      if (mounted) {
        setState(() {
          _rating = r;
        });
      }
    } catch (e) {
      debugPrint('Error loading rating in card: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] as String;
    final subtitle = widget.data['subtitle'] as String;
    final desc = widget.data['desc'] as String;
    final tag = widget.data['tag'] as String; // Частота
    final level = widget.data['level'] as String; // Сложность
    final imgUrl = widget.data['image'] as String? ?? '';
    final exercises = widget.data['exercises'] as List<dynamic>? ?? [];
    final color = widget.data['color'] as Color;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workoutData: widget.data),
        ),
      ).then((_) => _loadRating()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F3F5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть с премиум-картинкой и плашками
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Фоновое изображение
                    if (imgUrl.isNotEmpty)
                      Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(color: color.withOpacity(0.1)),
                      )
                    else
                      Container(color: color.withOpacity(0.1)),

                    // Градиентное затенение
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.75),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Содержимое поверх картинки
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Метка сложности и иконка в круге
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white24, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      level.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(widget.data['icon'] as IconData, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Заголовки
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
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
            // Описание и нижняя мета-информация
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7B8085),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Метаплашки (Дни тренировок и кол-во упражнений)
                  Row(
                    children: [
                      _MetaBadge(
                        icon: UIcons.regularRounded.calendar,
                        label: tag,
                        badgeColor: color,
                      ),
                      const SizedBox(width: 8),
                      _MetaBadge(
                        icon: UIcons.regularRounded.gym,
                        label: '${exercises.length} Egzersiz',
                        badgeColor: color,
                      ),
                      const SizedBox(width: 8),
                      _MetaBadge(
                        icon: Icons.star_rounded,
                        label: _rating > 0 ? '$_rating.0' : 'Oyla',
                        badgeColor: _rating > 0 ? Colors.amber : const Color(0xFF7B8085),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Кнопка действия (современная, без перегруженности)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workoutData: widget.data),
                        ),
                      ).then((_) => _loadRating()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Egzersizleri İncele',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(UIcons.regularRounded.arrow_right, size: 14, color: AppColors.primary),
                        ],
                      ),
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
}

// ─── Вспомогательные Виджеты ──────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7B8085),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color badgeColor;
  const _MetaBadge({required this.icon, required this.label, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.12), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
