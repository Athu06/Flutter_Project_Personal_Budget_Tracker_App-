import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart';

class ApiService {
  final String baseUrl =
      'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api';

/// Fetch expenses with filters (category, date range, sorting)
Future<List<ExpenseData>> getExpenses({
  String expenseType = "All",
  Timestamp? startDate,
  Timestamp? endDate,
  String? sortBy,
}) async {
  try {
    // Base URL for API
    String baseUrl = 'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api/expenses';

    // Construct query parameters
    final Map<String, String> queryParameters = {
      if (expenseType != "All") 'expenseType': expenseType,
      if (startDate != null) 'startDate': startDate.toDate().toIso8601String(),
      if (endDate != null) 'endDate': endDate.toDate().toIso8601String(),
      if (sortBy != null) 'sortBy': sortBy, // Sort parameter
    };

    // If no parameters are passed, use the default sortBy
    if (queryParameters.isEmpty && sortBy == null) {
      queryParameters['sortBy'] = 'date_desc';
    }

    // Construct final URI with query parameters
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);

    print('Fetching expenses with URL: $uri');
    
    // Make the API request
    final response = await http.get(uri);

    List<ExpenseData> parseExpenseData(String responseBody) {
      final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
      return parsed.map<ExpenseData>((json) => ExpenseData.fromJson(json)).toList();
    }

    // Handle response
    if (response.statusCode == 200) {
      // Parse and return expenses
      return parseExpenseData(response.body);
    } else {
      throw Exception('Failed to load expenses');
    }
  } catch (e) {
    print('Error fetching expenses: $e');
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
