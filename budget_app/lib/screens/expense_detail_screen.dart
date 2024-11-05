import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpenseDetailScreen extends StatefulWidget {
  @override
  _ExpenseDetailScreenState createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories on init
  }

  Future<void> _fetchCategories() async {
    List<String> categories = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('expenses').get();
    for (var doc in querySnapshot.docs) {
      categories.add(doc['category']);
    }
    setState(() {
      _categories = categories;
    });
  }

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
              'https://us-central1-stemious-hands-on-task.cloudfunctions.net/api/expense'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(expense),
        );

        if (response.statusCode == 201) {
          // Show success message using SnackBar
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Expense Saved')));

          // Clear the controllers after saving
          _categoryController.clear();
          _descriptionController.clear();
          _amountController.clear();

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

  void _updateExpense() async {
    if (_selectedCategory != null && _formKey.currentState!.validate()) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('expenses')
          .doc(_selectedCategory);
      await docRef.update({
        "description": _descriptionController.text,
        "amount": double.parse(_amountController.text),
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Expense Updated')));
    }
  }

  void _deleteExpense() async {
    if (_selectedCategory != null) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('expenses')
          .doc(_selectedCategory);
      await docRef.delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Expense Deleted')));
      setState(() {
        _selectedCategory = null;
        _descriptionController.clear();
        _amountController.clear();
      });
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
                Navigator.of(context).pop();
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
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Expense Details'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Add'),
              Tab(text: 'Update'),
              Tab(text: 'Delete'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add Expense Tab
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a category' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a description' : null,
                    ),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
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

            // Update Expense Tab
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Category'),
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'New Description'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter a description' : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'New Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateExpense,
                    child: Text('Update Expense'),
                  ),
                ],
              ),
            ),

            // Delete Expense Tab
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Category to Delete'),
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _deleteExpense,
                    child: Text('Delete Expense'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
