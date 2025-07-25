import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/cart_provider.dart';
import '../providers/rating_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/book_details.dart';

class BookCard extends StatefulWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    ratingProvider.fetchAverageRating(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: widget.book),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF1E2A38),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: widget.book.imageUrl.isNotEmpty
                    ? Image.network(widget.book.imageUrl, fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.book, color: Colors.white),
                ),
              ),
            ),
            // Book Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Author
                    Text(
                      widget.book.author,
                      style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Consumer<RatingProvider>(
                      builder: (context, ratingProvider, _) {
                        final avgRating = ratingProvider.getRatingForBook(widget.book.id);
                        return RatingBarIndicator(
                          rating: avgRating,
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 18,
                          unratedColor: Colors.grey,
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Price & Wishlist
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.book.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Consumer<WishlistProvider>(
                          builder: (context, wishlistProvider, _) {
                            final isWishlisted = wishlistProvider.isWishlisted(widget.book.id);
                            return IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              icon: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                color: isWishlisted ? Colors.orange : Colors.grey[300],
                              ),
                              onPressed: () {
                                wishlistProvider.toggleWishlist(widget.book);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Add to Cart or Out of Stock
                    widget.book.quantity > 0
                        ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                          setState(() => isLoading = true);
                          try {
                            await cartProvider.addToCart(widget.book);
                            Fluttertoast.showToast(
                              msg: "${widget.book.title} added to cart",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black87,
                              textColor: Colors.white,
                              fontSize: 14,
                            );
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: e.toString().replaceAll("Exception:", "").trim(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              textColor: Colors.white,
                              fontSize: 14,
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                        child: isLoading
                            ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 20,
                        )
                            : const Text(
                          "ADD TO CART",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                        : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          "OUT OF STOCK",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
