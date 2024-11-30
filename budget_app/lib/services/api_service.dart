import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get the Firebase authentication token
    String? token = await FirebaseAuth.instance.currentUser!.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is null or empty');
    }

    print('Retrieved token: $token');

    // Base URL for API
    String baseUrl = 'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api/expenses';

    // Construct query parameters
    final Map<String, String> queryParameters = {
      'uid': uid,  // Include the user's UID in the query
      if (expenseType != "All") 'expenseType': expenseType,
      if (startDate != null) 'startDate': startDate.toString(),
      if (endDate != null) 'endDate': endDate.toString(),
    };

    // Set default sortBy to 'date_desc' if none provided
    queryParameters['sortBy'] = sortBy ?? 'date_desc';

    // Construct final URI with query parameters
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);

    print('Fetching expenses with URL: $uri');

    // Make the API request with the Authorization token in the headers
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token', // Include token in the headers
      },
    );

    // Handle response (adjust this based on your actual API response)
    if (response.statusCode == 200) {
      // Parse and return expenses
      return parseExpenseData(response.body);
    } else {
      throw Exception('Failed to load expenses: ${response.body}');
    }
  } catch (e) {
    print('Error fetching expenses: $e');
    return [];
  }
}



  /// Update an existing expense
  Future<void> updateExpense(String id, Map<String, dynamic> expenseData) async {
    try {

      // Get the Firebase ID token for the current user
      String? idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

      // Check if the ID token is null
      if (idToken == null) {
        throw Exception('No Firebase ID token available');
      }

      // API URL
      final Uri uri = Uri.parse('$baseUrl/expense/$id');

      // Send the request with the authentication token in the Authorization header
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',  // Include the token in the header
        },
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

      // Get the Firebase ID token for the current user
      String? idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

      // Check if the ID token is null
      if (idToken == null) {
        throw Exception('No Firebase ID token available');
      }

      // API URL
      final Uri uri = Uri.parse('$baseUrl/expense/$id');

      // Send the request with the authentication token in the Authorization header
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',  // Include the token in the header
        },
      );

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
      // Get the Firebase ID token for the current user
      String? idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

      // Check if the ID token is null
      if (idToken == null) {
        throw Exception('No Firebase ID token available');
      }

      // API URL
      final Uri uri = Uri.parse('$baseUrl/expense');

      // Send the request with the authentication token in the Authorization header
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',  // Include the token in the header
        },
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

  // Helper method to parse expense data from response
  List<ExpenseData> parseExpenseData(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<ExpenseData>((json) => ExpenseData.fromJson(json)).toList();
  }
}
