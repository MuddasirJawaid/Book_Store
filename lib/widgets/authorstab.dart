// widgets/authorstab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';

class AuthorsScreen extends StatefulWidget {
  @override
  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  String? selectedAuthor;

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final books = bookProvider.books;

    final authors = books.map((b) => b.author).toSet().toList();

    final filteredBooks = selectedAuthor == null
        ? books
        : books.where((b) => b.author == selectedAuthor).toList();

    return Scaffold(
      appBar: AppBar(
              backgroundColor: const Color(0xFF1E2A38),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFFFF8E7)),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book, color: Color(0xFFFF9800), size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'BROWSE BY AUTHORS',
                    style: TextStyle(
                      color: Color(0xFFFFF8E7),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ],
              ),
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Select Author",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text("All"),
                      selected: selectedAuthor == null,
                      onSelected: (_) => setState(() => selectedAuthor = null),
                      selectedColor: const Color.fromARGB(255, 30, 42, 56),
                      labelStyle: TextStyle(
                        color:
                            selectedAuthor == null ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...authors.map((author) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(author),
                            selected: selectedAuthor == author,
                            onSelected: (_) =>
                                setState(() => selectedAuthor = author),
                            selectedColor: const Color.fromARGB(255, 30, 42, 56),
                            labelStyle: TextStyle(
                              color: selectedAuthor == author
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              filteredBooks.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No books available for this author."),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredBooks.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.35,
                        ),
                        itemBuilder: (ctx, i) =>
                            BookCard(book: filteredBooks[i]),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
