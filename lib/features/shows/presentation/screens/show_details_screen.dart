import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/state_message.dart';
import 'package:tv_show_tracker/features/shows/bloc/show_details_cubit.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/data/models/show_details.dart';
import 'package:tv_show_tracker/features/shows/data/repositories/shows_repository.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/cast_tile.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/details_header.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/episode_widgets.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/overview_tab.dart';

/// Shows the header immediately from the [Show] passed in, then fills in
/// cast and episodes once the embed request completes.
class ShowDetailsScreen extends StatefulWidget {
  const ShowDetailsScreen({super.key, required this.show});

  final Show show;

  static Route<void> route(Show show) {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (context) => ShowDetailsCubit(
          repository: context.read<ShowsRepository>(),
          showId: show.id,
        )..load(),
        child: ShowDetailsScreen(show: show),
      ),
    );
  }

  @override
  State<ShowDetailsScreen> createState() => _ShowDetailsScreenState();
}

class _ShowDetailsScreenState extends State<ShowDetailsScreen>
    with SingleTickerProviderStateMixin {
  static const _overviewTab = 0;
  static const _episodesTab = 1;

  late final TabController _tabController;
  int _tabIndex = _overviewTab;
  int? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabIndex != _tabController.index) {
      setState(() => _tabIndex = _tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ShowDetailsCubit, ShowDetailsState>(
        builder: (context, state) {
          final details = state is ShowDetailsSuccess ? state.details : null;
          final show = details?.show ?? widget.show;

          return CustomScrollView(
            slivers: [
              DetailsAppBar(show: show),
              SliverToBoxAdapter(
                child: DetailsHeader(show: show, seasonCount: details?.seasonCount),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(_buildTabBar()),
              ),
              ..._buildTabContent(state, show),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.border,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Episodes'),
        Tab(text: 'Cast'),
      ],
    );
  }

  List<Widget> _buildTabContent(ShowDetailsState state, Show show) {
    if (_tabIndex == _overviewTab) {
      return [SliverToBoxAdapter(child: OverviewTab(show: show))];
    }

    return switch (state) {
      ShowDetailsInitial() || ShowDetailsLoading() => const [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ShowDetailsError(:final message) => [
          SliverToBoxAdapter(
            child: StateMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Details could not load',
              message: message,
              actionLabel: 'Retry',
              onAction: () => context.read<ShowDetailsCubit>().load(),
            ),
          ),
        ],
      ShowDetailsSuccess(:final details) =>
        _tabIndex == _episodesTab ? _episodeSlivers(details) : _castSlivers(details),
    };
  }

  List<Widget> _episodeSlivers(ShowDetails details) {
    if (details.seasons.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: StateMessage(
            icon: Icons.video_library_outlined,
            title: 'No episodes listed',
            message: 'TVMaze has no episode information for this show yet.',
          ),
        ),
      ];
    }

    final seasonNumbers = details.seasons.keys.toList();
    final current = _selectedSeason;
    final selected =
        current != null && seasonNumbers.contains(current) ? current : seasonNumbers.first;
    final episodes = details.seasons[selected]!;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SeasonSelector(
            seasons: details.seasons,
            selected: selected,
            onChanged: (season) => setState(() => _selectedSeason = season),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: episodes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => EpisodeTile(episode: episodes[index]),
        ),
      ),
    ];
  }

  List<Widget> _castSlivers(ShowDetails details) {
    if (details.cast.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: StateMessage(
            icon: Icons.people_outline_rounded,
            title: 'No cast listed',
            message: 'TVMaze has no cast information for this show yet.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        sliver: SliverList.separated(
          itemCount: details.cast.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) => CastTile(member: details.cast[index]),
        ),
      ),
    ];
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => true;
}
