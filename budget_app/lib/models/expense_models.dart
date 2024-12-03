import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseData {
  final String id;
  final String userId; // Added userId field for user-specific data
  final String category;
  final double amount;
  final Timestamp date; // Firebase Timestamp
  final String description;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ExpenseData({
    required this.id,
    required this.userId, // Include userId in the constructor
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create an instance of ExpenseData from Firestore DocumentSnapshot
  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    try {
      return ExpenseData(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        category: json['category'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        date: json['date'] is Timestamp
            ? json['date'] as Timestamp
            : Timestamp.fromMillisecondsSinceEpoch(
                json['date']['_seconds'] * 1000),
        description: json['description'] ?? '',
        createdAt: json['createdAt'] is Timestamp
            ? json['createdAt'] as Timestamp
            : Timestamp.fromMillisecondsSinceEpoch(
                json['createdAt']['_seconds'] * 1000),
        updatedAt: json['updatedAt'] is Timestamp
            ? json['updatedAt'] as Timestamp
            : Timestamp.fromMillisecondsSinceEpoch(
                json['updatedAt']['_seconds'] * 1000),
      );
    } catch (e) {
      print('Error parsing ExpenseData: $e');
      rethrow;
    }
  }

  /// Method to convert an instance of ExpenseData to a JSON map (serialization)
  Map<String, dynamic> toJson() {
    assert(id.isNotEmpty, 'Expense ID cannot be empty');
    assert(userId.isNotEmpty, 'User ID cannot be empty');
    assert(category.isNotEmpty, 'Category cannot be empty');
    return {
      'id': id,
      'userId': userId, // Include userId in the JSON map
      'category': category,
      'amount': amount,
      'date': date, // Keep as Timestamp for Firestore
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convenience methods to convert Firebase Timestamp to DateTime for UI usage
  DateTime get dateAsDateTime => date.toDate();
  DateTime get createdAtAsDateTime => createdAt.toDate();
  DateTime get updatedAtAsDateTime => updatedAt.toDate();

  /// Convenience method to display formatted date for the UI
  String get formattedDate {
    final dateTime = date.toDate();
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }
}
  