// ignore_for_file: use_build_context_synchronously

import 'package:book_villa/views/add_book_page.dart';
import 'package:book_villa/views/edit_book_page.dart';
import 'package:book_villa/views/widgets/admin_profile_section.dart';
import 'package:book_villa/views/widgets/book_section.dart';
import 'package:book_villa/views/widgets/bowwored_book_section.dart';
import 'package:flutter/material.dart';
import 'package:book_villa/controllers/book_controller.dart';
import 'package:book_villa/models/book_model.dart';

class AdminDashboardPage extends StatefulWidget {
  final String adminId;
  const AdminDashboardPage({super.key, required this.adminId});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final BookController _bookController = BookController();
  int _selectedIndex = 0;
  bool isLoading = true;
  List<BookModel> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // Fetch all books from Firestore once at startup
  Future<void> _loadBooks() async {
    setState(() => isLoading = true);
    final fetchedBooks = await _bookController.fetchBooks();
    setState(() {
      books = fetchedBooks;
      isLoading = false;
    });
  }

  // Handle tab change
  void _onTabChange(int index) => setState(() => _selectedIndex = index);

  ///  Add new book
  Future<void> _addBook() async {
    final newBook = await Navigator.push<BookModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddBookPage()),
    );

    if (newBook != null) {
      setState(() {
        books.add(newBook);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("✅ '${newBook.title}' added successfully!"),
        ),
      );
    }
  }

  // Edit book instantly
  Future<void> _editBook(BookModel book) async {
    final updatedBook = await Navigator.push<BookModel>(
      context,
      MaterialPageRoute(builder: (context) => EditBookPage(existingBook: book)),
    );

    if (updatedBook != null) {
      // Update book locally without reloading
      setState(() {
        final index = books.indexWhere((b) => b.id == updatedBook.id);
        if (index != -1) books[index] = updatedBook;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("✏️ '${updatedBook.title}' updated successfully!"),
        ),
      );
    }
  }

  Future<void> _deleteBook(BookModel book) async {
    // show confirmation dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Book"),
        content: Text("Are you sure you want to delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final success = await _bookController.deleteBook(book.id);

              if (!mounted) return;

              if (success) {
                setState(() {
                  books.removeWhere((b) => b.id == book.id);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("🗑️ '${book.title}' deleted successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ Failed to delete book. Try again."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: const Text(
          "📚 Admin Dashboard",
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
                BooksSection(
                  books: books,
                  onAdd: _addBook,
                  onEdit: _editBook,
                  onDelete: _deleteBook,
                ),
                const BorrowedSection(),
                AdminProfileSection(adminId: widget.adminId),
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
            icon: Icon(Icons.library_books_outlined),
            label: "Books",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: "Borrowed",
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
