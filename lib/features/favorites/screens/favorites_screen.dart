import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';

class FavoriteExercise {
  final String id;
  final String name;
  final String category;
  final String setsReps;
  final String difficulty;

  FavoriteExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.setsReps,
    required this.difficulty,
  });
}

class FavoriteRecipe {
  final String id;
  final String name;
  final String mealType;
  final String calories;
  final String macros;

  FavoriteRecipe({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.macros,
  });
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Local state for list item removals
  final List<FavoriteExercise> _exercises = [
    FavoriteExercise(
      id: 'ex_1',
      name: 'Incline Dumbbell Press',
      category: 'Göğüs Egzersizi',
      setsReps: '4 Set x 12 Tekrar',
      difficulty: 'Orta Seviye',
    ),
    FavoriteExercise(
      id: 'ex_2',
      name: 'Barbell Squat (Çömelme)',
      category: 'Bacak Egzersizi',
      setsReps: '4 Set x 8 Tekrar',
      difficulty: 'İleri Seviye',
    ),
    FavoriteExercise(
      id: 'ex_3',
      name: 'Pull-Ups (Barfiks)',
      category: 'Sırt Egzersizi',
      setsReps: '3 Set x Maksimum',
      difficulty: 'Orta Seviye',
    ),
  ];

  final List<FavoriteRecipe> _recipes = [
    FavoriteRecipe(
      id: 'rec_1',
      name: 'Yulaflı Protein Pankek',
      mealType: 'Kahvaltı',
      calories: '450 kcal',
      macros: 'P: 35g | K: 50g | Y: 10g',
    ),
    FavoriteRecipe(
      id: 'rec_2',
      name: 'Fırında Sebzeli Tavuk Göğsü',
      mealType: 'Akşam Yemeği',
      calories: '520 kcal',
      macros: 'P: 50g | K: 20g | Y: 12g',
    ),
  ];

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

  void _removeExercise(FavoriteExercise exercise) {
    setState(() {
      _exercises.removeWhere((item) => item.id == exercise.id);
    });
    CustomFeedback.show(
      context,
      '${exercise.name} favorilerden kaldırıldı',
      type: FeedbackType.info,
    );
  }

  void _removeRecipe(FavoriteRecipe recipe) {
    setState(() {
      _recipes.removeWhere((item) => item.id == recipe.id);
    });
    CustomFeedback.show(
      context,
      '${recipe.name} favorilerden kaldırıldı',
      type: FeedbackType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // 1. Dark Top Header
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
                          'FAVORİLERİM',
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
                  'Hızlı erişim için kaydettiğiniz egzersizler ve yemek tarifleri',
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

          // 2. Tab Bar Selector
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
                  Tab(text: 'Egzersizler'),
                  Tab(text: 'Yemek Tarifleri'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Tab Bar View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExercisesList(),
                _buildRecipesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    if (_exercises.isEmpty) {
      return _buildEmptyState(
        icon: Icons.fitness_center_rounded,
        message: 'Henüz favori egzersiz eklemediniz.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Dumbbell circle avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.category,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniBadge(Icons.repeat, exercise.setsReps),
                          const SizedBox(width: 8),
                          _buildMiniBadge(Icons.bolt, exercise.difficulty),
                        ],
                      ),
                    ],
                  ),
                ),
                // Heart Action button
                GestureDetector(
                  onTap: () => _removeExercise(exercise),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipesList() {
    if (_recipes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_menu_rounded,
        message: 'Henüz favori tarif eklemediniz.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Cooking icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recipe.mealType,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniBadge(Icons.local_fire_department_rounded, recipe.calories, badgeColor: const Color(0xFFFFEBEE), textColor: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniBadge(Icons.assessment_rounded, recipe.macros),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Heart Action button
                GestureDetector(
                  onTap: () => _removeRecipe(recipe),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniBadge(IconData icon, String label, {Color badgeColor = const Color(0xFFF3F4F6), Color textColor = const Color(0xFF4B5563)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Geri Dön',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
