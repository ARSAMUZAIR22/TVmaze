import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/utils/formatters.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      if (show.status != null) (Icons.radio_button_checked_rounded, 'Status', show.status!),
      if (show.network != null) (Icons.live_tv_rounded, 'Network', show.network!),
      if (show.genres.isNotEmpty) (Icons.category_outlined, 'Genres', show.genres.join(', ')),
      if (show.language != null) (Icons.language_rounded, 'Language', show.language!),
      if (show.premiered != null)
        (Icons.event_rounded, 'Premiered', Formatters.formatDate(show.premiered)),
      if (show.runtime != null) (Icons.schedule_rounded, 'Runtime', '${show.runtime} min'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text(
              'No additional information is available for this show.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.border),
                    _InfoRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
