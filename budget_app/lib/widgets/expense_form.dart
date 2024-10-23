// widgets/expense_form.dart
import 'package:flutter/material.dart';
import '../models/expense_models.dart';

class ExpenseForm extends StatefulWidget {
  final Function(ExpenseData) onSubmit;
  final ExpenseData? existingExpense;

  ExpenseForm({required this.onSubmit, this.existingExpense});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      _categoryController.text = widget.existingExpense!.category;
      _descriptionController.text = widget.existingExpense!.description;
      _amountController.text = widget.existingExpense!.amount.toString();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newExpense = ExpenseData(
        id: widget.existingExpense?.id ?? 0,
        category: _categoryController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
      );

      widget.onSubmit(newExpense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.existingExpense == null
                ? 'Add Expense'
                : 'Update Expense'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
