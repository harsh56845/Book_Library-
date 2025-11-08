import 'package:flutter/material.dart';
import 'package:book_villa/models/book_model.dart';
import 'package:book_villa/controllers/book_controller.dart';

class EditBookPage extends StatefulWidget {
  final BookModel existingBook;

  const EditBookPage({super.key, required this.existingBook});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final BookController _bookController = BookController();

  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController genreController;
  late TextEditingController copiesController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existingBook.title);
    authorController = TextEditingController(text: widget.existingBook.author);
    genreController = TextEditingController(text: widget.existingBook.genre);
    copiesController = TextEditingController(
      text: widget.existingBook.totalCopies.toString(),
    );
  }

  // Update Book feilds in Firebase
  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final updatedBook = BookModel(
      id: widget.existingBook.id,
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      genre: genreController.text.trim(),
      totalCopies: int.tryParse(copiesController.text.trim()) ?? 0,
    );

    final result = await _bookController.updateBook(updatedBook);

    setState(() => isLoading = false);

    if (result != null) {
      // Return the updated BookModel to dashboard
      Navigator.pop(context, result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("❌ Failed to update book. Try again!"),
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
          "✏️ Edit Book",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(titleController, "Book Title", Icons.book),
              const SizedBox(height: 20),
              _buildTextField(authorController, "Author Name", Icons.person),
              const SizedBox(height: 20),
              _buildTextField(genreController, "Genre", Icons.category),
              const SizedBox(height: 20),
              _buildTextField(
                copiesController,
                "Total Copies",
                Icons.library_books,
                TextInputType.number,
              ),
              const SizedBox(height: 30),

              // Update Button
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
                onPressed: isLoading ? null : _updateBook,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  isLoading ? "Updating..." : "Update Book",
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

  // decoration to text feild
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
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
