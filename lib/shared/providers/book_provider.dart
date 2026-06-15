import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/google_books_service.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_repository_impl.dart';
import '../usecases/search_books_usecase.dart';

// 1. Dio client provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

// 2. Service provider
final googleBooksServiceProvider = Provider<GoogleBooksService>((ref) {
  final dio = ref.read(dioProvider);
  return GoogleBooksService(dio);
});

// 3. Repository provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final service = ref.read(googleBooksServiceProvider);
  return BookRepositoryImpl(service);
});

// 4. Use Case provider
final searchBooksUseCaseProvider = Provider<SearchBooksUseCase>((ref) {
  final repo = ref.read(bookRepositoryProvider);
  return SearchBooksUseCase(repo);
});
