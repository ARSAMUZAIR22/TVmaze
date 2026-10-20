import 'package:tv_show_tracker/features/shows/data/models/show.dart';

class ShowsPage {
  const ShowsPage({required this.shows, required this.hasMore});

  final List<Show> shows;
  final bool hasMore;
}
