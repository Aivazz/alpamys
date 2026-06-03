import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../providers/profile_provider.dart';

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

  /// Shows a dialog asking for the current password, then calls
  /// [verifyBeforeUpdateEmail] so Firebase sends a confirmation link.
  Future<void> _promptEmailChange(String newEmail) async {
    final passwordCtrl = TextEditingController();
    bool obscure = true;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'E-postayı Değiştir',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni adresinize doğrulama bağlantısı gönderilecek:\n$newEmail',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mevcut Şifre',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                            size: 18, color: Colors.grey),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Onayla', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        if (mounted) CustomFeedback.show(context, 'Kullanıcı bulunamadı.', type: FeedbackType.warning);
        return;
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Send verification link to new address
      await user.verifyBeforeUpdateEmail(newEmail);

      // Also update local cache so UI reflects intent immediately
      ProfileProvider().updateProfile(
        name:       _nameController.text.trim(),
        phone:      _phoneController.text.trim(),
        email:      newEmail,
        weight:     double.tryParse(_weightController.text) ?? 0.0,
        weightUnit: _weightUnit,
        height:     double.tryParse(_heightController.text) ?? 0.0,
        heightUnit: _heightUnit,
        gender:     _selectedGender,
        age:        int.tryParse(_ageController.text) ?? 0,
        avatar:     _selectedAvatar,
      );

      if (mounted) {
        CustomFeedback.show(
          context,
          '$newEmail adresine doğrulama bağlantısı gönderildi. Profil güncellendi!',
          type: FeedbackType.success,
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Şifre hatalı.';
          break;
        case 'email-already-in-use':
          msg = 'Bu e-posta zaten kullanımda.';
          break;
        case 'invalid-email':
          msg = 'Geçersiz e-posta adresi.';
          break;
        default:
          msg = 'Hata: ${e.message}';
      }
      if (mounted) CustomFeedback.show(context, msg, type: FeedbackType.warning);
    } catch (e) {
      if (mounted) {
        // If Firebase is not configured (dev/test), just save locally
        ProfileProvider().updateProfile(
          name:       _nameController.text.trim(),
          phone:      _phoneController.text.trim(),
          email:      newEmail,
          weight:     double.tryParse(_weightController.text) ?? 0.0,
          weightUnit: _weightUnit,
          height:     double.tryParse(_heightController.text) ?? 0.0,
          heightUnit: _heightUnit,
          gender:     _selectedGender,
          age:        int.tryParse(_ageController.text) ?? 0,
          avatar:     _selectedAvatar,
        );
        CustomFeedback.show(context, 'E-posta güncellendi (yerel).', type: FeedbackType.success);
        Navigator.pop(context);
      }
    } finally {
      passwordCtrl.dispose();
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 18.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563), // Slate gray label
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          // ignore: use_null_aware_elements
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

  Widget _buildPhotoEditor() {
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
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Profil Fotoğrafı Seç',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: const Text(
                  'Galeriden Seç',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text(
                  'Fotoğraf Çek',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const Text(
                    'Cinsiyet Seçimi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGenderOptionTile(
                    title: 'Kadın',
                    symbol: '♀',
                    isSelected: _selectedGender == 'Female',
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.06) : const Color(0xFFF9FAFB),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
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
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return GestureDetector(
      onTap: _showGenderPicker,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _selectedGender == 'Female' ? 'Kadın' : 'Erkek',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'PROFİLİ DÜZENLE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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
                    _buildPhotoEditor(),
                    const SizedBox(height: 24),
                    
                    _buildFieldLabel('Ad Soyad'),
                    _buildTextField(
                      controller: _nameController,
                      suffixIcon: const Icon(Icons.check, color: Colors.black, size: 20),
                    ),

                    _buildFieldLabel('Telefon'),
                    _buildTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildFieldLabel('E-posta Adresi'),
                    _buildTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    _buildFieldLabel('Kilo'),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
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

                    _buildFieldLabel('Boy'),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
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

                    _buildFieldLabel('Cinsiyet'),
                    _buildGenderDropdown(),

                    _buildFieldLabel('Yaş'),
                    _buildTextField(
                      controller: _ageController,
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
                            color: Colors.white,
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
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB), // Grey background for toggle container
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
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.black : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
