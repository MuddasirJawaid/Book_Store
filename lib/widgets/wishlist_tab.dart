// widgets/wishlist_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/book_provider.dart';


class WishlistTab extends StatefulWidget {
  const WishlistTab({super.key});

  @override
  State<WishlistTab> createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  bool _initialized = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    
      wishlistProvider.allBooks = bookProvider.books;

      setState(() => _loading = true);
      wishlistProvider.loadWishlist().then((_) {
        setState(() {
          _initialized = true;
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistBooks = wishlistProvider.wishlist;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wishlistBooks.isEmpty) {
      return const Center(
        child: Text(
          'Your wishlist is empty.',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: wishlistBooks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (ctx, i) {
        final book = wishlistBooks[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFF1E2A38),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    book.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (ctx, error, _) => const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${book.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(
                          wishlistProvider.isWishlisted(book.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: wishlistProvider.isWishlisted(book.id)
                              ? Colors.orange
                              : Colors.grey[300],
                        ),
                        onPressed: () {
                          wishlistProvider.toggleWishlist(book);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
