// admin/admin_add_book.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart' as model;
import '../providers/book_provider.dart';

class AdminAddBookScreen extends StatefulWidget {
  const AdminAddBookScreen({super.key});

  @override
  State<AdminAddBookScreen> createState() => _AdminAddBookScreenState();
}

class _AdminAddBookScreenState extends State<AdminAddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 42, 56),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 248, 231)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 152, 0), size: 28),
            SizedBox(width: 8),
            Text(
              'ADD NEW BOOK',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 248, 231),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, 'Title'),
              const SizedBox(height: 10),
              _buildTextField(_authorController, 'Author'),
              const SizedBox(height: 10),
              _buildTextField(_categoryController, 'Category'),
              const SizedBox(height: 10),
              _buildTextField(_descriptionController, 'Description', maxLines: 3),
              const SizedBox(height: 10),
              _buildTextField(_imageUrlController, 'Image URL'),
              const SizedBox(height: 10),
              _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildTextField(_quantityController, 'Quantity', keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                      ),
                      onPressed: _submitForm,
                      child: const Text('Add Book'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newBook = model.Book(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        quantity: int.parse(_quantityController.text.trim()),
        isWishlisted: false,
      );

      final docRef = await FirebaseFirestore.instance.collection('books').add(newBook.toMap());
      await docRef.update({'id': docRef.id});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📚 Book added successfully!')),
      );

      _clearForm();
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error adding book. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _authorController.clear();
    _categoryController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _priceController.clear();
    _quantityController.clear();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Enter $label';
        if (label == 'Price') {
          final parsed = double.tryParse(value.trim());
          if (parsed == null || parsed < 0) return 'Enter a valid price';
        }
        if (label == 'Quantity') {
          final parsed = int.tryParse(value.trim());
          if (parsed == null || parsed < 0) return 'Enter a valid quantity';
        }
        return null;
      },
    );
  }
}
