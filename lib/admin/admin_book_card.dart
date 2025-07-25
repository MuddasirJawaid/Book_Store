import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/rating_provider.dart';

class AdminBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onEdit;

  const AdminBookCard({
    super.key,
    required this.book,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final avgRating = Provider.of<RatingProvider>(context).getRatingForBook(book.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A38), // Ensure correct background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 0.7,
              child: book.imageUrl.isNotEmpty
                  ? Image.network(book.imageUrl, fit: BoxFit.cover)
                  : Container(
                color: Colors.grey[800],
                child: const Icon(Icons.book, color: Colors.white),
              ),
            ),
          ),
          // Book Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: \$${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.orange, // Fix green color
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${book.quantity}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: avgRating,
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 18,
                  unratedColor: Colors.grey,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("EDIT"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
