import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new book to Firestore
  Future<bool> addBook(BookModel book) async {
    try {
      await _firestore.collection('books').add(book.toMap());
      print("✅ Book added: ${book.title}");
      return true;
    } catch (e) {
      print("❌ Error adding book: $e");
      return false;
    }
  }

  // Fetch all books
  Future<List<BookModel>> fetchBooks() async {
    try {
      final snapshot = await _firestore.collection('books').get();
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("❌ Error fetching books: $e");
      return [];
    }
  }

  Future<BookModel?> updateBook(BookModel book) async {
    try {
      await _firestore.collection('books').doc(book.id).update(book.toMap());
      print("✏️ Book updated: ${book.title}");
      return book; // ✅ return updated book
    } catch (e) {
      print("❌ Error updating book: $e");
      return null;
    }
  }

  // Delete a book by ID
  Future<bool> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
      print("🗑️ Book deleted: $bookId");
      return true;
    } catch (e) {
      print("❌ Error deleting book: $e");
      return false;
    }
  }

  Future<void> saveBorrowedBook(String userId, String bookId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('borrowedBooks')
          .add({'bookId': bookId, 'borrowedAt': FieldValue.serverTimestamp()});
      print("✅ Borrowed book saved for user: $userId -> $bookId");
    } catch (e) {
      print("❌ Error saving borrowed book: $e");
    }
  }

  Future<void> deleteBorrowedBook(String userId, String bookId) async {
    final borrowedRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('borrowedBooks');

    final query = await borrowedRef.where('bookId', isEqualTo: bookId).get();
    for (var doc in query.docs) {
      await borrowedRef.doc(doc.id).delete();
    }
  }

  Future<void> updateBookCopies(String bookId, int newCopies) async {
    await _firestore.collection('books').doc(bookId).update({
      'Total Copies': newCopies,
    });
  }
}
