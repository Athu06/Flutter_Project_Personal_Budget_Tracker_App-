import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // Import for JSON encoding

class ExpenseDetailScreen extends StatefulWidget {
  @override
  _ExpenseDetailScreenState createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = {
        "category": _categoryController.text,
        "description": _descriptionController.text,
        "amount": double.parse(_amountController.text),
        "date": DateTime.now().toIso8601String(),
      };

      try {
        final response = await http.post(
          Uri.parse(
              'http://localhost:3000/expense'), // Change to your actual API endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(expense),
        );

        if (response.statusCode == 201) {
          // Assuming a successful creation returns 201
          // Show success message using SnackBar
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Expense Saved')));
          Navigator.pop(context); // Navigate back after successful insertion
        } else {
          // Handle server error
          print("Server error: ${response.statusCode}");
          print("Response body: ${response.body}"); // Log the response body
          _showErrorDialog("Server error: ${response.statusCode}");
        }
      } catch (error) {
        print("Error saving expense: $error");
        _showErrorDialog("Error saving expense: $error");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
