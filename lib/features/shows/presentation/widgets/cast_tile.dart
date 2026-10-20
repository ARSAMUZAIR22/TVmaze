import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/poster_image.dart';
import 'package:tv_show_tracker/features/shows/data/models/cast_member.dart';

class CastTile extends StatelessWidget {
  const CastTile({super.key, required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final character = member.characterName;

    return Row(
      children: [
        PosterImage(
          url: member.imageUrl,
          width: 52,
          height: 52,
          borderRadius: 26,
          placeholderIcon: Icons.person_rounded,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.personName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              if (character != null) ...[
                const SizedBox(height: 2),
                Text(
                  character,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
