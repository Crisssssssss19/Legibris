class BookEntity {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final int? pageCount;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.pageCount,
  });
}
