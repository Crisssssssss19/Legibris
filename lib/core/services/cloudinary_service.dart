import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  final Dio _dio;
  final String _cloudName;
  final String _uploadPreset;

  CloudinaryService(this._dio, {required String cloudName, required String uploadPreset})
      : _cloudName = cloudName,
        _uploadPreset = uploadPreset;

  // Upload file image to Cloudinary hosting
  Future<String?> uploadImage(File file) async {
    try {
      final String url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': _uploadPreset,
      });

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final secureUrl = response.data['secure_url'] as String?;
        return secureUrl;
      }
      return null;
    } catch (e) {
      print('Cloudinary Upload Exception: $e');
      return null;
    }
  }

  // Generate responsive thumbnail URLs dynamically
  String getOptimizedThumbnail(String originalUrl, {int width = 150, int height = 150}) {
    // Cloudinary supports dynamic crop transformations: 'c_fill,h_150,w_150'
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;
    
    final splitMarker = '/upload/';
    final parts = originalUrl.split(splitMarker);
    if (parts.length == 2) {
      return '${parts[0]}${splitMarker}c_fill,h_$height,w_$width/${parts[1]}';
    }
    return originalUrl;
  }
}
