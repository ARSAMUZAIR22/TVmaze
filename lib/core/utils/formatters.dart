abstract final class Formatters {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// TVMaze summaries are HTML. Converts them to readable plain text.
  static String stripHtml(String? html) {
    if (html == null || html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>\s*<p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  /// `2008-01-20` becomes `Jan 20, 2008`.
  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'TBA';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String? year(String? isoDate) {
    if (isoDate == null || isoDate.length < 4) return null;
    return isoDate.substring(0, 4);
  }
}
