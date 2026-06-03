import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uicons/uicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/auth_event.dart';
import '../presentation/bloc/auth_state.dart';
import '../../profile/providers/profile_provider.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUpInitially;
  const LoginScreen({super.key, this.isSignUpInitially = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLoginMode = !widget.isSignUpInitially;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_isLoginMode) {
        context.read<AuthBloc>().add(
          LoginSubmittedEvent(
            _emailController.text.trim(),
            _passwordController.text,
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          SignUpSubmittedEvent(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFF131313),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                CustomFeedback.show(
                  context,
                  state.message,
                  type: FeedbackType.warning,
                );
              }
              if (state is AuthSuccess) {
                ProfileProvider().fetchProfile();
                Navigator.pushReplacementNamed(
                  context,
                  state.onboardingCompleted ? '/home' : '/onboarding',
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 32),
                        _HeaderTitle(isLoginMode: _isLoginMode),
                        const SizedBox(height: 24),
                        _FormFields(
                          isLoginMode: _isLoginMode,
                          nameController: _nameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                        ),
                        if (_isLoginMode) const _ForgotPasswordButton(),
                        const SizedBox(height: 24),
                        _SubmitButton(
                          isLoading: isLoading,
                          isLoginMode: _isLoginMode,
                          onPressed: () => _submitForm(context),
                        ),
                        const SizedBox(height: 18),
                        const _SocialDivider(),
                        const SizedBox(height: 18),
                        const _GoogleSignInButton(),
                        const SizedBox(height: 24),
                        _ModeSwitcher(
                          isLoginMode: _isLoginMode,
                          onTap: () =>
                              setState(() => _isLoginMode = !_isLoginMode),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(UIcons.regularRounded.gym, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ALPAMYS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'PRO FITNESS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  final bool isLoginMode;
  const _HeaderTitle({required this.isLoginMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isLoginMode ? 'HOŞ GELDİNİZ' : 'HESAP OLUŞTUR',
            key: ValueKey<bool>(isLoginMode),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sağlıklı spor ve gelişim yolculuğunuza hemen adım atın.',
          style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
        ),
      ],
    );
  }
}

class _FormFields extends StatefulWidget {
  final bool isLoginMode;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _FormFields({
    required this.isLoginMode,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends State<_FormFields> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          if (!widget.isLoginMode) ...[
            _buildField(
              controller: widget.nameController,
              hintText: 'Adınız Soyadınız',
              prefixIcon: UIcons.regularRounded.user,
              validator: (val) => val == null || val.isEmpty
                  ? 'Lütfen adınızı soyadınızı girin'
                  : null,
            ),
            const SizedBox(height: 14),
          ],
          _buildField(
            controller: widget.emailController,
            hintText: 'E-posta Adresiniz',
            prefixIcon: UIcons.regularRounded.envelope,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Lütfen e-posta adresinizi girin';
              }
              if (!val.contains('@')) return 'Geçersiz e-posta formatı';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: widget.passwordController,
            hintText: 'Şifreniz',
            prefixIcon: UIcons.regularRounded.lock,
            isPassword: true,
            validator: (val) => val == null || val.isEmpty
                ? 'Lütfen şifrenizi girin'
                : (val.length < 6 ? 'Şifre en az 6 karakter olmalıdır' : null),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14.5),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 13.5,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white.withOpacity(0.5),
          size: 20,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? UIcons.regularRounded.eye_crossed
                      : UIcons.regularRounded.eye,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => CustomFeedback.show(
          context,
          'Şifre sıfırlama bağlantısı gönderildi!',
          type: FeedbackType.info,
        ),
        child: const Text(
          'Şifremi Unuttum?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isLoginMode;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.isLoginMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                isLoginMode ? 'GİRİŞ YAP' : 'KAYIT OL',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'veya şununla bağlan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1),
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.06),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
              height: 16,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 24);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Google ile Devam Et',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final bool isLoginMode;
  final VoidCallback onTap;

  const _ModeSwitcher({required this.isLoginMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            text: isLoginMode
                ? 'Hesabınız yok mu? '
                : 'Zaten hesabınız var mı? ',
            style: const TextStyle(color: Colors.white54, fontSize: 13.5),
            children: [
              TextSpan(
                text: isLoginMode ? 'Kayıt Ol' : 'Giriş Yap',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
