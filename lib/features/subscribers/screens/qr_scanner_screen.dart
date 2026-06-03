import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';

class QrScannerScreen extends StatefulWidget {
  final String title;
  const QrScannerScreen({super.key, required this.title});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isScanned = false;
  bool _hasError = false;

  late AnimationController _animCtrl;
  late Animation<double> _scannerLineAnim;

  @override
  void initState() {
    super.initState();
    _initScannerAnimation();
  }

  void _initScannerAnimation() {
    _animCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scannerLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  void _handleScanSuccess(String code) {
    if (_isScanned) return;
    setState(() {
      _isScanned = true;
    });

    _controller.stop();
    
    // Play success feedback with decoded value
    CustomFeedback.show(
      context,
      'Giriş Başarılı!\nOkunan QR: $code',
      type: FeedbackType.success,
    );

    // Go back after feedback display delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.on:
                    return const Icon(Icons.flash_on_rounded, color: AppColors.primary);
                  default:
                    return const Icon(Icons.flash_off_rounded, color: Colors.white);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Mobile Scanner Feed ──────────────────────────────────────────
          Positioned.fill(
            child: _hasError
                ? _buildSimulatedFeed()
                : MobileScanner(
                    controller: _controller,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                        final String code = barcodes.first.rawValue!;
                        _handleScanSuccess(code);
                      }
                    },
                    errorBuilder: (context, error) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_hasError) {
                          setState(() {
                            _hasError = true;
                          });
                        }
                      });
                      return _buildSimulatedFeed();
                    },
                  ),
          ),

          // ── Scan Overlay Visual Mask ────────────────────────────────────
          Positioned.fill(
            child: _buildOverlayMask(),
          ),

          // ── Instruction & Control Overlay ──────────────────────────────
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _isScanned 
                            ? 'Giriş Onaylandı' 
                            : 'Kamerayı salondaki QR koda hizalayın',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_hasError) ...[
                  Text(
                    'Kamera başlatılamadı. Simülasyon aktif.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Manual QR input or Simulation trigger button for emulator/debugging
                GestureDetector(
                  onTap: () => _handleScanSuccess('ALP-GYM-9921-OK'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Text(
                      'Simüle Et: Barkod Algılandı',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedFeed() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF1E1E24), Color(0xFF090909)],
          radius: 1.2,
        ),
      ),
      child: const Center(
        child: Opacity(
          opacity: 0.1,
          child: Icon(Icons.qr_code_2_rounded, size: 200, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOverlayMask() {
    final size = MediaQuery.of(context).size;
    final double scanAreaSize = size.width * 0.7;

    return Stack(
      children: [
        // Semi-transparent backdrop with cut out square in center
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Finder Box Corners & Scanning Line Animation
        Center(
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
                _buildFinderCorner(Alignment.topLeft),
                _buildFinderCorner(Alignment.topRight),
                _buildFinderCorner(Alignment.bottomLeft),
                _buildFinderCorner(Alignment.bottomRight),

                if (!_isScanned)
                  AnimatedBuilder(
                    animation: _scannerLineAnim,
                    builder: (context, child) {
                      final topOffset = _scannerLineAnim.value * (scanAreaSize - 4);
                      return Positioned(
                        top: topOffset,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                if (_isScanned)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinderCorner(Alignment alignment) {
    const double size = 20;
    const double thickness = 4;
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              top: isTop ? 0 : null,
              bottom: !isTop ? 0 : null,
              left: 0,
              right: 0,
              child: Container(
                height: thickness,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              left: isLeft ? 0 : null,
              right: !isLeft ? 0 : null,
              top: 0,
              bottom: 0,
              child: Container(
                width: thickness,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
