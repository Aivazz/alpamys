import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common_widgets/navigation/bottom_nav_bar.dart';
import '../../../common_widgets/icons/uicons.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../market/screens/market_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../recipes/screens/recipes_screen.dart';
import '../../training/screens/training_screen.dart';
import '../../subscribers/screens/subscribers_screen.dart';
import 'home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  late final List<Widget> _screens;

  Color get _sidebarBg => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _textColor => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get _subTextColor => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF374151);
  Color get _iconColor => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF4B5563);
  Color get _borderColor => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F3F5);
  Color get _closeBtnColor => Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _screens = [
      HomeScreen(onMenuPressed: _toggleMenu),
      const AIAssistantScreen(),
      const SubscribersScreen(showBackButton: false),
      ProfileScreen(onBackPress: () {
        setState(() {
          _currentIndex = 0;
        });
      }),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Widget _buildSidebarItem(Widget icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ??
          () {
            _toggleMenu();
            CustomFeedback.show(context, '$title yakında!', type: FeedbackType.info);
          },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Center(child: icon),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: _subTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(double width) {
    return SizedBox(
      width: width * 0.70,
      child: Container(
        color: _sidebarBg,
        padding: const EdgeInsets.fromLTRB(28.0, 48.0, 24.0, 24.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              GestureDetector(
                onTap: _toggleMenu,
                child: UIconClose(color: _closeBtnColor, size: 24),
              ),
              const SizedBox(height: 28),
              // Profile Area
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: ListenableBuilder(
                  listenable: ProfileProvider(),
                  builder: (context, child) {
                    final profileProvider = ProfileProvider();
                    final name = profileProvider.profileData['name']?.toString() ?? 'Sophia';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundImage: profileProvider.getAvatarImage(),
                          backgroundColor: Colors.white10,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),
              // Menu List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSidebarItem(
                      Icon(Icons.restaurant_menu_rounded, color: _iconColor, size: 24),
                      'Tarifler',
                      onTap: () {
                        _toggleMenu();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecipesScreen(),
                          ),
                        );
                      },
                    ),

                    _buildSidebarItem(
                      UIconTraining(color: _iconColor, size: 24),
                      'Antrenmanlar',
                      onTap: () {
                        _toggleMenu();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrainingScreen(),
                          ),
                        );
                      },
                    ),

                    _buildSidebarItem(
                      UIconMarket(color: _iconColor, size: 24),
                      'Market',
                      onTap: () {
                        _toggleMenu();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketScreen(),
                          ),
                        );
                      },
                    ),

                    _buildSidebarItem(
                      UIconSettings(color: _iconColor, size: 24),
                      'Ayarlar',
                      onTap: () {
                        _toggleMenu();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Logout at bottom
              _buildSidebarItem(
                UIconLogout(color: _iconColor, size: 24),
                'Çıkış Yap',
                onTap: () async {
                  _toggleMenu();
                  
                  // Reset profile memory
                  ProfileProvider().clearProfile();
                  
                  // Clear SharedPreferences session keys
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('mock_logged_in', false);
                    await prefs.setBool('onboarding_completed', false);
                    await prefs.remove('full_name');
                    await prefs.remove('email');
                    await prefs.remove('phone');
                    await prefs.remove('avatar');
                    await prefs.remove('gender');
                    await prefs.remove('weight');
                    await prefs.remove('weight_unit');
                    await prefs.remove('height');
                    await prefs.remove('height_unit');
                    await prefs.remove('age');
                    await prefs.remove('favorite_activity');
                    await prefs.remove('fitness_level');
                    await prefs.remove('goal');
                  } catch (e) {
                    debugPrint('Error clearing session on logout: $e');
                  }
                  
                  // Log out of Firebase if active
                  try {
                    if (Firebase.apps.isNotEmpty) {
                      await FirebaseAuth.instance.signOut();
                    }
                  } catch (e) {
                    debugPrint('Firebase sign out error: $e');
                  }
                  
                  // Navigate back to LoginScreen and clear entire navigation history
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final isMenuOpen = _animationController.value > 0.0;
        if (isMenuOpen) {
          _toggleMenu();
          return;
        }
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Sidebar always rendered below
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double fade = Tween<double>(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
              ).evaluate(_animationController);
              return Opacity(
                opacity: fade,
                child: child,
              );
            },
            child: _buildSidebar(width),
          ),

          // Main content with slide + scale
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double slideValue = Tween<double>(begin: 0.0, end: 0.70).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ).evaluate(_animationController);
              final double slide = slideValue * width;

              final double scale = Tween<double>(begin: 1.0, end: 0.78).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ).evaluate(_animationController);

              final double radius = Tween<double>(begin: 0.0, end: 32.0).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ).evaluate(_animationController);

              final isMenuOpen = _animationController.value > 0.0;

              return Transform(
                transform: Matrix4.translationValues(slide, 0.0, 0.0)
                  ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0)),
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_animationController.value * 0.18),
                          blurRadius: 32,
                          spreadRadius: 0,
                          offset: const Offset(-6, 10),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      behavior: isMenuOpen ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
                      onTap: isMenuOpen ? _toggleMenu : null,
                      child: AbsorbPointer(
                        absorbing: isMenuOpen,
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Scaffold(
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.03, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
              bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
                  ? null
                  : CustomBottomNavBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AIAssistantScreen(isFullScreen: true),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
