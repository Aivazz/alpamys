import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/api_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/home/screens/main_layout.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Resolve base URL for local backend dynamically
  await ApiService.resolveBaseUrl();

  // Determine initial route on app startup
  String initialRoute = '/';
  try {
    final prefs = await SharedPreferences.getInstance();
    
    bool isLoggedIn = false;
    if (Firebase.apps.isNotEmpty) {
      isLoggedIn = FirebaseAuth.instance.currentUser != null;
    } else {
      isLoggedIn = prefs.getBool('mock_logged_in') ?? false;
    }

    if (isLoggedIn) {
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      initialRoute = onboardingCompleted ? '/home' : '/onboarding';
    }
  } catch (e) {
    debugPrint("Error determining initial route: $e");
  }

  runApp(AlpamysApp(initialRoute: initialRoute));
}

class AlpamysApp extends StatelessWidget {
  final String initialRoute;
  const AlpamysApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider();
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, child) {
        return MaterialApp(
          title: 'Alpamys Pro Fitness',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          initialRoute: initialRoute,
          routes: {
            '/': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const MainLayout(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
          },
        );
      },
    );
  }
}
