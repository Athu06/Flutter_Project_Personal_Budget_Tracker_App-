import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  final String baseUrl =
      'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api';

  // Fetch the current user's token
  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    return user.getIdToken(true); // Force a token refresh
  }

  // Fetch the email and UID of all users (for admin use)
  Future<Map<String, String>> fetchUserEmails() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      Map<String, String> userEmailsToUID = {
        'Users': '', // Default value for the dropdown
        for (var doc in snapshot.docs) doc['email']: doc.id,
      };

      return userEmailsToUID;
    } catch (error) {
      print("Error fetching user emails: $error");
      return {}; // Return an empty map on error
    }
  }

  /// Get expenses for specific user from admin page (from dropdown).
    Future<List<ExpenseData>> getExpensesbyUser({
      String? userId,
      String expenseType = "All",  // Default to "All" if not passed
      int? startDate,
      int? endDate,
      String? sortBy,
    }) async {
      try {
        // Get the Firebase authentication token
        String? token = await FirebaseAuth.instance.currentUser!.getIdToken();
        if (token == null || token.isEmpty) {
          throw Exception('Token is null or empty');
        }

        print('Retrieved token: $token');

        // Construct query parameters
        final Map<String, String> queryParameters = {
          'uid': userId ?? FirebaseAuth.instance.currentUser!.uid,  // Use passed userId or current user's UID
          if (expenseType != "All") 'expenseType': expenseType,
          if (startDate != null) 'startDate': startDate.toString(),
          if (endDate != null) 'endDate': endDate.toString(),
          'sortBy': sortBy ?? 'date_desc',  // Default to 'date_desc' if sortBy is not provided
        };

        // Construct final URI with query parameters
        final Uri uri = Uri.parse(
          'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api/expenses/user'
        ).replace(queryParameters: queryParameters);

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
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((e) => ExpenseData.fromJson(e)).toList();
        } else {
          throw Exception('Failed to load expenses: ${response.body}');
        }
      } catch (e) {
        print('Error fetching expenses: $e');
        return [];
      }
    }


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

      // Construct query parameters
      final Map<String, String> queryParameters = {
        'uid': uid,  // Include the user's UID in the query
        if (expenseType != "All") 'expenseType': expenseType,
        if (startDate != null) 'startDate': startDate.toString(),
        if (endDate != null) 'endDate': endDate.toString(),
        'sortBy': sortBy ?? 'date_desc',
      };

      // Construct final URI with query parameters
      final Uri uri = Uri.parse(baseUrl + '/expenses').replace(queryParameters: queryParameters);

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

      if (idToken == null) {
        throw Exception('No Firebase ID token available');
      }

      final Uri uri = Uri.parse('$baseUrl/expense/$id');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
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

      if (idToken == null) {
        throw Exception('No Firebase ID token available');
      }

      final Uri uri = Uri.parse('$baseUrl/expense/$id');
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
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

      if (idToken == null) {
        throw Exception('No Firebase ID token available');
      }

      final Uri uri = Uri.parse('$baseUrl/expense');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
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
