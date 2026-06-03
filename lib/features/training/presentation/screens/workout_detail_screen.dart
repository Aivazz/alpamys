// lib/features/training/presentation/screens/workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/feedback/custom_feedback.dart';
import '../bloc/training_bloc.dart';
import '../bloc/training_event.dart';
import '../bloc/training_state.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> workoutData;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutData,
  });

  @override
  Widget build(BuildContext context) {
    final title = workoutData['title'] as String? ?? 'Antrenman Detayı';
    final imgUrl = workoutData['image'] as String? ?? '';
    final exercises = workoutData['exercises'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // CustomScrollView обеспечивает нативную переиспользуемость Slivers в памяти
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroAppBar(context, title, imgUrl),
              _buildWorkoutMetadata(workoutData),
              _buildExercisesSliverList(exercises),
              // Заглушка-отступ снизу, чтобы контент не перекрывался плавающей кнопкой старта
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildStickyBottomActionBar(context, title),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context, String title, String imgUrl) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFF131313),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imgUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const Center(child: Icon(Icons.fitness_center, size: 40)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.85)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutMetadata(Map<String, dynamic> data) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['desc'] as String? ?? '',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'EGZERSİZ AKIŞI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesSliverList(List<dynamic> exercises) {
    // SliverList рендерит элементы лениво, экономя память устройства
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final exercise = exercises[index] as Map<String, dynamic>;
            final name = exercise['name'] as String? ?? '';

            // Используем BlocBuilder для изоляции перерисовки конкретного элемента
            return BlocBuilder<TrainingBloc, TrainingState>(
              buildWhen: (previous, current) {
                if (previous is TrainingLoadedState && current is TrainingLoadedState) {
                  // Перерисовываем карточку ТОЛЬКО если изменился статус именно этого упражнения
                  final prevContains = previous.completedExercises.contains(name);
                  final currContains = current.completedExercises.contains(name);
                  return prevContains != currContains;
                }
                return true;
              },
              builder: (context, state) {
                final isCompleted = state is TrainingLoadedState && 
                                    state.completedExercises.contains(name);

                return _ExerciseCard(
                  index: index,
                  name: name,
                  sets: exercise['sets'] as String? ?? '',
                  desc: exercise['desc'] as String? ?? '',
                  duration: exercise['duration'] as String? ?? '',
                  isCompleted: isCompleted,
                  onTap: () {
                    context.read<TrainingBloc>().add(
                      ToggleExerciseCompletionEvent(exerciseName: name),
                    );
                  },
                );
              },
            );
          },
          childCount: exercises.length,
        ),
      ),
    );
  }

  Widget _buildStickyBottomActionBar(BuildContext context, String title) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                // Логика перехода к третьему этапу (Активная Сессия)
                CustomFeedback.show(context, 'Seans başlatılıyor...', type: FeedbackType.success);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    'ANTRENMANI BAŞLAT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Оптимизированный изолированный виджет карточки (Smart Редеринг)
class _ExerciseCard extends StatelessWidget {
  final int index;
  final String name;
  final String sets;
  final String desc;
  final String duration;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.index,
    required this.name,
    required this.sets,
    required this.desc,
    required this.duration,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? AppColors.primary.withOpacity(0.5) : const Color(0xFFE5E7EB),
          width: isCompleted ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Контейнер с порядковым номером
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : const Color(0xFF131313),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Текстовый блок
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? Colors.grey : Colors.black,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMiniBadge(Icons.repeat_rounded, sets),
                    const SizedBox(width: 8),
                    _buildMiniBadge(Icons.timer_outlined, duration),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}