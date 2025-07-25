// widgets/best_seller.dart
import 'package:prj/models/book.dart';
import 'package:prj/widgets/book_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BestSellerScreen extends StatefulWidget {
  const BestSellerScreen({super.key});

  @override
  State<BestSellerScreen> createState() => _BestSellerScreenState();
}

class _BestSellerScreenState extends State<BestSellerScreen> {
  List<Book> bestSellerBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBestSellers();
  }

  Future<void> fetchBestSellers() async {
    try {
      final salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();

      Map<String, int> salesCount = {};

      for (var doc in salesSnapshot.docs) {
        final bookId = doc['bookId'];
        final quantity = (doc['quantity'] as num).toInt();

        salesCount[bookId] = (salesCount[bookId] ?? 0) + quantity;
      }

      final sorted = salesCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topBookIds = sorted.take(5).map((e) => e.key).toList();

      List<Book> books = [];

      for (String id in topBookIds) {
        final doc = await FirebaseFirestore.instance.collection('books').doc(id).get();
        if (doc.exists) {
          books.add(Book.fromFirestore(doc));
        }
      }

      setState(() {
        bestSellerBooks = books;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching best sellers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Best Sellers"),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: const Color(0xFF1E2A38),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bestSellerBooks.isEmpty
              ? const Center(
                  child: Text(
                    "No best sellers found.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: bestSellerBooks.length,
                  itemBuilder: (context, index) {
                    final book = bestSellerBooks[index];
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: Colors.white10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.orange.withOpacity(0.4)),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(book.imageUrl, width: 50, fit: BoxFit.cover),
                          ),
                          title: Text(book.title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            "Author: ${book.author}\n\$${book.price.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(book: book),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
