// models/book.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final int quantity;
  final bool isWishlisted;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.quantity,
    this.isWishlisted = false,
  });

  factory Book.fromMap(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] as String,
      author: data['author'] as String? ?? 'Unknown Author',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      price: (data['price'] as num).toDouble(),
      category: data['category'] as String? ?? 'General',
      quantity: data['quantity'] != null ? (data['quantity'] as num).toInt() : 0,
      isWishlisted: data['isWishlisted'] ?? false,
    );
  }

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'quantity': quantity,
      'isWishlisted': isWishlisted,
    };
  }

  Map<String, dynamic> toCartMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'quantity': quantity,
      'isWishlisted': isWishlisted,
    };
  }

  factory Book.fromCartMap(Map<String, dynamic> data) {
    return Book(
      id: data['id'],
      title: data['title'],
      author: data['author'],
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      price: (data['price'] as num).toDouble(),
      category: data['category'] ?? '',
      quantity: data['quantity'] != null ? (data['quantity'] as num).toInt() : 0,
      isWishlisted: data['isWishlisted'] ?? false,
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? imageUrl,
    double? price,
    String? category,
    int? quantity,
    bool? isWishlisted,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isWishlisted: isWishlisted ?? this.isWishlisted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Book && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Book(id: $id, title: $title, price: $price, quantity: $quantity)';
}
