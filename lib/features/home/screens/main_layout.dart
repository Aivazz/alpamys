import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common_widgets/navigation/bottom_nav_bar.dart';
import '../../../common_widgets/icons/uicons.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../../core/utils/responsive.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../market/screens/market_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../recipes/screens/recipes_screen.dart';
import '../../training/screens/training_screen.dart';
import '../../subscribers/screens/subscribers_screen.dart';
import '../../subscribers/services/subscription_service.dart';
import 'home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animCtrl;

  // Экраны создаются один раз и не пересоздаются
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _screens = [
      RepaintBoundary(child: HomeScreen(onMenuPressed: _toggleMenu)),
      const RepaintBoundary(child: AIAssistantScreen()),
      const RepaintBoundary(child: SubscribersScreen(showBackButton: false)),
      RepaintBoundary(
        child: ProfileScreen(onBackPress: () => setState(() => _currentIndex = 0)),
      ),
    ];
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    HapticFeedback.lightImpact();
    if (_animCtrl.isCompleted) {
      _animCtrl.reverse();
    } else {
      _animCtrl.forward();
    }
  }

  // ── Sidebar ─────────────────────────────────────────────────────────
  Widget _buildSidebar(double width, bool isDark) {
    final sidebarW = (width * 0.72).clamp(240.0, 320.0);

    final bgColor  = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white70 : const Color(0xFF374151);
    final iconCol  = isDark ? Colors.white60 : const Color(0xFF4B5563);
    final divColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F3F5);

    return RepaintBoundary(
      child: SizedBox(
        width: sidebarW,
        child: Container(
          color: bgColor,
          padding: EdgeInsets.fromLTRB(R.lg, R.xl + 8, R.md, R.md),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _toggleMenu,
                  child: UIconClose(color: txtColor, size: R.iconMd),
                ),
                SizedBox(height: R.lg),

                // Profile snapshot — ListenableBuilder изолирован
                ListenableBuilder(
                  listenable: ProfileProvider(),
                  builder: (context, _) {
                    final pp = ProfileProvider();
                    final name = pp.profileData['name']?.toString() ?? 'Kullanıcı';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: R.sp(42),
                          backgroundImage: pp.getAvatarImage(),
                          backgroundColor: Colors.white10,
                        ),
                        SizedBox(height: R.md),
                        Text(
                          name,
                          style: TextStyle(
                            color: txtColor,
                            fontSize: R.sp(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: R.xl),

                // Menu items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _menuItem(
                        icon: Icon(Icons.restaurant_menu_rounded, color: iconCol, size: R.iconMd),
                        label: 'Tarifler',
                        divColor: divColor,
                        subColor: subColor,
                        onTap: () {
                          _toggleMenu();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RecipesScreen()));
                        },
                      ),
                      _menuItem(
                        icon: UIconTraining(color: iconCol, size: R.iconMd),
                        label: 'Antrenmanlar',
                        divColor: divColor,
                        subColor: subColor,
                        onTap: () {
                          _toggleMenu();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const TrainingScreen()));
                        },
                      ),
                      _menuItem(
                        icon: UIconMarket(color: iconCol, size: R.iconMd),
                        label: 'Market',
                        divColor: divColor,
                        subColor: subColor,
                        onTap: () {
                          _toggleMenu();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const MarketScreen()));
                        },
                      ),
                      _menuItem(
                        icon: UIconSettings(color: iconCol, size: R.iconMd),
                        label: 'Ayarlar',
                        divColor: divColor,
                        subColor: subColor,
                        onTap: () {
                          _toggleMenu();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        },
                      ),
                    ],
                  ),
                ),

                // Logout
                _menuItem(
                  icon: UIconLogout(color: iconCol, size: R.iconMd),
                  label: 'Çıkış Yap',
                  divColor: divColor,
                  subColor: subColor,
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required Widget icon,
    required String label,
    required Color divColor,
    required Color subColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {
        _toggleMenu();
        CustomFeedback.show(context, '$label yakında!', type: FeedbackType.info);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: divColor, width: 1)),
        ),
        child: Row(
          children: [
            SizedBox(width: R.lg, child: Center(child: icon)),
            SizedBox(width: R.sm + 4),
            Text(
              label,
              style: TextStyle(
                color: subColor,
                fontSize: R.sp(15),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    _toggleMenu();
    ProfileProvider().clearProfile();
    SubscriptionService().clearCache();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mock_logged_in', false);
      await prefs.setBool('onboarding_completed', false);
      await prefs.remove('full_name');
      await prefs.remove('email');
    } catch (e) {
      debugPrint('Logout prefs error: $e');
    }
    try {
      if (Firebase.apps.isNotEmpty) await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Firebase signout error: $e');
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    R.init(context); // инициализируем responsive один раз на root

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width  = MediaQuery.sizeOf(context).width;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_animCtrl.value > 0.0) { _toggleMenu(); return; }
        if (_currentIndex != 0) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Sidebar (только рендерится когда меню открыто/анимируется)
            AnimatedBuilder(
              animation: _animCtrl,
              builder: (context, child) {
                final fade = Curves.easeOut.transform(
                  (((_animCtrl.value - 0.3) / 0.7).clamp(0.0, 1.0)),
                );
                return Opacity(opacity: fade, child: child);
              },
              child: _buildSidebar(width, isDark),
            ),

            // Main content (slide + scale)
            AnimatedBuilder(
              animation: _animCtrl,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(_animCtrl.value);
                final slide  = t * width * 0.70;
                final scale  = 1.0 - t * 0.22;
                final radius = t * 32.0;
                final isOpen = _animCtrl.value > 0.0;

                return Transform(
                  transform: Matrix4.translationValues(slide, 0, 0)
                    ..scale(scale, scale),
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: isOpen
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(_animCtrl.value * 0.18),
                                  blurRadius: 32,
                                  offset: const Offset(-6, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: GestureDetector(
                        behavior: isOpen ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
                        onTap: isOpen ? _toggleMenu : null,
                        child: AbsorbPointer(
                          absorbing: isOpen,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Scaffold(
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: child,
                  ),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: _screens[_currentIndex],
                  ),
                ),
                bottomNavigationBar: keyboardOpen
                    ? null
                    : CustomBottomNavBar(
                        currentIndex: _currentIndex,
                        onTap: (index) {
                          if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AIAssistantScreen(isFullScreen: true),
                              ),
                            );
                            return;
                          }
                          if (index != _currentIndex) {
                            HapticFeedback.selectionClick();
                            setState(() => _currentIndex = index);
                          }
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
