import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/poster_image.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';

/// Row layout used by Search results and the Watchlist.
class ShowListTile extends StatelessWidget {
  const ShowListTile({
    super.key,
    required this.show,
    required this.onTap,
    this.trailing,
  });

  final Show show;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final years = show.yearsLabel;
    final genres = show.genresLabel(3);
    final rating = show.ratingLabel;
    const meta = TextStyle(fontSize: 12, color: AppColors.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            PosterImage(url: show.posterUrl, width: 56, height: 80, borderRadius: 8),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  if (years.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(years, style: meta),
                  ],
                  if (genres.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(genres, style: meta, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  if (rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
