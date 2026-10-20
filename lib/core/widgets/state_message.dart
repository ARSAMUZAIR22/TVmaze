import 'package:flutter/material.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';

/// Shared view for empty, error and idle states.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final body = message;
    final label = actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
            if (label != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
