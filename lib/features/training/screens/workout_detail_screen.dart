// lib/features/training/screens/workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../presentation/bloc/training_state.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workoutData;
  final TrainingLoadedState? parentState;
  final Function(String)? onToggleCompletion;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutData,
    this.parentState,
    this.onToggleCompletion,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  // Набор для отслеживания развернутых упражнений
  final Set<String> _expandedExercises = {};
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final title = widget.workoutData['title'] as String? ?? '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final rating = prefs.getInt('workout_rating_$title') ?? 0;
      if (mounted) {
        setState(() {
          _currentRating = rating;
        });
      }
    } catch (e) {
      debugPrint('Error loading rating: $e');
    }
  }

  Future<void> _saveRating(int rating) async {
    final title = widget.workoutData['title'] as String? ?? '';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('workout_rating_$title', rating);
      if (mounted) {
        setState(() {
          _currentRating = rating;
        });
      }
      if (mounted) {
        CustomFeedback.show(
          context,
          'Değerlendirmeniz kaydedildi: $rating/5',
          type: FeedbackType.success,
        );
      }
    } catch (e) {
      debugPrint('Error saving rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.workoutData['title'] as String? ?? 'Antrenman Detayı';
    final imgUrl = widget.workoutData['image'] as String? ?? '';
    final exercises = widget.workoutData['exercises'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Премиум темный стиль
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroAppBar(context, title, imgUrl),
          _buildWorkoutMetadata(widget.workoutData),
          _buildExercisesSliverList(exercises),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context, String title, String imgUrl) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFF131313),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= MediaQuery.of(context).padding.top + kToolbarHeight + 8;
          final themeColor = widget.workoutData['color'] as Color? ?? AppColors.primary;
          final level = widget.workoutData['level'] as String? ?? 'Orta';
          final tag = widget.workoutData['tag'] as String? ?? 'Haftada 3 Gün';
          final subtitle = widget.workoutData['subtitle'] as String? ?? '';

          return FlexibleSpaceBar(
            centerTitle: true,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (imgUrl.isNotEmpty)
                  Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: Colors.white24,
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: Colors.white24,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: themeColor.withOpacity(0.35), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bar_chart_rounded, color: themeColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    level.toUpperCase(),
                                    style: TextStyle(
                                      color: themeColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutMetadata(Map<String, dynamic> data) {
    final exercises = data['exercises'] as List<dynamic>? ?? [];
    final themeColor = data['color'] as Color? ?? AppColors.primary;
    final level = data['level'] as String? ?? 'Orta';

    int totalMinutes = 0;
    for (final ex in exercises) {
      final durStr = ex['duration'] as String? ?? '';
      final match = RegExp(r'(\d+)').firstMatch(durStr);
      if (match != null) {
        totalMinutes += int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    final durationText = totalMinutes > 0 ? '$totalMinutes dk' : '25 dk';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data['desc'] != null) ...[
                    Text(
                      data['desc'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.timer_outlined,
                        color: themeColor,
                        value: durationText,
                        label: 'SÜRE',
                      ),
                      Container(width: 1, height: 32, color: Colors.white10),
                      _buildStatItem(
                        icon: Icons.fitness_center_rounded,
                        color: themeColor,
                        value: '${exercises.length} Hareket',
                        label: 'EGZERSİZ',
                      ),
                      Container(width: 1, height: 32, color: Colors.white10),
                      _buildStatItem(
                        icon: Icons.bar_chart_rounded,
                        color: themeColor,
                        value: level,
                        label: 'ZORLUK',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildRatingCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'EGZERSİZ AKIŞI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Bu Antrenmanı Değerlendir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentRating > 0
                ? 'Puanınız: $_currentRating / 5'
                : 'Programı oylamak için yıldızlara dokunun',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= _currentRating;
              return GestureDetector(
                onTap: () => _saveRating(starValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  curve: Curves.easeOut,
                  transform: isSelected
                      ? (Matrix4.identity()..scale(1.15))
                      : Matrix4.identity(),
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isSelected ? Colors.amber : Colors.white24,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSliverList(List<dynamic> exercises) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final exercise = exercises[index];
          final name = exercise['name'] as String? ?? '';
          final desc = exercise['desc'] as String? ?? '';
          final sets = exercise['sets'] as String? ?? '';
          final duration = exercise['duration'] as String? ?? '';
          final isCompleted =
              widget.parentState?.completedExercises.contains(name) ?? false;
          final isExpanded = _expandedExercises.contains(name);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E), // Цвет карточки как на скриншоте (iOS Dark Card)
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.06),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedExercises.remove(name);
                          } else {
                            _expandedExercises.add(name);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            // Иконка упражнения слева
                            _getExerciseIconWidget(name),
                            const SizedBox(width: 14),

                            // Центральный блок с текстом и бэджами
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isCompleted ? Colors.white54 : Colors.white,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (desc.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),

                                  // Бэджи сетов и времени в ряд
                                  Row(
                                    children: [
                                      if (sets.isNotEmpty)
                                        _buildRoundedBadge(
                                          Icons.repeat_rounded,
                                          sets,
                                        ),
                                      if (sets.isNotEmpty && duration.isNotEmpty)
                                        const SizedBox(width: 8),
                                      if (duration.isNotEmpty)
                                        _buildRoundedBadge(
                                          Icons.timer_outlined,
                                          duration,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Кнопка-стрелочка справа
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Выпадающее объяснение (анимированное появление)
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              color: Colors.white.withOpacity(0.08),
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            if (_getExerciseGifUrl(name).isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: Colors.black,
                                  height: 200,
                                  width: double.infinity,
                                  child: Image.network(
                                    _getExerciseGifUrl(name),
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image_outlined,
                                            color: Colors.white24,
                                            size: 32,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Görsel Yüklenemedi',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            const Text(
                              'NASIL YAPILIR?',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getExerciseExplanation(name),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.75),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: exercises.length),
      ),
    );
  }

  Widget _buildRoundedBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Цвет бэджа как на макете
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE5E5EA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getExerciseIconWidget(String name) {
    IconData iconData = Icons.fitness_center_rounded;
    Color iconColor = const Color(0xFFA3CB24); // default lime green accent

    final lowerName = name.toLowerCase();
    if (lowerName.contains('squat') || lowerName.contains('leg') || lowerName.contains('calf')) {
      iconData = Icons.accessibility_new_rounded;
      iconColor = const Color(0xFFFF9F0A); // Orange
    } else if (lowerName.contains('press') || lowerName.contains('bench') || lowerName.contains('fly') || lowerName.contains('push')) {
      iconData = Icons.fitness_center_rounded;
      iconColor = const Color(0xFF007AFF); // Blue
    } else if (lowerName.contains('row') || lowerName.contains('pull') || lowerName.contains('chin') || lowerName.contains('lat')) {
      iconData = Icons.sports_gymnastics_rounded;
      iconColor = const Color(0xFF30D158); // Green
    } else if (lowerName.contains('deadlift') || lowerName.contains('halter') || lowerName.contains('snatch')) {
      iconData = Icons.fitness_center_rounded;
      iconColor = const Color(0xFFBF5AF2); // Purple
    } else if (lowerName.contains('run') || lowerName.contains('walk') || lowerName.contains('jump') || lowerName.contains('sled')) {
      iconData = Icons.directions_run_rounded;
      iconColor = const Color(0xFFFF375F); // Red
    } else if (lowerName.contains('abs') || lowerName.contains('core') || lowerName.contains('swing')) {
      iconData = Icons.bolt_rounded;
      iconColor = const Color(0xFFFFD60A); // Yellow
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1), // subtle tint background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
    );
  }

  String _getExerciseGifUrl(String name) {
    final lowerName = name.toLowerCase();
    
    // Full Body & Strength compound movements (using omercotkd/exercises-gifs raw URLs)
    if (lowerName == 'barbell squat' || lowerName.contains('back squat') || (lowerName.contains('barbell') && lowerName.contains('squat'))) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0043.gif';
    } else if (lowerName == 'bench press' || (lowerName.contains('bench') && lowerName.contains('press'))) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0025.gif';
    } else if (lowerName == 'barbell row' || (lowerName.contains('barbell') && lowerName.contains('row'))) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0022.gif';
    } else if (lowerName == 'overhead press' || (lowerName.contains('overhead') && lowerName.contains('press')) || lowerName.contains('military press')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0040.gif';
    } else if (lowerName == 'romanian deadlift' || (lowerName.contains('romanian') && lowerName.contains('deadlift'))) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0085.gif';
    } else if (lowerName == 'deadlift' || lowerName.contains('deadlift')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0032.gif';
    }
    
    // Bodyweight & Home workouts
    else if (lowerName.contains('push-up') || lowerName.contains('pushup') || lowerName.contains('şınav')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0662.gif';
    } else if (lowerName.contains('plank')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0720.gif';
    } else if (lowerName.contains('burpee')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/1160.gif';
    } else if (lowerName.contains('mountain climber')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0630.gif';
    } else if (lowerName.contains('jump squat')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/3214.gif';
    } else if (lowerName.contains('squat') && !lowerName.contains('barbell')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0321.gif';
    }
    
    // Accessory / Isolation movements
    else if ((lowerName.contains('bicep') || lowerName.contains('dumbbell') || lowerName.contains('arm')) && lowerName.contains('curl')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0294.gif';
    } else if (lowerName.contains('tricep') && lowerName.contains('pushdown')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0200.gif';
    } else if (lowerName.contains('lat pulldown')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0150.gif';
    } else if (lowerName.contains('leg extension')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0585.gif';
    } else if (lowerName.contains('leg curl')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0599.gif';
    } else if (lowerName.contains('incline dumbbell press') || lowerName.contains('incline press')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0314.gif';
    } else if (lowerName.contains('cable fly')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0171.gif';
    } else if (lowerName.contains('face pull')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0193.gif';
    } else if (lowerName.contains('leg press')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0739.gif';
    } else if (lowerName.contains('lateral raise')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0334.gif';
    } else if (lowerName.contains('goblet squat')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/1760.gif';
    } else if (lowerName.contains('single-leg rdl') || lowerName.contains('single leg rdl')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0387.gif';
    } else if (lowerName.contains('trx row') || lowerName.contains('suspension row')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0808.gif';
    } else if (lowerName.contains('pallof press') || lowerName.contains('pallof')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0979.gif';
    } else if (lowerName.contains('thruster')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/3305.gif';
    } else if (lowerName.contains('pull-up') || lowerName.contains('pullup')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0652.gif';
    } else if (lowerName.contains('box jump')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/3213.gif';
    } else if (lowerName.contains('kettlebell swing')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0549.gif';
    }
    
    // Strongman exercises
    else if (lowerName.contains('tire flip')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/2459.gif';
    } else if (lowerName.contains('farmer')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/2133.gif';
    } else if (lowerName.contains('log press')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0028.gif';
    } else if (lowerName.contains('atlas stone')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0648.gif';
    }
    
    // Olympic Weightlifting (Olimpik Halter)
    else if (lowerName.contains('snatch pull')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0776.gif';
    } else if (lowerName.contains('snatch')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0067.gif';
    } else if (lowerName.contains('clean') && lowerName.contains('jerk')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0028.gif';
    } else if (lowerName.contains('front squat')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0042.gif';
    }
    
    // Functional exercises (Fonksiyonel)
    else if (lowerName.contains('sled push')) {
      return 'https://raw.githubusercontent.com/omercotkd/exercises-gifs/master/assets/0743.gif';
    }
    
    return '';
  }

  String _getExerciseExplanation(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('squat') && lowerName.contains('back')) {
      return "1. Barı trapez kaslarınızın üzerine yerleştirip dik durun.\n2. Kalçanızı geriye doğru iterek uyluklarınız yere paralel olana kadar derin bir squat pozisyonuna inin.\n3. Gövdenizin dikliğini koruyarak topuklarınızdan aldığınız güçle yukarı kalkın.\n* Dizlerinizin içeriye doğru bükülmesine izin vermeyin.";
    } else if (lowerName.contains('squat')) {
      return "1. Barı veya dumbbell'ı göğüs hizasında güvenli bir şekilde konumlandırın.\n2. Ayaklarınızı omuz genişliğinde açın, sırtınızı düz tutun.\n3. Karın kaslarınızı sıkarak kontrollü bir şekilde çömelin.\n4. Topuklarınızla yeri iterek dik duruşa geri dönün.\n* Ağırlığı kaldırırken nefes verin.";
    } else if (lowerName.contains('bench press') && lowerName.contains('close')) {
      return "1. Düz sehpaya uzanın ve barı omuz genişliğinden daha dar (yaklaşık 20-30 cm) kavrayın.\n2. Barı yavaşça alt göğsünüze doğru indirin, dirsekleri gövdenize yakın tutun.\n3. Arka kol (triceps) kaslarınızı sıkarak barı yukarı itin.\n* Bileklerinizi bükmemeye özen gösterin.";
    } else if (lowerName.contains('bench press')) {
      return "1. Düz sehpaya uzanın ve ayaklarınızı yere sabitleyin.\n2. Barı omuz genişliğinden biraz daha geniş tutun.\n3. Kontrollü bir şekilde barı göğsünüzün ortasına (meme ucu hizası) indirin.\n4. Göğüs kaslarınızı sıkarak barı yukarıya doğru itin.\n* Dirseklerinizi tamamen kilitlemeyin.";
    } else if (lowerName.contains('incline') && lowerName.contains('press')) {
      return "1. 30-45 derecelik eğimli sehpaya uzanın.\n2. Dumbbell'ları göğüs hizasında tutun, dirseklerinizi 90 derece bükün.\n3. Ağırlıkları yukarı doğru, göğüs üzerinde birleştirecek şekilde itin.\n4. Kontrollü bir şekilde başlangıç konumuna indirin.\n* Üst göğüs kaslarınızı odak noktası yapın.";
    } else if (lowerName.contains('row') && lowerName.contains('barbell')) {
      return "1. Barı omuz genişliğinde üstten tutuşla kavrayın.\n2. Dizlerinizi hafifçe bükün, gövdenizi 45 derece öne eğin ve sırtınızı düz tutun.\n3. Barı kontrollü bir şekilde alt karnınıza doğru çekin, kürek kemiklerinizi sıkıştırın.\n4. Yavaşça başlangıç pozisyonuna indirin.";
    } else if (lowerName.contains('lat pulldown')) {
      return "1. İstasyonun barını omuz genişliğinden daha geniş şekilde kavrayın ve oturun.\n2. Göğsünüzü hafifçe yukarı kaldırıp barı köprücük kemiğinize doğru çekin.\n3. Sırt kaslarınızı iyice sıkıştırın.\n4. Barı yavaşça yukarı bırakarak sırt kaslarınızı esnetin.";
    } else if (lowerName.contains('deadlift') && lowerName.contains('romanian')) {
      return "1. Barı kalça genişliğinde tutun.\n2. Sırtınız düz, dizleriniz çok hafif bükülü şekilde kalçanızı geriye doğru itin.\n3. Barı bacaklarınıza yakın tutarak kaval kemiklerinizin ortasına kadar indirin.\n4. Arka bacak (hamstring) ve kalça kaslarınızı sıkarak yukarı doğrulun.";
    } else if (lowerName.contains('deadlift')) {
      return "1. Ayaklarınızı barın altına yerleştirin.\n2. Kalçanızı indirip sırtınızı tamamen düz tutarak barı kavrayın.\n3. Ayaklarınızla yeri iterek gövdeniz dikleşene kadar ağırlığı kaldırın.\n4. Kalçanızı geriye iterek ağırlığı kontrollüce yere bırakın.";
    } else if (lowerName.contains('overhead press') || lowerName.contains('military press')) {
      return "1. Ayakta durun, barı omuz hizasında üstten tutuşla kavrayın.\n2. Gövdenizi dik tutarak ve karın kaslarınızı sıkarak barı başınızın üzerine doğru itin.\n3. Başınızı kollarınızın arasından hafifçe öne çıkararak tepe noktasında kilitleyin.\n4. Barı kontrollüce omuzlarınıza indirin.";
    } else if (lowerName.contains('curl')) {
      return "1. Ayakta dik durun, avuç içleriniz birbirine bakacak şekilde dumbbell'ları tutun.\n2. Dirseklerinizi sabitleyip ağırlıkları omuzlarınıza doğru kaldırın, kaldırırken bileğinizi çevirin.\n3. Biceps kasınızı sıkın ve yavaşça indirin.\n* Vücudunuzu sallamaktan kaçının.";
    } else if (lowerName.contains('pushdown')) {
      return "1. Kablo istasyonunda bar veya halatı kavrayın, dirseklerinizi gövdenize sabitleyin.\n2. Kollarınızı tamamen aşağıya doğru uzatarak triceps kaslarınızı kilitleyin.\n3. Yavaşça dirseklerinizi 90 derece olana kadar yukarı bırakın.\n* Omuzlarınızı hareket ettirmeyin.";
    } else if (lowerName.contains('lateral raise')) {
      return "1. Ayakta dik durun veya kablo makinesinin yan tarafına geçin.\n2. Ağırlığı dirseklerinizi hafif bükülü tutarak yana doğru omuz hizasına kadar kaldırın.\n3. Tepe noktasında kısa bir süre bekleyin ve yavaşça indirin.\n* Yan omuz kaslarınızı çalıştırır.";
    } else if (lowerName.contains('extension') && lowerName.contains('leg')) {
      return "1. Makineye oturun ve ayak bileklerinizi pedin arkasına yerleştirin.\n2. Bacaklarınızı tamamen düz olana kadar yukarı doğru kaldırıp uyluklarınızı sıkın.\n3. Yavaşça başlangıç noktasına indirin.\n* Ön bacak kaslarınızı izole eder.";
    } else if (lowerName.contains('leg curl')) {
      return "1. Makineye yüzüstü uzanın ve pedin ayak bileklerinizin hemen altında olduğundan emin olun.\n2. Topuklarınızı kalçanıza doğru çekerek arka bacak kaslarınızı sıkın.\n3. Kontrollü şekilde bacaklarınızı uzatın.\n* Arka bacak kaslarınızı izole eder.";
    } else if (lowerName.contains('pull-up') || lowerName.contains('chin-up')) {
      return "1. Barı omuz genişliğinden biraz daha geniş tutuşla kavrayın.\n2. Çeneniz barı geçene kadar kendinizi yukarı çekin, sırt kaslarınızı sıkın.\n3. Yavaşça başlangıç konumuna inin.\n* Kendi vücut ağırlığınızla en etkili sırt egzersizidir.";
    } else if (lowerName.contains('box jump')) {
      return "1. Kutunun önünde durun.\n2. Yarım squat yaparak kollarınızı geriye savurun ve patlayıcı bir şekilde kutunun üzerine zıplayın.\n3. Kutunun üzerine yumuşak bir şekilde, dizlerinizi bükerek inin.\n* Patlayıcı gücü ve kondisyonu artırır.";
    } else if (lowerName.contains('farmer\'s walk')) {
      return "1. İki elinize ağır dumbbell veya kettlebell alın.\n2. Omuzlarınızı geride, sırtınızı dik tutarak düz bir hat üzerinde adımlayın.\n3. Karın kaslarınızı sıkı tutarak kontrollü yürüyün.\n* Kavrama gücünü ve tüm vücut stabilitesini geliştirir.";
    } else if (lowerName.contains('kettlebell swing')) {
      return "1. Kettlebell'i iki elinizle kavrayın, ayaklarınızı genişçe açın.\n2. Kalçanızı geriye iterek kettlebell'i bacaklarınızın arasından savurun.\n3. Kalçanızı patlayıcı şekilde öne iterek ağırlığı omuz hizasına yükseltin.\n* Kalça ve core bölgesini güçlendirir.";
    } else if (lowerName.contains('fly')) {
      return "1. Kablo istasyonunda veya sehpada dumbbell'larla kolları yana açın.\n2. Dirseklerinizi hafif bükülü tutarak ağırlıkları göğüs üzerinde yarım daire çizecek şekilde birleştirin.\n3. Göğüs kaslarınızı sıkıştırın ve yavaşça açın.";
    } else {
      return "1. Hareketi duruşunuzu bozmadan, kontrollü ve nizami bir şekilde gerçekleştirin.\n2. Hedef kas grubundaki kasılmaya odaklanın.\n3. Hareket sırasında nefesinizi tutmayın, zorlanırken nefes verin.\n4. Setler arasında belirtilen dinlenme sürelerine uyun.";
    }
  }
}
