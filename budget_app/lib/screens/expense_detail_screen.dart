import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/expense_models.dart';
import '../services/api_service.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final ExpenseData? expense; // Optional parameter for editing

  const ExpenseDetailScreen({Key? key, this.expense}) : super(key: key);

  @override
  _ExpenseDetailScreenState createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Future<List<ExpenseData>> expensesFuture;

  @override
  void initState() {
    super.initState();

    // Populate fields if editing an existing expense
    if (widget.expense != null) {
      _categoryController.text = widget.expense!.category;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expenseData = {
        "category": _categoryController.text,
        "description": _descriptionController.text,
        "amount": double.parse(_amountController.text),
        "date": DateTime.now().toIso8601String(),
      };

      try {
        if (widget.expense != null && widget.expense!.id != null) {
          // Update existing expense
          await apiService.updateExpense(widget.expense!.id!, expenseData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense Updated')),
          );
          setState(() {
            expensesFuture = apiService.getExpenses();
          });
        } else {
          // Add new expense
          final response = await http.post(
            Uri.parse('${apiService.baseUrl}/expense'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(expenseData),
          );

          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense Saved')),
            );
            setState(() {}); // Refresh UI after save
          } else {
            throw Exception('Failed to add expense');
          }
        }

        Navigator.pop(context, true); // Return success
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
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a category' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(
                  widget.expense != null ? 'Update Expense' : 'Save Expense',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
