import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/poster_image.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/watchlist/bloc/watchlist_cubit.dart';

/// Collapsing poster header with back and favorite buttons.
class DetailsAppBar extends StatelessWidget {
  const DetailsAppBar({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 380,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Center(
        child: _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        BlocBuilder<WatchlistCubit, WatchlistState>(
          builder: (context, _) {
            final cubit = context.read<WatchlistCubit>();
            final saved = cubit.contains(show.id);
            return _CircleIconButton(
              icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved ? AppColors.heart : AppColors.textPrimary,
              tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
              onPressed: () => cubit.toggle(show),
            );
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(
              url: show.largePosterUrl,
              borderRadius: 0,
              alignment: Alignment.topCenter,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.35, 0.8, 1],
                  colors: [
                    AppColors.scrimLight,
                    Colors.transparent,
                    AppColors.scrim,
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.scrimLight,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

/// Title, meta, genres, summary and the watchlist button.
class DetailsHeader extends StatelessWidget {
  const DetailsHeader({super.key, required this.show, this.seasonCount});

  final Show show;

  /// Null until episodes have loaded.
  final int? seasonCount;

  @override
  Widget build(BuildContext context) {
    final seasons = seasonCount;
    final rating = show.ratingLabel;
    final summary = show.plainSummary;
    const metaStyle = TextStyle(fontSize: 14, color: AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            show.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (show.yearsLabel.isNotEmpty) Text(show.yearsLabel, style: metaStyle),
              if (seasons != null && seasons > 0)
                Text('$seasons ${seasons == 1 ? 'Season' : 'Seasons'}', style: metaStyle),
              if (rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text(
                      '$rating/10',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
          if (show.genres.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final genre in show.genres) _GenreChip(label: genre)],
            ),
          ],
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ExpandableText(text: summary),
          ],
          const SizedBox(height: 20),
          _WatchlistButton(show: show),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  static const _collapsedLines = 4;
  static const _style = TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary);

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: _style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: _style,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (overflows)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WatchlistButton extends StatelessWidget {
  const _WatchlistButton({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, _) {
        final cubit = context.read<WatchlistCubit>();
        final saved = cubit.contains(show.id);

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: saved
              ? OutlinedButton.icon(
                  onPressed: () => cubit.toggle(show),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Remove from Watchlist'),
                )
              : FilledButton.icon(
                  onPressed: () => cubit.toggle(show),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add to Watchlist'),
                ),
        );
      },
    );
  }
}
