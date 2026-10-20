import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tv_show_tracker/core/network/api_exception.dart';

/// Thin HTTP wrapper around the TVMaze API.
///
/// Handles JSON decoding, timeouts, error mapping and retries on
/// HTTP 429 (TVMaze allows roughly 20 calls every 10 seconds per IP).
class ApiClient {
  ApiClient({http.Client? client, this.host = 'api.tvmaze.com'})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String host;

  static const _timeout = Duration(seconds: 15);
  static const _maxRetries = 2;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final uri = Uri.https(host, path, query);
    var attempt = 0;

    while (true) {
      try {
        final response = await _client.get(uri).timeout(_timeout);

        if (response.statusCode == 429 && attempt < _maxRetries) {
          attempt++;
          await Future<void>.delayed(Duration(seconds: 2 * attempt));
          continue;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(utf8.decode(response.bodyBytes));
        }

        throw ApiException(
          _messageFor(response.statusCode),
          statusCode: response.statusCode,
        );
      } on TimeoutException {
        throw const ApiException('The request timed out. Try again.');
      } on http.ClientException {
        throw const ApiException(
          'No internet connection. Check your network and try again.',
        );
      } on FormatException {
        throw const ApiException('The server returned an unreadable response.');
      }
    }
  }

  String _messageFor(int statusCode) {
    if (statusCode == 404) return 'The requested content was not found.';
    if (statusCode == 429) return 'Too many requests. Wait a moment and try again.';
    if (statusCode >= 500) return 'TVMaze is having trouble right now. Try again later.';
    return 'Request failed with status $statusCode.';
  }
}
