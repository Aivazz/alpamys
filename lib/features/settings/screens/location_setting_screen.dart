import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/providers/profile_provider.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  bool _isLocating = false;
  String _currentLocationName = 'Yükleniyor...';
  String _coordinatesText = '---';

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  void _loadLocationData() async {
    final profileProvider = ProfileProvider();
    final location = profileProvider.profileData['location']?.toString() ?? 'Almatı';
    
    final prefs = await SharedPreferences.getInstance();
    final cachedCoords = prefs.getString('location_coords') ?? '---';
    
    setState(() {
      _currentLocationName = location;
      _coordinatesText = cachedCoords;
    });
  }

  Future<void> _determineLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Konum servisleri kapalı. Lütfen GPS özelliğini açın.';
      }

      // 2. Request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Konum erişim izni reddedildi.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Konum izinleri kalıcı olarak reddedilmiş. Ayarlardan açmanız gerekir.';
      }

      // 3. Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final double lat = position.latitude;
      final double lon = position.longitude;
      final String formattedCoords = '${lat.toStringAsFixed(4)}° ${lat >= 0 ? "N" : "S"}, ${lon.toStringAsFixed(4)}° ${lon >= 0 ? "E" : "W"}';

      String detectedPlace = '';

      try {
        // 4. Reverse geocoding (global, explicitly in Turkish)
        await setLocaleIdentifier('tr_TR');
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final city = p.locality?.isNotEmpty == true 
              ? p.locality 
              : (p.subAdministrativeArea?.isNotEmpty == true 
                  ? p.subAdministrativeArea 
                  : p.administrativeArea);
          detectedPlace = city ?? '';
        }
      } catch (e) {
        debugPrint("Reverse geocoding failed: $e");
      }

      if (detectedPlace.isEmpty) {
        detectedPlace = 'Konum Belirlendi';
      }

      setState(() {
        _currentLocationName = '$detectedPlace (GPS)';
        _coordinatesText = formattedCoords;
        _isLocating = false;
      });

      // Save to ProfileProvider and SharedPreferences
      final profileProvider = ProfileProvider();
      profileProvider.updateLocation('$detectedPlace (GPS)', latitude: lat, longitude: lon);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('location_coords', formattedCoords);

      if (!mounted) return;
      CustomFeedback.show(
        context,
        'Konum güncellendi: $detectedPlace',
        type: FeedbackType.success,
      );

    } catch (e) {
      debugPrint("Location error: $e");
      
      // If native plugin is missing (needs a rebuild)
      if (e.toString().contains('MissingPluginException') || e.toString().contains('No implementation found')) {
        _runSimulation();
        return;
      }

      setState(() {
        _isLocating = false;
      });
      
      if (!mounted) return;
      CustomFeedback.show(
        context,
        e.toString(),
        type: FeedbackType.warning,
      );
    }
  }

  void _runSimulation() {
    if (!mounted) return;
    CustomFeedback.show(
      context,
      'GPS eklentisi derleme gerektiriyor. Tam yeniden başlatma yapın. Simülasyon çalıştırılıyor...',
      type: FeedbackType.info,
    );

    Timer(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        const simCity = 'New York';
        const simCoords = '40.7128° N, 74.0060° W';
        
        setState(() {
          _currentLocationName = '$simCity (GPS)';
          _coordinatesText = simCoords;
          _isLocating = false;
        });

        final profileProvider = ProfileProvider();
        profileProvider.updateLocation('$simCity (GPS)', latitude: 40.7128, longitude: -74.0060);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('location_coords', simCoords);

        if (!mounted) return;
        CustomFeedback.show(
          context,
          'Konum güncellendi (Simülasyon): $simCity',
          type: FeedbackType.success,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Compact, elegant)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: topPadding + 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF131313),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: topPadding + 12.0),
                child: SizedBox(
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
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                UIcons.regularRounded.angle_left,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'KONUM AYARLARI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Simple Card showing current status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Geçerli Konum',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentLocationName,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFF3F4F6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kanal',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'GPS / Uydudan Otomatik',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Koordinatlar',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _coordinatesText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Single elegant action button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLocating ? null : _determineLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLocating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Konum Alınıyor...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Konumu Otomatik Güncelle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
