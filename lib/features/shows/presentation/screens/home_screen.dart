import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/skeleton.dart';
import 'package:tv_show_tracker/core/widgets/state_message.dart';
import 'package:tv_show_tracker/features/shows/bloc/shows_bloc.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/presentation/screens/show_details_screen.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/show_card.dart';

const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 160,
  mainAxisSpacing: 16,
  crossAxisSpacing: 12,
  childAspectRatio: 0.5,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Start fetching the next page this far before the end of the list.
  static const _prefetchExtent = 800.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _prefetchExtent) return;

    final bloc = context.read<ShowsBloc>();
    final state = bloc.state;
    // A failed page waits for the Try again button instead of auto-retrying.
    if (state is! ShowsSuccess ||
        state.hasReachedMax ||
        state.isLoadingMore ||
        state.loadMoreError != null) {
      return;
    }
    bloc.add(const ShowsNextPageRequested());
  }

  Future<void> _refresh() {
    final completer = Completer<void>();
    context.read<ShowsBloc>().add(ShowsRefreshed(completer: completer));
    return completer.future;
  }

  void _openShow(Show show) => Navigator.of(context).push(ShowDetailsScreen.route(show));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowsBloc, ShowsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceHigh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader(onSearchTap: widget.onSearchTap)),
              ...switch (state) {
                ShowsInitial() || ShowsLoading() => _loadingSlivers(),
                ShowsError(:final message) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: StateMessage(
                        icon: Icons.wifi_off_rounded,
                        title: 'Shows could not load',
                        message: message,
                        actionLabel: 'Retry',
                        onAction: () =>
                            context.read<ShowsBloc>().add(const ShowsFetched()),
                      ),
                    ),
                  ],
                ShowsEmpty() => [
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: StateMessage(
                        icon: Icons.tv_off_rounded,
                        title: 'No shows available',
                        message: 'Pull down to refresh.',
                      ),
                    ),
                  ],
                final ShowsSuccess success => _successSlivers(success),
              },
            ],
          ),
        );
      },
    );
  }

  List<Widget> _loadingSlivers() => [
        const SliverToBoxAdapter(child: _SectionTitle('Trending Now')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 250,
            child: SkeletonShimmer(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    const SkeletonBox(width: 130, height: 250),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: _SectionTitle('Popular Shows')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: _gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) => const SkeletonShimmer(child: SkeletonBox()),
              childCount: 9,
            ),
          ),
        ),
      ];

  List<Widget> _successSlivers(ShowsSuccess state) => [
        if (state.trending.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _SectionTitle('Trending Now')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.trending.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final show = state.trending[index];
                  return SizedBox(
                    width: 130,
                    child: ShowCard(show: show, onTap: () => _openShow(show)),
                  );
                },
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: _SectionTitle('Popular Shows')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: _gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final show = state.shows[index];
                return ShowCard(show: show, onTap: () => _openShow(show));
              },
              childCount: state.shows.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _PaginationFooter(
            state: state,
            onRetry: () => context.read<ShowsBloc>().add(const ShowsNextPageRequested()),
          ),
        ),
      ];
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello,', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            const Text(
              'TV Explorer! 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Material(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 10),
                      Text('Search shows...', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.state, required this.onRetry});

  final ShowsSuccess state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = state.loadMoreError;
    const secondary = TextStyle(color: AppColors.textSecondary);

    final Widget child;
    if (state.isLoadingMore) {
      child = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    } else if (error != null) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error, style: secondary, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      );
    } else if (state.hasReachedMax) {
      child = const Text("You've reached the end of the list", style: secondary);
    } else {
      child = const SizedBox(height: 24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Center(child: child),
    );
  }
}
