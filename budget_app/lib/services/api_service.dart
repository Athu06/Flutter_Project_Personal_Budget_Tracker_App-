import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart'; // Import your ExpenseData model

const String baseUrl = 'http://localhost:3000'; // Base URL of your Node.js API

class ApiService {
  // Fetch all expenses from the API
  Future<List<ExpenseData>> getExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((expense) => ExpenseData.fromJson(expense)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  // Add a new expense
  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expense'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expenseData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add expense');
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

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/expense/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }
}
