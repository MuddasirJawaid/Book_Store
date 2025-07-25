// widgets/review.dart
import 'package:prj/providers/reviewprovide.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewWidget extends StatefulWidget {
  final String bookId;

  const ReviewWidget({super.key, required this.bookId});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _canSubmit = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    reviewProvider.fetchReviews(widget.bookId).then((_) {
      reviewProvider.canSubmitReview(widget.bookId).then((allowed) {
        setState(() {
          _canSubmit = allowed;
          _loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_canSubmit) ...[
          const Text("Write a Review", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Enter your review",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.trim().isEmpty) return;

              await reviewProvider.submitReview(widget.bookId, _controller.text.trim());
              _controller.clear();
              FocusScope.of(context).unfocus();
            },
            child: const Text("Submit Review"),
          ),
          const Divider(),
        ] else ...[
          const Text("Only users who have ordered and received this book can leave a review."),
          const Divider(),
        ],

        const Text("Reviews", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (reviewProvider.reviews.isEmpty)
          const Text("No reviews yet."),
        ...reviewProvider.reviews.map(
          (review) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(review.userName),
            subtitle: Text(review.text),
            trailing: Text(
              review.timestamp.toDate().toLocal().toString().split(' ')[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
