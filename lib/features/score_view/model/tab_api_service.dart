import 'package:http/http.dart' as http;
import 'dart:convert';
import 'song_model.dart';

class TabApiService {
  final String baseUrl;
  final http.Client _client;

  TabApiService({this.baseUrl = 'http://localhost:8080'})
      : _client = http.Client();

  Future<Song> parseFile(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/tabs/parse'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return Song.fromJson(json.decode(body) as Map<String, dynamic>);
    } else {
      throw TabApiException(
        response.statusCode,
        'Failed to parse file: ${response.statusCode}',
      );
    }
  }

  Future<Song> parseBytes(List<int> bytes, String fileName) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/tabs/parse'),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return Song.fromJson(json.decode(body) as Map<String, dynamic>);
    } else {
      throw TabApiException(
        response.statusCode,
        'Failed to parse file: ${response.statusCode}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class TabApiException implements Exception {
  final int statusCode;
  final String message;

  TabApiException(this.statusCode, this.message);

  @override
  String toString() => 'TabApiException($statusCode): $message';
}
