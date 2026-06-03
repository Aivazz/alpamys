import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../profile/providers/profile_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  // Onboarding Answers State
  String _selectedGender = 'Erkek'; // Erkek / Kadın
  String _selectedActivity = 'Running'; // Running, Walking, Meal plan, Cycling, Yoga, Health
  int _selectedAge = 25;
  
  bool _isKg = true; // true = KG, false = LBS
  String _weightInput = '75';
  
  bool _isCm = true; // true = CM, false = FEET
  String _heightInput = '175';

  String _selectedLevel = 'Beginner'; // Beginner, Intermediate, Advanced
  String _selectedGoal = 'Improve fitness'; // Weight loss, Gain muscle, Improve fitness

  // Activity List data
  final List<Map<String, String>> _activities = [
    {
      'name': 'Running',
      'label': 'Koşu',
      'image': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=200&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Walking',
      'label': 'Yürüyüş',
      'image': 'https://images.unsplash.com/photo-1502224562085-639556652f33?w=200&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Meal plan',
      'label': 'Diyet',
      'image': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=200&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Cycling',
      'label': 'Bisiklet',
      'image': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=200&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Yoga',
      'label': 'Yoga',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Health',
      'label': 'Sağlık',
      'image': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=200&auto=format&fit=crop&q=60',
    },
  ];

  void _nextPage() async {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Completed, save onboarding details to Go backend
      final weight = double.tryParse(_weightInput) ?? 0.0;
      final height = double.tryParse(_heightInput) ?? 0.0;

      await ApiService.saveOnboarding(
        gender: _selectedGender,
        favoriteActivity: _selectedActivity,
        age: _selectedAge,
        weight: weight,
        weightUnit: _isKg ? 'kg' : 'lbs',
        height: height,
        heightUnit: _isCm ? 'cm' : 'feet',
        fitnessLevel: _selectedLevel,
        goal: _selectedGoal,
      );

      await ProfileProvider().fetchProfile();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _toggleWeightUnit(bool isKg) {
    if (_isKg == isKg) return;
    setState(() {
      _isKg = isKg;
      double? currentWeight = double.tryParse(_weightInput);
      if (currentWeight != null) {
        if (isKg) {
          // LBS to KG
          _weightInput = (currentWeight / 2.20462).round().toString();
        } else {
          // KG to LBS
          _weightInput = (currentWeight * 2.20462).round().toString();
        }
      }
    });
  }

  void _toggleHeightUnit(bool isCm) {
    if (_isCm == isCm) return;
    setState(() {
      _isCm = isCm;
      double? currentHeight = double.tryParse(_heightInput);
      if (currentHeight != null) {
        if (isCm) {
          // FEET to CM
          _heightInput = (currentHeight * 30.48).round().toString();
        } else {
          // CM to FEET
          _heightInput = (currentHeight / 30.48).toStringAsFixed(1);
        }
      }
    });
  }

  void _onKeyboardInput(String value) {
    setState(() {
      if (_currentStep == 3) {
        // Weight
        if (value == '.' && _weightInput.contains('.')) return;
        if (_weightInput.length < 5) {
          _weightInput = _weightInput == '0' && value != '.' ? value : _weightInput + value;
        }
      } else if (_currentStep == 4) {
        // Height
        if (value == '.' && _heightInput.contains('.')) return;
        if (_heightInput.length < 5) {
          _heightInput = _heightInput == '0' && value != '.' ? value : _heightInput + value;
        }
      }
    });
  }

  void _onKeyboardDelete() {
    setState(() {
      if (_currentStep == 3) {
        if (_weightInput.isNotEmpty) {
          _weightInput = _weightInput.substring(0, _weightInput.length - 1);
          if (_weightInput.isEmpty) _weightInput = '0';
        }
      } else if (_currentStep == 4) {
        if (_heightInput.isNotEmpty) {
          _heightInput = _heightInput.substring(0, _heightInput.length - 1);
          if (_heightInput.isEmpty) _heightInput = '0';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Premium Solid Dark
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(UIcons.regularRounded.angle_left, color: Colors.white, size: 22),
                    onPressed: _prevPage,
                  ),
                  Column(
                    children: [
                      Text(
                        'Adım ${_currentStep + 1} / $_totalSteps',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress Bar
                      Container(
                        width: 140,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 140 * ((_currentStep + 1) / _totalSteps),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Page contents
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildGenderStep(),
                  _buildFavoriteStep(),
                  _buildAgeStep(),
                  _buildWeightStep(),
                  _buildHeightStep(),
                  _buildLevelStep(),
                  _buildGoalStep(),
                ],
              ),
            ),

            // Action Button / Keyboard Area
            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  // BOTTOM AREA: Displays Custom Keyboard for weight/height steps, otherwise show "NEXT STEPS"
  Widget _buildBottomArea() {
    bool showKeyboard = _currentStep == 3 || _currentStep == 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showKeyboard) ...[
          // Numerical Custom Keyboard
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            child: Column(
              children: [
                // Submit row inside keyboard area
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _nextPage,
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'TAMAMLA' : 'SONRAKİ ADIM',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Numbers
                _buildKeyboardRow(['1', '2', '3']),
                const SizedBox(height: 12),
                _buildKeyboardRow(['4', '5', '6']),
                const SizedBox(height: 12),
                _buildKeyboardRow(['7', '8', '9']),
                const SizedBox(height: 12),
                _buildKeyboardRow(['.', '0', 'delete']),
              ],
            ),
          ),
        ] else ...[
          // Normal Next Button Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: _nextPage,
                child: Text(
                  _currentStep == _totalSteps - 1 ? 'TAMAMLA' : 'SONRAKİ ADIM',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Keyboard Rows Helper
  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const Expanded(child: SizedBox.shrink());
        }
        bool isDelete = key == 'delete';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Material(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: isDelete ? _onKeyboardDelete : () => _onKeyboardInput(key),
                splashColor: AppColors.primary.withOpacity(0.2),
                highlightColor: AppColors.primary.withOpacity(0.1),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
                  ),
                  child: isDelete
                      ? Icon(UIcons.regularRounded.arrow_left, color: Colors.white, size: 20)
                      : Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // STEP 1: Gender Selection
  Widget _buildGenderStep() {
    return _buildStepLayout(
      title: 'CİNSİYETİNİZ NEDİR?',
      subtitle: 'Antrenman programınızı biyolojinize en uygun şekilde optimize etmek için gereklidir.',
      child: Row(
        children: [
          Expanded(
            child: _buildGenderCard(
              gender: 'Erkek',
              icon: Icons.male,
              label: 'Erkek',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildGenderCard(
              gender: 'Kadın',
              icon: Icons.female,
              label: 'Kadın',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard({required String gender, required IconData icon, required String label}) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppColors.primary : Colors.white60,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Favorite Activity
  Widget _buildFavoriteStep() {
    return _buildStepLayout(
      title: 'FAVORİ AKTİVİTENİZ?',
      subtitle: 'En sevdiğiniz hareket planlarını öne çıkarmak için birini seçin.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final act = _activities[index];
          bool isSelected = _selectedActivity == act['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedActivity = act['name']!;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.15),
                      width: 2.5,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(act['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  act['label']!,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // STEP 3: Age Selector (Vertical Wheel)
  Widget _buildAgeStep() {
    return _buildStepLayout(
      title: 'KAÇ YAŞINDASINIZ?',
      subtitle: 'Metabolizma hızınızı ve gelişim hedeflerinizi hesaplamak için yaşınız önemlidir.',
      child: Center(
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Target selector highlight box
              Container(
                height: 52,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
              ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.003,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAge = 12 + index;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 88, // 12 to 100
                  builder: (context, index) {
                    int age = 12 + index;
                    bool isSelected = age == _selectedAge;
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        age.toString(),
                        style: TextStyle(
                          fontSize: isSelected ? 28 : 20,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : Colors.white38,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 4: Weight Input (Numerical Keyboard)
  Widget _buildWeightStep() {
    return _buildStepLayout(
      title: 'KİLONUZ NEDİR?',
      subtitle: 'Kalori yakım oranınızı doğru bir şekilde tahmin etmek için kilonuzu girin.',
      child: Column(
        children: [
          // Segmented unit selector (KG/LBS)
          _buildUnitSelector(
            val1: 'KG',
            val2: 'LBS',
            isSelected1: _isKg,
            onChanged: _toggleWeightUnit,
          ),
          const SizedBox(height: 36),
          // Large Weight value display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _weightInput,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isKg ? 'kg' : 'lbs',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 5: Height Input (Numerical Keyboard)
  Widget _buildHeightStep() {
    return _buildStepLayout(
      title: 'BOYUNUZ NEDİR?',
      subtitle: 'Vücut kitle indeksinizi (VKİ) hesaplamada kullanılacaktır.',
      child: Column(
        children: [
          // Segmented unit selector (CM/FEET)
          _buildUnitSelector(
            val1: 'CM',
            val2: 'FEET',
            isSelected1: _isCm,
            onChanged: _toggleHeightUnit,
          ),
          const SizedBox(height: 36),
          // Height value display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _heightInput,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isCm ? 'cm' : 'feet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 7: Fitness Level Selection
  Widget _buildLevelStep() {
    return _buildStepLayout(
      title: 'SPOR SEVİYENİZ?',
      subtitle: 'Antrenman yoğunluğunu size en uygun düzeyde tutmak için önemlidir.',
      child: Column(
        children: [
          _buildOptionCard(
            value: 'Beginner',
            label: 'Yeni Başlayan',
            desc: 'Egzersiz yapmaya yeni başladım veya uzun ara verdim.',
          ),
          const SizedBox(height: 14),
          _buildOptionCard(
            value: 'Intermediate',
            label: 'Orta Seviye',
            desc: 'Düzenli egzersiz yapıyorum ve kondisyonum yerinde.',
          ),
          const SizedBox(height: 14),
          _buildOptionCard(
            value: 'Advanced',
            label: 'İleri Seviye',
            desc: 'Yoğun antrenmanlara ve ağır egzersizlere alışığım.',
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({required String value, required String label, required String desc}) {
    bool isSelected = _selectedLevel == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.7) : Colors.white38,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 8: Goal Selection
  Widget _buildGoalStep() {
    return _buildStepLayout(
      title: 'HEDEFİNİZ NEDİR?',
      subtitle: 'Sizin için en doğru egzersiz ve beslenme önerilerini sunmak için gereklidir.',
      child: Column(
        children: [
          _buildGoalCard(
            value: 'Weight loss',
            label: 'Kilo Vermek',
            icon: UIcons.regularRounded.settings_sliders, // Placeholder icons or similar
          ),
          const SizedBox(height: 14),
          _buildGoalCard(
            value: 'Gain muscle',
            label: 'Kas Kütlesi Kazanmak',
            icon: UIcons.regularRounded.gym,
          ),
          const SizedBox(height: 14),
          _buildGoalCard(
            value: 'Improve fitness',
            label: 'Kondisyon Artırmak',
            icon: UIcons.regularRounded.heart,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({required String value, required String label, required IconData icon}) {
    bool isSelected = _selectedGoal == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white60,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Segmented Unit Selector helper (e.g. KG/LBS or CM/FEET)
  Widget _buildUnitSelector({
    required String val1,
    required String val2,
    required bool isSelected1,
    required Function(bool) onChanged,
  }) {
    return Container(
      width: 180,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  val1,
                  style: TextStyle(
                    color: isSelected1 ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isSelected1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  val2,
                  style: TextStyle(
                    color: !isSelected1 ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step template structure helper
  Widget _buildStepLayout({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withOpacity(0.5),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 36),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
