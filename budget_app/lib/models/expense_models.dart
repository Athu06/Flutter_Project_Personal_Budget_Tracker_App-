// models/expense_model.dart
class ExpenseData {
  final int id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  ExpenseData(
      {required this.id,
      required this.category,
      required this.description,
      required this.amount,
      required this.date});

  // Convert Expense to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Convert Map to Expense
  static ExpenseData fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      id: map['id'],
      category: map['category'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
