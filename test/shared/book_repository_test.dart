import 'package:flutter_test/flutter_test.dart';
import 'package:legibris/core/errors/failures.dart';
import 'package:legibris/core/services/google_books_service.dart';
import 'package:legibris/shared/entities/book_entity.dart';
import 'package:legibris/shared/models/book_model.dart';
import 'package:legibris/shared/repositories/book_repository_impl.dart';

// Simple mock for GoogleBooksService
class MockGoogleBooksService extends GoogleBooksService {
  MockGoogleBooksService() : super(anyDioInstance());

  static anyDioInstance() => null; // Placeholder

  @override
  Future<List<BookModel>> searchBooks(String query, {int maxResults = 10}) async {
    if (query == 'error') {
      throw Exception('Api error');
    }
    return [
      const BookModel(
        id: '1',
        title: 'Mock Book',
        author: 'Mock Author',
        coverUrl: 'https://mock.url',
        pageCount: 120,
      )
    ];
  }
}

void main() {
  late BookRepositoryImpl repository;
  late MockGoogleBooksService mockService;

  setUp(() {
    mockService = MockGoogleBooksService();
    repository = BookRepositoryImpl(mockService);
  });

  group('BookRepositoryImpl unit tests', () {
    test('should return a list of BookEntity when search is successful', () async {
      // Act
      final result = await repository.searchBooks('flutter');

      // Assert
      expect(result, isA<List<BookEntity>>());
      expect(result.length, 1);
      expect(result.first.title, 'Mock Book');
    });

    test('should throw a ServerFailure when remote service throws an exception', () async {
      // Assert/Act
      expect(
        () => repository.searchBooks('error'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
