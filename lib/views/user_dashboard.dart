// ignore_for_file: avoid_print, dead_code, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:book_villa/models/user_model.dart';
import 'package:book_villa/models/book_model.dart';
import 'package:book_villa/controllers/book_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboardPage extends StatefulWidget {
  final UserModel user;
  const UserDashboardPage({super.key, required this.user});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final BookController _bookController = BookController();
  int _selectedIndex = 0;
  bool isLoading = true;

  List<BookModel> allBooks = [];
  List<BookModel> borrowedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadBooks();
    await _loadBorrowedBooks();
  }

  /// Load available books (if totalCopies > 0)
  Future<void> _loadBooks() async {
    final books = await _bookController.fetchBooks();
    setState(() {
      allBooks = books.where((b) => b.totalCopies > 0).toList();
      isLoading = false;
    });
  }

  /// Load borrowed books of current user
  Future<void> _loadBorrowedBooks() async {
    final borrowedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('borrowedBooks')
        .get();

    List<String> borrowedBookIds = borrowedSnapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data.containsKey('bookId')) return data['bookId'] as String;
          print("⚠️ Borrowed record missing bookId: ${doc.id}");
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();

    if (borrowedBookIds.isEmpty) {
      setState(() => borrowedBooks = []);
      return;
    }

    final allFetchedBooks = await _bookController.fetchBooks();
    setState(() {
      borrowedBooks = allFetchedBooks
          .where((book) => borrowedBookIds.contains(book.id))
          .toList();
    });

    print("Borrowed documents for ${widget.user.email}:");
    for (var d in borrowedSnapshot.docs) {
      print(d.data());
    }
  }

  /// Borrow Book: Allow multiple different books but not the same one twice
  Future<void> _borrowBook(BookModel book) async {
    final alreadyBorrowed = borrowedBooks.any(
      (borrowedBook) => borrowedBook.id == book.id,
    );

    if (alreadyBorrowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ You have already borrowed '${book.title}'. Return it before borrowing again.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await _bookController.saveBorrowedBook(widget.user.id, book.id);
    await _bookController.updateBookCopies(book.id, book.totalCopies - 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Borrowed '${book.title}' successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    await _loadAllData();
  }

  // Return Book =  Remove from Firestore + increase totalCopies
  Future<void> _returnBook(BookModel book) async {
    await _bookController.deleteBorrowedBook(widget.user.id, book.id);
    await _bookController.updateBookCopies(book.id, book.totalCopies + 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📘 Returned '${book.title}' successfully!"),
        backgroundColor: Colors.orange,
      ),
    );

    await _loadAllData();
  }

  void _onTabChange(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: const Text(
          "📚 Book Library",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [
                HomeSection(books: allBooks, onBorrow: _borrowBook),
                MyBooksSection(
                  borrowedBooks: borrowedBooks,
                  onReturn: _returnBook,
                ),
                ProfileSection(user: widget.user),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6C63FF),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onTabChange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: "My Books",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

//
// ---------- Home Section ----------
class HomeSection extends StatelessWidget {
  final List<BookModel> books;
  final Function(BookModel) onBorrow;

  const HomeSection({super.key, this.books = const [], required this.onBorrow});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: books.isEmpty
          ? const Center(
              child: Text(
                "No available books right now 📕",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
            )
          : ListView(
              children: [
                const Text(
                  "Available Books 📖",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...books.map(
                  (book) => Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.book,
                            color: Color(0xFF6C63FF),
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text("Author: ${book.author}"),
                                Text(
                                  "Genre: ${book.genre}",
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  "Available Copies: ${book.totalCopies}",
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                            ),
                            onPressed: () => onBorrow(book),
                            child: const Text(
                              "Borrow",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------- My Books Section ----------
class MyBooksSection extends StatelessWidget {
  final List<BookModel> borrowedBooks;
  final Function(BookModel) onReturn;

  const MyBooksSection({
    super.key,
    this.borrowedBooks = const [],
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: borrowedBooks.isEmpty
          ? const Center(
              child: Text(
                "You haven’t borrowed any books yet 📚",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
            )
          : ListView(
              children: [
                const Text(
                  "My Borrowed Books 📚",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...borrowedBooks.map(
                  (book) => Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.menu_book,
                        color: Color(0xFF6C63FF),
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Author: ${book.author}\nGenre: ${book.genre}",
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () => onReturn(book),
                        child: const Text(
                          "Return",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------- Profile Section ----------
class ProfileSection extends StatelessWidget {
  final UserModel user;
  const ProfileSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF6C63FF),
              child: Icon(Icons.person, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 20),
            Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              user.email,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
