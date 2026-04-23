import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.fallbackIcon = Icons.person_rounded,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = Colors.white,
  });

  final double radius;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return _fallback();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackContent(),
        ),
      ),
    );
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: _fallbackContent(),
    );
  }

  Widget _fallbackContent() {
    return Icon(fallbackIcon, color: iconColor, size: radius);
  }
}
