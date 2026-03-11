import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/expense_model.dart';
import '../../../../core/providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _payerController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Selected values
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  
  // Available categories
  final List<String> _categories = [
    'Food',
    'Transport',
    'Accommodation',
    'Shopping',
    'Entertainment',
    'Miscellaneous'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExistingExpense();
    }
  }

  void _loadExistingExpense() {
    final expenses = ref.read(expensesProvider);
    final expense = expenses.firstWhere(
      (e) => e.id == widget.expenseId,
      orElse: () => throw Exception('Expense not found'),
    );
    
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();
    _payerController.text = expense.payer;
    _descriptionController.text = expense.description ?? '';
    _selectedCategory = expense.category;
    _selectedDate = expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _payerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      final expense = Expense(
        id: widget.expenseId ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0.0,
        category: _selectedCategory,
        payer: _payerController.text.trim(),
        date: _selectedDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );
      
      if (widget.expenseId != null) {
        ref.read(expensesProvider.notifier).updateExpense(expense);
      } else {
        ref.read(expensesProvider.notifier).addExpense(expense);
      }
      
      Navigator.of(context).pop();
    }
  }

  void _deleteExpense() {
    if (widget.expenseId != null) {
      ref.read(expensesProvider.notifier).deleteExpense(widget.expenseId!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get trip members
    final tripMembers = ref.watch(tripMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId != null ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (widget.expenseId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text('Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: _deleteExpense,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What was this expense for?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Payer
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return tripMembers;
                  }
                  return tripMembers
                      .where((member) => member.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                onSelected: (String selection) {
                  _payerController.text = selection;
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onFieldSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Paid by',
                      hintText: 'Who paid for this?',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter who paid';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Date
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add any additional details',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: Text(widget.expenseId != null ? 'Update Expense' : 'Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}