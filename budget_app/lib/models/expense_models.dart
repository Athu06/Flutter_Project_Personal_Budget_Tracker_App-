class ExpenseData {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  ExpenseData({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date']), // Convert to DateTime from timestamp
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.millisecondsSinceEpoch, // Convert to milliseconds timestamp
      'description': description,
    };
  }
}
