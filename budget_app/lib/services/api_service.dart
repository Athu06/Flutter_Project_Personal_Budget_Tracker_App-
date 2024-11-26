import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart';

class ApiService {
  final String baseUrl =
      'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api';

/// Fetch expenses with filters (category, date range, sorting)
Future<List<ExpenseData>> getExpenses({
  String expenseType = "All",
  int? startDate,
  int? endDate,
  String? sortBy,
}) async {
  try {
    // Construct query parameters
    final Map<String, String> queryParameters = {
      if (expenseType != "All") 'expenseType': expenseType,
      if (startDate != null) 'startDate': startDate.toString(),
      if (endDate != null) 'endDate': endDate.toString(),
      if (sortBy != null) 'sortBy': sortBy,
    };

    final Uri uri = Uri.parse('$baseUrl/expenses').replace(queryParameters: queryParameters);

    print('Fetching expenses with URL: $uri');

    // Make the GET request
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((expense) => ExpenseData.fromJson(expense)).toList();
    } else {
      // Log the error and provide a fallback
      print('Error fetching expenses: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch expenses');
    }
  } catch (e) {
    // Log the error and handle it gracefully
    print('Error occurred while fetching expenses: $e');
    // Return an empty list or provide an error message for UI handling
    return [];
  }
}


  /// Update an existing expense
  Future<void> updateExpense(String id, Map<String, dynamic> expenseData) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/expense/$id');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(expenseData),
      );

      if (response.statusCode == 200) {
        print('Expense updated successfully');
      } else {
        print('Failed to update expense: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update expense');
      }
    } catch (e) {
      print('Error occurred while updating expense: $e');
      throw Exception('Error updating expense');
    }
  }

  /// Delete an existing expense
  Future<bool> deleteExpense(String id) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/expense/$id');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print('Expense deleted successfully');
        return true;
      } else {
        print('Failed to delete expense: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while deleting expense: $e');
      return false;
    }
  }

  /// Add a new expense
  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/expenses');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(expenseData),
      );

      if (response.statusCode == 201) {
        print('Expense added successfully');
      } else {
        print('Failed to add expense: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      print('Error occurred while adding expense: $e');
      throw Exception('Error adding expense');
    }
  }
}
