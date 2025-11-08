class BookModel {
  final String id;
  final String title;
  final String author;
  final String genre;
  final int totalCopies;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.totalCopies,
  });

  // Convert Book object to Map
  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Author': author,
      'Genre': genre,
      'Total Copies': totalCopies,
    };
  }

  // Convert Firestore document to Book object
  factory BookModel.fromMap(String id, Map<String, dynamic> data) {
    return BookModel(
      id: id,
      title: data['Title'] ?? '',
      author: data['Author'] ?? '',
      genre: data['Genre'] ?? '',
      totalCopies: data['Total Copies'] ?? 0,
    );
  }
}
