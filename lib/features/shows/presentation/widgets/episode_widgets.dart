import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/utils/formatters.dart';
import 'package:tv_show_tracker/core/widgets/poster_image.dart';
import 'package:tv_show_tracker/features/shows/data/models/episode.dart';

class SeasonSelector extends StatelessWidget {
  const SeasonSelector({
    super.key,
    required this.seasons,
    required this.selected,
    required this.onChanged,
  });

  final Map<int, List<Episode>> seasons;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selected,
          isExpanded: true,
          dropdownColor: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            for (final entry in seasons.entries)
              DropdownMenuItem(
                value: entry.key,
                child: Text(
                  _label(entry.key, entry.value.length),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  String _label(int season, int count) {
    final name = season == 0 ? 'Specials' : 'Season $season';
    return '$name ($count ${count == 1 ? 'episode' : 'episodes'})';
  }
}

class EpisodeTile extends StatelessWidget {
  const EpisodeTile({super.key, required this.episode});

  final Episode episode;

  String get _meta {
    final date = Formatters.formatDate(episode.airdate);
    final runtime = episode.runtime;
    return runtime == null ? date : '$date  ·  $runtime min';
  }

  @override
  Widget build(BuildContext context) {
    final number = episode.number;

    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(
                    url: episode.imageMedium,
                    borderRadius: 8,
                    placeholderIcon: Icons.movie_outlined,
                  ),
                  if (number != null)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.scrim,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$number',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _meta,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final number = episode.number;
    final code = number == null
        ? 'Season ${episode.season} special'
        : 'Season ${episode.season}, Episode $number';
    final summary = episode.plainSummary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  episode.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(_meta, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Text(
                  summary.isEmpty ? 'No summary available for this episode.' : summary,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
