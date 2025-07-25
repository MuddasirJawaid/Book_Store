// widgets/book_details.dart
import 'package:prj/models/book.dart';
import 'package:prj/providers/cart_provider.dart';
import 'package:prj/providers/rating_provider.dart';
import 'package:prj/providers/reviewprovide.dart';
import 'package:prj/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  double _avgRating = 0;
  double _userRating = 0;
  bool _canRate = false;
  bool _isAddingToCart = false; // ✅ loader flag

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    final avgRate = await ratingProvider.getAverageRating(widget.book.id);
    final userRate = await ratingProvider.getUserRating(widget.book.id) ?? 0;
    final eligible = await ratingProvider.hasUserOrderedAndDelivered(widget.book.id);

    await reviewProvider.fetchReviews(widget.book.id);

    setState(() {
      _avgRating = avgRate;
      _userRating = userRate;
      _canRate = eligible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: const Color(0xFF1E2A38),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.book.imageUrl,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.book.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Author: ${widget.book.author}',
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Description: ${widget.book.description}',
                style: TextStyle(fontSize: 16, color: Colors.grey[300])),
            const SizedBox(height: 8),
            Text('\$${widget.book.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 4),
            Text(
              widget.book.quantity > 0
                  ? 'In Stock: ${widget.book.quantity}'
                  : 'Currently Out of Stock',
              style: TextStyle(
                fontSize: 14,
                color: widget.book.quantity > 0 ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),

            Consumer<RatingProvider>(
              builder: (context, ratingProvider, _) {
                return StreamBuilder<double>(
                  stream: ratingProvider.averageRatingStream(widget.book.id),
                  builder: (context, snapshot) {
                    final rating = snapshot.data ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Average Rating: ${rating.toStringAsFixed(1)}',
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 30.0,
                          unratedColor: Colors.grey,
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    wishlistProvider.isWishlisted(widget.book.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: wishlistProvider.isWishlisted(widget.book.id)
                        ? Colors.orange
                        : Colors.white,
                  ),
                  onPressed: () {
                    wishlistProvider.toggleWishlist(widget.book);
                  },
                ),
                widget.book.quantity == 0
                    ? const Text(
                  'Out of Stock',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _isAddingToCart
                      ? null
                      : () async {
                    setState(() => _isAddingToCart = true);
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
                      setState(() => _isAddingToCart = false);
                    }
                  },
                  child: _isAddingToCart
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Add to Cart'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_canRate)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Rating:", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 4),
                  RatingBar.builder(
                    initialRating: _userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (newRating) async {
                      final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
                      await ratingProvider.saveRating(widget.book.id, newRating);
                      await Future.delayed(const Duration(milliseconds: 500));
                      final newAvg = await ratingProvider.getAverageRating(widget.book.id);
                      setState(() {
                        _userRating = newRating;
                        _avgRating = newAvg;
                      });
                    },
                  ),
                ],
              )
            else
              const Text("You must order and receive this book to rate it.",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),

            const SizedBox(height: 24),

            Consumer<ReviewProvider>(
              builder: (context, reviewProvider, _) {
                final reviews = reviewProvider.reviews;
                final userId = reviewProvider.user?.uid ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Reviews:", style: TextStyle(color: Colors.orange, fontSize: 18)),
                    const SizedBox(height: 8),
                    if (reviews.isEmpty)
                      const Text("No reviews yet", style: TextStyle(color: Colors.white70)),
                    ...reviews.map((review) {
                      final isLiked = review.isLikedBy(userId);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(review.userName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                        color: isLiked ? Colors.orange : Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        await reviewProvider.toggleLike(widget.book.id, review);
                                      },
                                    ),
                                    Text(
                                      "${review.likes.length}",
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(review.text,
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(review.timestamp.toDate().toString().split(".")[0],
                                style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
