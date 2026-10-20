import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/state_message.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/presentation/screens/show_details_screen.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/show_list_tile.dart';
import 'package:tv_show_tracker/features/watchlist/bloc/watchlist_cubit.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key, required this.onExplore});

  /// Switches to the Home tab.
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, state) {
          return Column(
            children: [
              _Header(showClear: state is WatchlistSuccess),
              Expanded(
                child: switch (state) {
                  WatchlistInitial() || WatchlistLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  WatchlistError(:final message) => StateMessage(
                      icon: Icons.error_outline_rounded,
                      title: 'Watchlist unavailable',
                      message: message,
                      actionLabel: 'Retry',
                      onAction: () => context.read<WatchlistCubit>().load(),
                    ),
                  WatchlistEmpty() => _EmptyWatchlist(onExplore: onExplore),
                  WatchlistSuccess(:final shows) => _WatchlistList(shows: shows),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.showClear});

  final bool showClear;

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<WatchlistCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear watchlist?'),
        content: const Text('This removes every show from your watchlist.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.heart),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'My Watchlist',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ),
            if (showClear)
              IconButton(
                tooltip: 'Clear watchlist',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmClear(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistList extends StatelessWidget {
  const _WatchlistList({required this.shows});

  final List<Show> shows;

  void _remove(BuildContext context, Show show, int index) {
    final cubit = context.read<WatchlistCubit>();
    final messenger = ScaffoldMessenger.of(context);
    cubit.remove(show.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed "${show.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cubit.add(show, index: index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: shows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final show = shows[index];
        return Dismissible(
          key: ValueKey(show.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _remove(context, show, index),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.heartSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.heart),
          ),
          child: ShowListTile(
            show: show,
            onTap: () => Navigator.of(context).push(ShowDetailsScreen.route(show)),
            trailing: IconButton(
              tooltip: 'Remove from watchlist',
              icon: const Icon(Icons.favorite_rounded, color: AppColors.heart),
              onPressed: () => _remove(context, show, index),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 22,
                    child: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 26),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your watchlist is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save shows from Home or Search and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onExplore,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 36),
              ),
              child: const Text('Explore Shows'),
            ),
          ],
        ),
      ),
    );
  }
}
