class ExpenseData {
  final int id;
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
    };
  }

  // Convert Map to ExpenseData for SQLite
  static ExpenseData fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      id: map['id'] != null
          ? int.tryParse(map['id'].toString()) ?? 0
          : 0, // Handle null
      category: map['category'] ?? 'Unknown', // Default value for category
      description: map['description'] ??
          'No description', // Default value for description
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0, // Ensure double type
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(), // Handle null
    );
  }

  // Convert JSON to ExpenseData
  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: int.tryParse(json['id'].toString()) ?? 0, // Handle null
      category: json['category'] ?? 'Unknown', // Default value for category
      description: json['description'] ??
          'No description', // Default value for description
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Ensure double type
      date: DateTime.tryParse(json['date']) ?? DateTime.now(), // Handle null
    );
  }

  // Convert ExpenseData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
