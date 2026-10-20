import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/theme/app_colors.dart';
import 'package:tv_show_tracker/core/widgets/skeleton.dart';
import 'package:tv_show_tracker/core/widgets/state_message.dart';
import 'package:tv_show_tracker/features/search/bloc/search_bloc.dart';
import 'package:tv_show_tracker/features/shows/presentation/screens/show_details_screen.dart';
import 'package:tv_show_tracker/features/shows/presentation/widgets/show_list_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.focusNode});

  /// Owned by the shell so the Home search bar can focus this field.
  final FocusNode focusNode;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) =>
      context.read<SearchBloc>().add(SearchQueryChanged(value));

  void _clear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search shows...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.cancel_rounded, size: 20),
                          onPressed: _clear,
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) => switch (state) {
                SearchInitial() => const StateMessage(
                    icon: Icons.manage_search_rounded,
                    title: 'Find your next show',
                    message: 'Search the TVMaze catalogue by title.',
                  ),
                SearchLoading() => const _SearchSkeleton(),
                SearchEmpty(:final query) => StateMessage(
                    icon: Icons.search_off_rounded,
                    title: 'No results for "$query"',
                    message: 'Check the spelling or try a different title.',
                  ),
                SearchError(:final query, :final message) => StateMessage(
                    icon: Icons.wifi_off_rounded,
                    title: 'Search failed',
                    message: message,
                    actionLabel: 'Retry',
                    onAction: () =>
                        context.read<SearchBloc>().add(SearchQueryChanged(query)),
                  ),
                SearchSuccess(:final results) => ListView.separated(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 20, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final show = results[index];
                      return ShowListTile(
                        show: show,
                        onTap: () =>
                            Navigator.of(context).push(ShowDetailsScreen.route(show)),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) => const Row(
          children: [
            SkeletonBox(width: 56, height: 80, radius: 8),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 160, height: 14, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 90, height: 12, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 120, height: 12, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
