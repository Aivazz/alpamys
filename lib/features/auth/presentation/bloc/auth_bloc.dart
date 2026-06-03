import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<SignUpSubmittedEvent>(_onSignUpSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (Firebase.apps.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('mock_logged_in', true);
        await prefs.setString('email', event.email);
        await Future.delayed(const Duration(milliseconds: 600));
      } else {
        // Сначала авторизуем в Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
      }

      // После успешного входа синхронизируем сессию с Go бэкендом
      await ApiService.syncUser();
      final isCompleted = await ApiService.hasCompletedOnboarding();
      emit(AuthSuccess(onboardingCompleted: isCompleted));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (Firebase.apps.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('mock_logged_in', true);
        await prefs.setString('full_name', event.fullName);
        await prefs.setString('email', event.email);
        await Future.delayed(const Duration(milliseconds: 600));
      } else {
        // Данные попадают в Firebase Auth
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );
        // Записываем имя в профиль Firebase
        await credential.user?.updateDisplayName(event.fullName);
      }

      // Сразу после создания аккаунта в Firebase отправляем запрос на Go бэкенд,
      // чтобы создать зеркальную пустую запись в SQLite (alpamys.db)
      await ApiService.syncUser();
      emit(const AuthSuccess(onboardingCompleted: false));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Hatalı e-posta veya şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifreniz çok zayıf. En az 6 karakter olmalıdır.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
