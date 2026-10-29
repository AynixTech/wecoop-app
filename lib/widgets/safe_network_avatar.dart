import 'package:flutter/material.dart';

/// CircleAvatar che non propaga i fallimenti NetworkImage a FlutterError
/// (es. Spaces 403 su avatar privato legacy).
class SafeNetworkAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? placeholder;

  const SafeNetworkAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: url.isEmpty
          ? (placeholder ?? Icon(Icons.person, size: radius))
          : ClipOval(
              child: Image.network(
                url,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    placeholder ??
                    Icon(Icons.person, size: radius, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
    );
  }
}
