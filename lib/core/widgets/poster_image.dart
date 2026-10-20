import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';

class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholderIcon = Icons.live_tv_rounded,
  });

  final String? url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Alignment alignment;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final fallback = _Fallback(icon: placeholderIcon);
    final imageUrl = url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: fit,
                alignment: alignment,
                width: width,
                height: height,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) =>
                    const ColoredBox(color: AppColors.surfaceHigh),
                errorWidget: (context, url, error) => fallback,
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceHigh,
      child: Center(child: Icon(icon, color: AppColors.textSecondary)),
    );
  }
}
