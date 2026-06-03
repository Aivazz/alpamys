import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../providers/profile_provider.dart';
import '../../../core/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;

  String _weightUnit = 'KG';
  String _heightUnit = 'CM';
  String _selectedGender = 'Female';
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final profileData = ProfileProvider().profileData;
    _nameController = TextEditingController(text: profileData['name']?.toString() ?? '');
    _phoneController = TextEditingController(text: profileData['phone']?.toString() ?? '');
    _emailController = TextEditingController(text: profileData['email']?.toString() ?? '');
    
    _weightUnit = (profileData['weightUnit']?.toString() ?? 'KG').toUpperCase();
    _heightUnit = (profileData['heightUnit']?.toString() ?? 'CM').toUpperCase();

    final rawWeight = double.tryParse(profileData['weight']?.toString() ?? '') ?? 0.0;
    _weightController = TextEditingController(text: rawWeight == 0.0 ? '' : rawWeight.toStringAsFixed(1));

    final rawHeight = double.tryParse(profileData['height']?.toString() ?? '') ?? 0.0;
    _heightController = TextEditingController(text: rawHeight == 0.0 ? '' : rawHeight.toStringAsFixed(_heightUnit == 'FEET' ? 2 : 1));

    _ageController = TextEditingController(text: profileData['age']?.toString() ?? '');
    _selectedGender = profileData['gender']?.toString() ?? 'Female';
    _selectedAvatar = profileData['avatar']?.toString();
  }

  void _onWeightUnitChanged(String newUnit) {
    if (_weightUnit == newUnit) return;
    final currentVal = double.tryParse(_weightController.text) ?? 0.0;
    double newVal = currentVal;
    if (newUnit == 'LBS') {
      newVal = currentVal * 2.20462;
    } else {
      newVal = currentVal / 2.20462;
    }
    setState(() {
      _weightUnit = newUnit;
      _weightController.text = newVal == 0.0 ? '' : newVal.toStringAsFixed(1);
    });
  }

  void _onHeightUnitChanged(String newUnit) {
    if (_heightUnit == newUnit) return;
    final currentVal = double.tryParse(_heightController.text) ?? 0.0;
    double newVal = currentVal;
    if (newUnit == 'FEET') {
      newVal = currentVal * 0.0328084;
    } else {
      newVal = currentVal / 0.0328084;
    }
    setState(() {
      _heightUnit = newUnit;
      _heightController.text = newVal == 0.0 ? '' : newVal.toStringAsFixed(newUnit == 'FEET' ? 2 : 1);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      CustomFeedback.show(context, 'Lütfen adı doldurun', type: FeedbackType.warning);
      return;
    }

    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final age    = int.tryParse(_ageController.text) ?? 0;
    final newEmail = _emailController.text.trim();

    final currentEmail = ProfileProvider().profileData['email']?.toString() ?? '';
    final emailChanged  = newEmail.isNotEmpty && newEmail != currentEmail;

    // Save non-email fields immediately
    ProfileProvider().updateProfile(
      name:       _nameController.text.trim(),
      phone:      _phoneController.text.trim(),
      email:      emailChanged ? currentEmail : newEmail, // keep old until verified
      weight:     weight,
      weightUnit: _weightUnit,
      height:     height,
      heightUnit: _heightUnit,
      gender:     _selectedGender,
      age:        age,
      avatar:     _selectedAvatar,
    );

    if (emailChanged) {
      // Prompt for current password before changing email in Firebase
      await _promptEmailChange(newEmail);
    } else {
      if (mounted) {
        CustomFeedback.show(context, 'Profil başarıyla güncellendi!', type: FeedbackType.success);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _promptEmailChange(String newEmail) async {
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              title: Text(
                'E-postayı Değiştir',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni adresinize doğrulama bağlantısı gönderilecek:\n$newEmail',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mevcut Şifre',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: obscure,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF131313) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () => setS(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Doğrula ve Güncelle', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final pwd = passwordCtrl.text.trim();
      if (pwd.isEmpty) {
        CustomFeedback.show(context, 'Mevcut şifrenizi girmelisiniz.', type: FeedbackType.warning);
        return;
      }

      if (mounted) {
        CustomFeedback.show(context, 'E-posta güncelleniyor...', type: FeedbackType.info);
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          // Reauthenticate
          final cred = EmailAuthProvider.credential(email: user.email!, password: pwd);
          await user.reauthenticateWithCredential(cred);

          // Update email in Firebase Auth (sends a verification email)
          await user.verifyBeforeUpdateEmail(newEmail);
          // Sync with Go backend to save updated email in database
          await ApiService.syncUser();

          // Update local provider
          ProfileProvider().updateProfile(email: newEmail);

          if (mounted) {
            CustomFeedback.show(context, 'E-posta başarıyla güncellendi! Lütfen gelen kutunuzu kontrol edin.', type: FeedbackType.success);
            Navigator.pop(context);
          }
        } else {
          // Mock mode
          ProfileProvider().updateProfile(email: newEmail);
          if (mounted) {
            CustomFeedback.show(context, 'E-posta başarıyla güncellendi! (MOCK)', type: FeedbackType.success);
            Navigator.pop(context);
          }
        }
      } catch (e) {
        debugPrint('Error updating email: $e');
        if (mounted) {
          String msg = 'E-posta güncellenemedi.';
          if (e.toString().contains('wrong-password') || e.toString().contains('invalid-credential')) {
            msg = 'Şifre hatalı. Lütfen tekrar deneyin.';
          } else if (e.toString().contains('email-already-in-use')) {
            msg = 'Bu e-posta adresi zaten kullanımda.';
          } else if (e.toString().contains('invalid-email')) {
            msg = 'Geçersiz bir e-posta adresi girdiniz.';
          }
          CustomFeedback.show(context, msg, type: FeedbackType.warning);
        }
      }
    }
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 18.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedAvatar = image.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        String msg = 'Görsel seçilemedi: $e';
        if (e.toString().contains('MissingPluginException') || e.toString().contains('no implementation')) {
          msg = 'Yeni eklenti eklendi. Lütfen uygulamayı durdurup yeniden başlatın (flutter run / rebuild).';
        } else if (e.toString().contains('permission_denied') || e.toString().contains('permission')) {
          msg = 'Kamera/Galeri erişim izni reddedildi. Lütfen ayarlardan izin verin.';
        }
        CustomFeedback.show(context, msg, type: FeedbackType.warning);
      }
    }
  }

  Widget _buildPhotoEditor(bool isDark) {
    final avatarUrl = _selectedAvatar ?? AppAssets.avatar;
    ImageProvider imgProvider;
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      imgProvider = NetworkImage(avatarUrl);
    } else if (kIsWeb) {
      imgProvider = NetworkImage(avatarUrl);
    } else {
      imgProvider = FileImage(File(avatarUrl));
    }

    return Center(
      child: GestureDetector(
        onTap: _showAvatarPicker,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: DecorationImage(
                  image: imgProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF131313) : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131313) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Profil Fotoğrafı Seç',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: Text(
                  'Galeriden Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              Divider(color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0)),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: Text(
                  'Fotoğraf Çek',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showGenderPicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131313) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  Text(
                    'Cinsiyet Seçimi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGenderOptionTile(
                    title: 'Kadın',
                    symbol: '♀',
                    isSelected: _selectedGender == 'Female',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedGender = 'Female';
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildGenderOptionTile(
                    title: 'Erkek',
                    symbol: '♂',
                    isSelected: _selectedGender == 'Male',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedGender = 'Male';
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGenderOptionTile({
    required String title,
    required String symbol,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? const Color(0xFF4E4E4E) : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(bool isDark) {
    return GestureDetector(
      onTap: () => _showGenderPicker(isDark),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _selectedGender == 'Female' ? '♀ ' : '♂ ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  _selectedGender == 'Female' ? 'Kadın' : 'Erkek',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'PROFİLİ DÜZENLE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing spacer
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildPhotoEditor(isDark),
                    const SizedBox(height: 24),
                    
                    _buildFieldLabel('Ad Soyad', isDark),
                    _buildTextField(
                      controller: _nameController,
                      isDark: isDark,
                      suffixIcon: Icon(Icons.check, color: isDark ? Colors.white : Colors.black, size: 20),
                    ),

                    _buildFieldLabel('Telefon', isDark),
                    _buildTextField(
                      controller: _phoneController,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildFieldLabel('E-posta Adresi', isDark),
                    _buildTextField(
                      controller: _emailController,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    _buildFieldLabel('Kilo', isDark),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          UnitToggle(
                            options: const ['LBS', 'KG'],
                            selectedOption: _weightUnit,
                            onChanged: _onWeightUnitChanged,
                          ),
                        ],
                      ),
                    ),

                    _buildFieldLabel('Boy', isDark),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          UnitToggle(
                            options: const ['FEET', 'CM'],
                            selectedOption: _heightUnit,
                            onChanged: _onHeightUnitChanged,
                          ),
                        ],
                      ),
                    ),

                    _buildFieldLabel('Cinsiyet', isDark),
                    _buildGenderDropdown(isDark),

                    _buildFieldLabel('Yaş', isDark),
                    _buildTextField(
                      controller: _ageController,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _saveProfile,
                        child: const Text(
                          'KAYDET',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnitToggle extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const UnitToggle({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selectedOption;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.black : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
