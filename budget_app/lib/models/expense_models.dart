import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseData {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  ExpenseData({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  // Convert ExpenseData to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      // If storing in SQLite, use DateTime.toIso8601String()
    };
  }

  // Convert Map to ExpenseData for SQLite
  static ExpenseData fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      id: map['id'] ?? "", // Default value for id if null
      category: map['category'] ?? 'Unknown', // Default value for category
      description: map['description'] ??
          'No description', // Default value for description
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0, // Ensure double type
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(), // Handle null date
    );
  }

  // Convert JSON to ExpenseData (for Firebase)
  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json["id"] ?? "", // Handle null for id
      category: json['category'] ?? 'Unknown', // Default value for category
      description: json['description'] ??
          'No description', // Default value for description
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Ensure double type
      date: (json['date'] is Timestamp)
          ? (json['date'] as Timestamp)
              .toDate() // If it's a Timestamp, convert it to DateTime
          : DateTime.tryParse(json['date']) ??
              DateTime.now(), // Handle null or invalid date
    );
  }

  // Convert ExpenseData to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date), // Store as Firestore Timestamp
    };
  }
}
