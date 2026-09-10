import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Immagine di rete con cache, downsampling e fallback icona.
/// Usa CachedNetworkImage per limitare memoria (Play Console bitmap warning).
class NetworkImageFallback extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;
  final Color? placeholderColor;

  const NetworkImageFallback({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.fallbackIconColor,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = fallbackIconColor ?? scheme.onSurfaceVariant;
    final bg = placeholderColor ?? AppColors.bgSubtle;

    if (url.trim().isEmpty) {
      return _fallback(bg, iconColor);
    }

    // Limita la decodifica bitmap alla dimensione di visualizzazione quando nota.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memW = width != null && width!.isFinite ? (width! * dpr).round() : null;
    final memH = height != null && height!.isFinite ? (height! * dpr).round() : null;

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memW,
      memCacheHeight: memH,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, _) => Container(
        width: width,
        height: height,
        color: bg,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, __) => _fallback(bg, iconColor),
    );
  }

  Widget _fallback(Color bg, Color iconColor) {
    return Container(
      width: width,
      height: height,
      color: bg,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: iconColor, size: 32),
    );
  }
}
