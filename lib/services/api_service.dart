import 'dart:convert';
import 'dart:io';

class ApiService {
  static Future<String> fetchData(String apiUrl, String dataPath) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(apiUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'CustomAPIWidgets/1.0');
      final response = await request.close().timeout(const Duration(seconds: 10));
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return _extractDataFromPath(data, dataPath);
      } else {
        throw Exception('HTTP \\${response.statusCode}: \\${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  static String _extractDataFromPath(dynamic data, String path) {
    if (path.isEmpty) {
      return data.toString();
    }

    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current == null) {
        throw Exception('Invalid path: $path');
      }

      if (current is Map<String, dynamic>) {
        current = current[part];
      } else if (current is List && int.tryParse(part) != null) {
        final index = int.parse(part);
        if (index >= 0 && index < current.length) {
          current = current[index];
        } else {
          throw Exception('Array index out of bounds: $part');
        }
      } else {
        throw Exception('Cannot access property $part');
      }
    }

    return current?.toString() ?? 'null';
  }

  static Future<bool> validateApiUrl(String url) async {
    try {
      final client = HttpClient();
      final request = await client.headUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}