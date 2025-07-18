import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NetworkUtils {
  /// Retrieves cached response from SharedPreferences.
  /// Ensures that expired entries are cleaned up before returning the data.
  static Future<http.Response?> getCachedResponse(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = getCacheKey(url);
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      final cache = jsonDecode(cachedData);
      final expiry = cache['expiry'];

      if (expiry != null) {
        final expiryDate = DateTime.parse(expiry);
        if (DateTime.now().isBefore(expiryDate)) {
          return http.Response(jsonEncode(cache['response']), 200);
        } else {
          await prefs.remove(cacheKey);
        }
      }
    }

    return null;
  }

  /// Caches a response in SharedPreferences with optional expiry time.
  static Future<void> cacheResponse(String url, http.Response response) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = getCacheKey(url);

    final cacheData = {
      'response': jsonDecode(response.body),
      'expiry': response.headers['expires'],
    };

    await prefs.setString(cacheKey, jsonEncode(cacheData));
  }

  /// A utility function to handle HTTP responses.
  /// Ensures JSON responses are parsed and returned.
  /// Throws an error if the response is not valid JSON.
  static Future<Map<String, dynamic>> handleResponse(
    http.Response response,
  ) async {
    try {
      final responseBody = response.body;
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse is Map<String, dynamic>) {
        return jsonResponse;
      } else {
        throw Exception('Unexpected JSON structure');
      }
    } catch (e) {
      throw Exception('Response is not valid JSON');
    }
  }

  static String getCacheKey(String url) {
    return 'cache_$url';
  }

  /// Clears all cached responses
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    for (var key in allKeys) {
      if (key.startsWith('cache_')) {
        await prefs.remove(key);
      }
    }
  }
}
