import 'package:flutter/material.dart';
import 'package:prj/widgets/book_details.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/book_provider.dart';
import 'book_card.dart';

class BooksTab extends StatefulWidget {
  const BooksTab({super.key});

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  String _searchQuery = '';
  String _selectedSortOrder = 'none';

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    List filteredBooks = _searchQuery.isEmpty
        ? bookProvider.books.toList()
        : bookProvider.books.where((book) {
      final title = book.title?.toLowerCase() ?? '';
      final author = book.author?.toLowerCase() ?? '';
      final category = book.category?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          author.contains(query) ||
          category.contains(query);
    }).toList();

    if (_selectedSortOrder == 'low_to_high') {
      filteredBooks.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (_selectedSortOrder == 'high_to_low') {
      filteredBooks.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    }

    return bookProvider.books.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search + Sort
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      onChanged: (val) =>
                          setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search title, author, category...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor:
                        const Color.fromARGB(255, 255, 255, 255),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 125,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSortOrder,
                      dropdownColor: const Color(0xFFFF9800),
                      iconEnabledColor: const Color(0xFF1E2A38),
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('Sort by',
                              style: TextStyle(
                                  color: Color(0xFF1E2A38))),
                        ),
                        DropdownMenuItem(
                          value: 'low_to_high',
                          child: Text('Low to High',
                              style: TextStyle(
                                  color: Color(0xFF1E2A38))),
                        ),
                        DropdownMenuItem(
                          value: 'high_to_low',
                          child: Text('High to Low',
                              style: TextStyle(
                                  color: Color(0xFF1E2A38))),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSortOrder = value);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFF9800),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear,
                        size: 18, color: Colors.redAccent),
                    tooltip: 'Clear Filters',
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedSortOrder = 'none';
                      });
                    },
                  ),
                ],
              ),
            ),

            // 📚 Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'New Arrivals',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A38),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🧾 No Books Found
            if (filteredBooks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    'No books found!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else ...[
              // 🎠 Carousel
              CarouselSlider.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index, realIndex) {
                  final book = filteredBooks[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetailScreen(book: book),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 30, 42, 56),
                      margin:
                      const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              book.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              book.title ?? "Unknown Title",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(
                                    255, 255, 248, 231),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 400,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 4.0,
                  viewportFraction: 0.5,
                ),
              ),
              const SizedBox(height: 30),

              // 🔲 Grid View
              Padding(
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
                  itemBuilder: (ctx, i) {
                    final book = filteredBooks[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookDetailScreen(book: book),
                          ),
                        );
                      },
                      child: BookCard(book: book),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
