import 'dart:convert';
import 'package:dio/dio.dart';
import '../../shared/models/book_model.dart';
import '../constants/app_constants.dart';

class GoogleBooksService {
  final Dio _dio;

  GoogleBooksService(this._dio);

  // Search books by text query (title, author, or category)
  Future<List<BookModel>> searchBooks(String query, {int maxResults = 10}) async {
    try {
      final response = await _dio.get(
        '${AppConstants.googleBooksBaseUrl}/volumes',
        queryParameters: {
          'q': query,
          'maxResults': maxResults,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('items')) {
          final items = data['items'] as List;
          return items.map((item) {
            final volumeInfo = item['volumeInfo'] as Map<String, dynamic>;
            final id = item['id'] as String;
            final title = volumeInfo['title'] as String? ?? 'Sin Título';
            final authors = volumeInfo['authors'] as List? ?? ['Autor Desconocido'];
            final coverMap = volumeInfo['imageLinks'] as Map<String, dynamic>?;
            final coverUrl = coverMap?['thumbnail'] as String?;
            final pageCount = volumeInfo['pageCount'] as int?;

            return BookModel(
              id: id,
              title: title,
              author: authors.join(', '),
              coverUrl: coverUrl,
              pageCount: pageCount,
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error al buscar libros en Google Books API: $e');
    }
  }

  // Search book details using ISBN
  Future<BookModel?> searchByIsbn(String isbn) async {
    try {
      final books = await searchBooks('isbn:$isbn', maxResults: 1);
      return books.isNotEmpty ? books.first : null;
    } catch (e) {
      throw Exception('Error al escanear ISBN en Google Books: $e');
    }
  }
}
