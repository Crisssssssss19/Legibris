import '../../core/errors/failures.dart';
import '../entities/book_entity.dart';

abstract class BookRepository {
  Future<List<BookEntity>> searchBooks(String query);
  Future<BookEntity?> getBookByIsbn(String isbn);
}
