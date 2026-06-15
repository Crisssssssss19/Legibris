import '../../core/usecase/usecase.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class SearchBooksUseCase implements UseCase<List<BookEntity>, String> {
  final BookRepository _repository;

  SearchBooksUseCase(this._repository);

  @override
  Future<List<BookEntity>> call(String query) async {
    return await _repository.searchBooks(query);
  }
}
