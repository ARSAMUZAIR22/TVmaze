import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/features/search/presentation/screens/search_screen.dart';
import 'package:tv_show_tracker/features/shows/presentation/screens/home_screen.dart';
import 'package:tv_show_tracker/features/watchlist/bloc/watchlist_cubit.dart';
import 'package:tv_show_tracker/features/watchlist/presentation/screens/watchlist_screen.dart';

/// Root scaffold with bottom navigation. Tabs live in an [IndexedStack]
/// so scroll position and search results survive tab switches.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _searchTab = 1;

  int _index = 0;
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _selectTab(int index, {bool focusSearch = false}) {
    if (index != _searchTab) _searchFocusNode.unfocus();
    setState(() => _index = index);
    if (focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onSearchTap: () => _selectTab(_searchTab, focusSearch: true)),
            SearchScreen(focusNode: _searchFocusNode),
            WatchlistScreen(onExplore: () => _selectTab(0)),
          ],
        ),
        bottomNavigationBar: BlocBuilder<WatchlistCubit, WatchlistState>(
          builder: (context, state) {
            final count = state is WatchlistSuccess ? state.shows.length : 0;
            return NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _selectTab,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.favorite_border_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.favorite_rounded),
                  ),
                  label: 'Watchlist',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
