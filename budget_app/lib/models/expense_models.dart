import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseData {
  final String id;
  final String category;
  final double amount;
  final Timestamp date;  // Keep it as Timestamp
  final String description;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ExpenseData({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create an instance of ExpenseData from a JSON map (deserialization)
  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: json['date'] is Timestamp ? json['date'] as Timestamp : Timestamp.fromMillisecondsSinceEpoch(json['date']),  // Ensure proper handling of Timestamp
      description: json['description'],
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] as Timestamp : Timestamp.fromMillisecondsSinceEpoch(json['date']),
      updatedAt: json['updatedAt'] is Timestamp ? json['updatedAt'] as Timestamp : Timestamp.fromMillisecondsSinceEpoch(json['date']),
    );
  }

  // Method to convert an instance of ExpenseData to a JSON map (serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,  // Save the Timestamp as milliseconds
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
