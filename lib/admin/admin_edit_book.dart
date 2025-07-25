// admin/admin_edit_book.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String author;
  late String description;
  late String imageUrl;
  late double price;
  late String category;
  late int quantity;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    title = widget.book.title;
    author = widget.book.author;
    description = widget.book.description;
    imageUrl = widget.book.imageUrl;
    price = widget.book.price;
    category = widget.book.category;
    quantity = widget.book.quantity;
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('books').doc(widget.book.id).update({
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'category': category,
        'quantity': quantity,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated successfully!')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating book: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onSaved: onSaved,
        validator: validator ??
            (value) =>
                (value == null || value.trim().isEmpty) ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 42, 56),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 248, 231)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 152, 0), size: 28),
            SizedBox(width: 8),
            Text(
              'EDIT BOOK',
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
              _buildTextFormField(
                label: 'Title',
                initialValue: title,
                onSaved: (value) => title = value ?? '',
              ),
              _buildTextFormField(
                label: 'Author',
                initialValue: author,
                onSaved: (value) => author = value ?? '',
              ),
              _buildTextFormField(
                label: 'Category',
                initialValue: category,
                onSaved: (value) => category = value ?? '',
              ),
              _buildTextFormField(
                label: 'Description',
                initialValue: description,
                onSaved: (value) => description = value ?? '',
                maxLines: 3,
              ),
              _buildTextFormField(
                label: 'Image URL',
                initialValue: imageUrl,
                onSaved: (value) => imageUrl = value ?? '',
              ),
              _buildTextFormField(
                label: 'Price',
                initialValue: price.toString(),
                onSaved: (value) => price = double.tryParse(value ?? '0') ?? 0,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter price';
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) return 'Enter a valid price';
                  return null;
                },
              ),
              _buildTextFormField(
                label: 'Quantity',
                initialValue: quantity.toString(),
                onSaved: (value) => quantity = int.tryParse(value ?? '0') ?? 0,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter quantity';
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 0) return 'Enter a valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
