import 'package:flutter/material.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); // Controller for date
  final TextEditingController _customCategoryController =
      TextEditingController(); // Controller for custom category

  late DateTime _selectedDate;
  late String _selectedCategory;

  // Define a list of expense categories
  final List<String> _categories = [
    "Food",
    "Rent",
    "Healthcare",
    "Entertainment",
    "Shopping",
    "Other"
  ];

  @override
  void initState() {
    super.initState();

    // Initialize date and other fields if editing an existing expense
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date.toDate();
      _selectedCategory = widget.expense!.category;
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = "Food"; // Default category
    }
    _dateController.text = _selectedDate.toLocal().toString().split(' ')[0];
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate
            .toLocal()
            .toString()
            .split(' ')[0]; // Update the displayed date
      });
    }
  }

void _saveExpense() async {
  if (_formKey.currentState!.validate()) {
    final expenseData = {
      "category": _selectedCategory == "Other"
          ? _customCategoryController.text
          : _selectedCategory,
      "description": _descriptionController.text,
      "amount": double.parse(_amountController.text),
      "date": _selectedDate.millisecondsSinceEpoch,
    };

    try {
      if (widget.expense != null) {
        // Update existing expense using the ID via API (you can add an API for update if needed)
        expenseData["id"] = widget.expense!.id;
        await apiService.updateExpense(widget.expense!.id, expenseData); // Call your API update method
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Updated')),
        );
      } else {
        // Add new expense via your API
        await apiService.addExpense(expenseData); // Call your addExpense API method
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Saved')),
        );
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
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _customCategoryController.dispose();
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
              // Dropdown for selecting category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a category' : null,
              ),

              // If "Other" is selected, show text field to input custom category
              if (_selectedCategory == "Other")
                TextFormField(
                  controller: _customCategoryController,
                  decoration:
                      const InputDecoration(labelText: 'Custom Category'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a custom category' : null,
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
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true, // Make the date field read-only
                onTap: _selectDate,
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
