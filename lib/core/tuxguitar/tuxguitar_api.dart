import 'dart:typed_data';
import 'dart:io';

import 'package:dio/dio.dart';

class TuxGuitarApi {
  final Dio _dio;

  TuxGuitarApi({
    required String baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  Future<Map<String, dynamic>> parseTab(File file) async {
    final bytes = await file.readAsBytes();

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: file.uri.pathSegments.last,
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/tabs/parse',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data == null) {
      throw Exception('Resposta vazia do backend');
    }

    return response.data!;
  }

  Future<Uint8List> renderAudio(File file) async {
    final bytes = await file.readAsBytes();

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: file.uri.pathSegments.last,
      ),
    });

    final response = await _dio.post<List<int>>(
      '/api/tabs/render-audio',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.bytes,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Resposta de áudio vazia');
    }

    return Uint8List.fromList(data);
  }
}
