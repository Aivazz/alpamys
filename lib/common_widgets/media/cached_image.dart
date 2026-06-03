import 'package:flutter/material.dart';

/// Кешированный сетевой виджет изображения с RepaintBoundary.
/// Использует встроенный Image.network с memCacheWidth/memCacheHeight
/// для экономии памяти, и корректный плейсхолдер/ошибка-билдер.
class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorChild;
  final Color? placeholderColor;

  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorChild,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phColor = placeholderColor ??
        (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6));

    Widget img;
    if (url.isEmpty) {
      img = _buildError(phColor, isDark);
    } else {
      // memCacheWidth limits GPU texture size → less VRAM usage
      final memW = width != null ? (width! * 2).round() : null;
      final memH = height != null ? (height! * 2).round() : null;
      img = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memW,
        cacheHeight: memH,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: frame == null
                ? _buildPlaceholder(phColor)
                : child,
          );
        },
        errorBuilder: (ctx, err, trace) => _buildError(phColor, isDark),
      );
    }

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }

    return RepaintBoundary(child: img);
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      key: const ValueKey('placeholder'),
      width: width,
      height: height,
      color: color,
    );
  }

  Widget _buildError(Color bgColor, bool isDark) {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      child: errorChild ??
          Icon(
            Icons.image_not_supported_outlined,
            size: (height != null ? height! * 0.35 : 28.0).clamp(18.0, 48.0),
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
    );
  }
}
