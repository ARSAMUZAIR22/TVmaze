import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/poster_image.dart';
import 'package:tv_show_tracker/core/widgets/rating_badge.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';

/// Poster card used in the Home grid and the Trending carousel.
/// The poster expands to fill whatever height the parent gives it.
class ShowCard extends StatelessWidget {
  const ShowCard({super.key, required this.show, required this.onTap});

  final Show show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rating = show.ratingLabel;
    final genres = show.genresLabel();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PosterImage(url: show.posterUrl),
                if (rating != null)
                  Positioned(top: 6, right: 6, child: RatingBadge(rating: rating)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            show.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            genres.isEmpty ? 'TV show' : genres,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
