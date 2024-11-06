import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart';

class ApiService {
  final String baseUrl =
      'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api';

  // Fetch all expenses
  Future<List<ExpenseData>> getExpenses() async {
    final url = Uri.parse('$baseUrl/expenses');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((expense) => ExpenseData.fromJson(expense)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  // Update an existing expense
  Future<void> updateExpense(
      String id, Map<String, dynamic> expenseData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/expense/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expenseData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update expense');
    }
  }

  // Delete an existing expense
  Future<bool> deleteExpense(String id) async {
    final uri = Uri.parse('$baseUrl/expense/$id');
    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print('Expense deleted successfully');
        return true;
      } else {
        print('Failed to delete expense: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  addExpense(Map<String, Object> expenseData) {}
}
