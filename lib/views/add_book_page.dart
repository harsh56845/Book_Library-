// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:book_villa/controllers/book_controller.dart';
import 'package:book_villa/models/book_model.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final BookController _bookController = BookController();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController copiesController = TextEditingController();

  bool isLoading = false;

  /// Add Book Function
  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final newBook = BookModel(
      id: '',
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      genre: genreController.text.trim(),
      totalCopies: int.tryParse(copiesController.text.trim()) ?? 0,
    );

    final success = await _bookController.addBook(newBook);

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context, newBook);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("✅ Book added successfully!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("❌ Failed to add book. Try again!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: const Text(
          "➕ Add New Book",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInputField(titleController, "Book Title", Icons.book),
              const SizedBox(height: 20),
              _buildInputField(authorController, "Author Name", Icons.person),
              const SizedBox(height: 20),
              _buildInputField(genreController, "Genre", Icons.category),
              const SizedBox(height: 20),
              _buildInputField(
                copiesController,
                "Total Copies",
                Icons.library_books,
                TextInputType.number,
              ),
              const SizedBox(height: 30),

              // Add Book Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : _addBook,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add, color: Colors.white),
                label: Text(
                  isLoading ? "Adding..." : "Add Book",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Builder
  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Please enter $label" : null,
    );
  }
}
