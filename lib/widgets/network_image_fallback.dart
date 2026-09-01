import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Immagine di rete con placeholder di caricamento e fallback icona.
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

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: bg,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: bg,
          alignment: Alignment.center,
          child: Icon(fallbackIcon, color: iconColor, size: 32),
        );
      },
    );
  }
}
