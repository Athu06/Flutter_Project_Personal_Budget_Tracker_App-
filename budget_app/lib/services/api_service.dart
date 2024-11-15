import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart';

class ApiService {
  final String baseUrl =
      'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api';

  // Fetch expenses by type (e.g., "food", "rent", etc.)
  Future<List<ExpenseData>> getExpensesByType(String expenseType) async {
    final Uri uri = Uri.parse('$baseUrl/expenses/$expenseType');
    print('Fetching expenses from URL: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((expense) => ExpenseData.fromJson(expense)).toList();
    } else {
      throw Exception('Failed to fetch expenses by type');
    }
  }

  // /// Fetch all expenses
  // Future<List<ExpenseData>> getExpenses() async {
  //   final Uri uri = Uri.parse('$baseUrl/expenses');
  //   final response = await http.get(uri);

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((expense) => ExpenseData.fromJson(expense)).toList();
  //   } else {
  //     throw Exception('Failed to load expenses');
  //   }
  // }

  /// Update an existing expense.
  Future<void> updateExpense(
      String id, Map<String, dynamic> expenseData) async {
    final Uri uri = Uri.parse('$baseUrl/expense/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expenseData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update expense');
    }
  }

  /// Delete an existing expense.
  Future<bool> deleteExpense(String id) async {
    final Uri uri = Uri.parse('$baseUrl/expense/$id');
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// Add a new expense.
  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    final Uri uri = Uri.parse('$baseUrl/expenses');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expenseData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add expense');
    }
  }
}
