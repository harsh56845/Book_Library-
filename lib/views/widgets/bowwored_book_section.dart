import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowedSection extends StatefulWidget {
  const BorrowedSection({super.key});

  @override
  State<BorrowedSection> createState() => _BorrowedSectionState();
}

class _BorrowedSectionState extends State<BorrowedSection> {
  bool isLoading = true;
  List<Map<String, dynamic>> borrowedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBorrowedBooks();
  }

  // Fetch all borrowed books from all users
  Future<void> _loadBorrowedBooks() async {
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> allBorrowed = [];

    try {
      final usersSnapshot = await firestore.collection('users').get();
      print("📁 Total users found: ${usersSnapshot.docs.length}");

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();

        // Borrowed books subcollection
        final borrowedSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('borrowedBooks')
            .get();

        print(
          "👤 ${userData['fullName']} borrowed ${borrowedSnapshot.docs.length} books",
        );

        for (var borrowedDoc in borrowedSnapshot.docs) {
          final borrowedData = borrowedDoc.data();
          final bookId = borrowedData['bookId'];

          // Fetch book details
          final bookDoc = await firestore.collection('books').doc(bookId).get();

          if (bookDoc.exists) {
            final bookData = bookDoc.data()!;
            allBorrowed.add({
              'bookId': bookId,
              'title': bookData['Title'] ?? 'Unknown',
              'author': bookData['Author'] ?? 'N/A',
              'genre': bookData['Genre'] ?? 'N/A',
              'borrower': userData['Full Name'] ?? 'Unknown User',
              'email': userData['Email'] ?? '-',
            });
          }
        }
      }

      setState(() {
        borrowedBooks = allBorrowed;
        isLoading = false;
      });

      print("✅ Total borrowed entries loaded: ${borrowedBooks.length}");
    } catch (e) {
      print("❌ Error loading borrowed books: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (borrowedBooks.isEmpty) {
      return const Center(
        child: Text(
          "No borrowed books found 📚",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "All Borrowed Books 📖",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...borrowedBooks.map((book) {
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.bookmark, color: Color(0xFF6C63FF)),
                title: Text(
                  book["title"] ?? "Unknown Title",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  "Author: ${book["author"]}\n"
                  "Genre: ${book["genre"]}\n"
                  "Borrowed by: ${book["borrower"]}\n"
                  "Email: ${book["email"]}",
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
