import '../../core/errors/failures.dart';
import '../../core/services/google_books_service.dart';
import '../entities/book_entity.dart';
import 'book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final GoogleBooksService _remoteService;

  BookRepositoryImpl(this._remoteService);

  @override
  Future<List<BookEntity>> searchBooks(String query) async {
    try {
      final models = await _remoteService.searchBooks(query);
      return models;
    } catch (e) {
      throw ServerFailure('No se pudieron buscar libros: $e');
    }
  }

  @override
  Future<BookEntity?> getBookByIsbn(String isbn) async {
    try {
      final model = await _remoteService.searchByIsbn(isbn);
      return model;
    } catch (e) {
      throw ServerFailure('No se pudo escanear el ISBN: $e');
    }
  }
}
