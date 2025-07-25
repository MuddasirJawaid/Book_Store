// widgets/categories_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'book_card.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BookProvider>(context).books;
    final categories = books.map((b) => b.category ?? "Unknown").toSet().toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (ctx, i) {
        final category = categories[i];
        final filteredBooks = books.where((b) => b.category == category).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SizedBox(
              height: 420,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredBooks.length,
                itemBuilder: (ctx, j) => SizedBox(
                  width: 140,
                  child: BookCard(book: filteredBooks[j]),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
