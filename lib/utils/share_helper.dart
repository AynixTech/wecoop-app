import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Origine del popover di condivisione iOS (obbligatoria e non-zero).
///
/// Senza un Rect valido, `share_plus` crasha su iOS con:
/// `sharePositionOrigin: argument must be set, {{0, 0}, {0, 0}} must be non-zero`.
Rect sharePositionOrigin(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is RenderBox && renderObject.hasSize) {
    final size = renderObject.size;
    if (size.width > 0 && size.height > 0) {
      final rect = renderObject.localToGlobal(Offset.zero) & size;
      final screen = Offset.zero & MediaQuery.sizeOf(context);
      if (screen.overlaps(rect)) return rect;
    }
  }

  final screenSize = MediaQuery.sizeOf(context);
  return Rect.fromCenter(
    center: Offset(screenSize.width / 2, screenSize.height / 2),
    width: 1,
    height: 1,
  );
}

/// Share di testo con origine iOS sicura.
Future<ShareResult?> shareText(
  BuildContext context, {
  required String text,
  String? subject,
}) async {
  if (!context.mounted) return null;
  try {
    return await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin(context),
    );
  } catch (_) {
    // Evita crash non gestiti del foglio di sistema (es. origin invalida).
    return null;
  }
}
