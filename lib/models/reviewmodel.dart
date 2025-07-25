// models/reviewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final Timestamp timestamp;
  final List<String> likes;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    required this.likes,
  });


  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      text: data['review'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'review': text,
      'timestamp': timestamp,
      'likes': likes,
    };
  }


  bool isLikedBy(String uid) {
    return likes.contains(uid);
  }


  int get likeCount => likes.length;
}
