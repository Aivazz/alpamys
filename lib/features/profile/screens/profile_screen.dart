import 'package:flutter/material.dart';
import '../../../common_widgets/icons/uicons.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPress;

  const ProfileScreen({
    super.key,
    this.onBackPress,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileProvider().fetchProfile();
    });
  }

  Widget _buildStatItem(String val, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = ProfileProvider();

    return ListenableBuilder(
      listenable: profileProvider,
      builder: (context, child) {
        final profileData = profileProvider.profileData;
        final name = profileData['name']?.toString() ?? '';
        final weight = profileData['weight']?.toString() ?? '75';
        final weightUnit = profileData['weightUnit']?.toString() ?? 'KG';
        final height = profileData['height']?.toString() ?? '175';
        final heightUnit = profileData['heightUnit']?.toString() ?? 'CM';
        final age = profileData['age']?.toString() ?? '25';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: profileProvider.isLoading && name.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PROFİL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            IconButton(
                              icon: const UIconEdit(size: 24, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Profile Image & Info
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 54,
                                backgroundImage: profileProvider.getAvatarImage(),
                                backgroundColor: Colors.white10,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name.isNotEmpty ? name : 'Yükleniyor...',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: _buildStatItem(weight, weightUnit.toLowerCase(), 'Kilo')),
                            Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                            Expanded(child: _buildStatItem(height, heightUnit.toLowerCase(), 'Boy')),
                            Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                            Expanded(child: _buildStatItem(age, 'yaş', 'Yaş')),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
