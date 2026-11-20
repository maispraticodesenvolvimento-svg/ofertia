import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.dataUrl, this.icon = Icons.inventory_2_outlined, this.fit = BoxFit.cover});

  final String? dataUrl;
  final IconData icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final value = dataUrl;
    if (value != null && value.startsWith('data:image/')) {
      try {
        final comma = value.indexOf(',');
        if (comma > 0) {
          return Image.memory(
            base64Decode(value.substring(comma + 1)),
            fit: fit,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => _fallback(),
          );
        }
      } catch (_) {}
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        color: AppColors.grey100,
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.grey400, size: 38),
      );
}
