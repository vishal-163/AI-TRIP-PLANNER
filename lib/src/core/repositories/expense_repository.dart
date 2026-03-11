import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> saveExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseSplit>> getExpenseSplits();
  Future<void> saveExpenseSplit(ExpenseSplit split);
  Future<void> deleteExpenseSplit(String expenseId);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  static const String _expensesKey = 'expenses';
  static const String _splitsKey = 'expense_splits';

  @override
  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList(_expensesKey) ?? [];
    
    return expensesJson
        .map((json) => Expense.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    
    // Check if expense already exists
    final existingIndex = expenses.indexWhere((e) => e.id == expense.id);
    if (existingIndex != -1) {
      expenses[existingIndex] = expense;
    } else {
      expenses.add(expense);
    }
    
    final expensesJson = expenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_expensesKey, expensesJson);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await saveExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    
    expenses.removeWhere((expense) => expense.id == id);
    
    final expensesJson = expenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_expensesKey, expensesJson);
    
    // Also delete any splits associated with this expense
    await deleteExpenseSplit(id);
  }

  @override
  Future<List<ExpenseSplit>> getExpenseSplits() async {
    final prefs = await SharedPreferences.getInstance();
    final splitsJson = prefs.getStringList(_splitsKey) ?? [];
    
    return splitsJson
        .map((json) => ExpenseSplit.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> saveExpenseSplit(ExpenseSplit split) async {
    final prefs = await SharedPreferences.getInstance();
    final splits = await getExpenseSplits();
    
    // Check if split already exists
    final existingIndex = splits.indexWhere((s) => s.expenseId == split.expenseId);
    if (existingIndex != -1) {
      splits[existingIndex] = split;
    } else {
      splits.add(split);
    }
    
    final splitsJson = splits.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_splitsKey, splitsJson);
  }

  @override
  Future<void> deleteExpenseSplit(String expenseId) async {
    final prefs = await SharedPreferences.getInstance();
    final splits = await getExpenseSplits();
    
    splits.removeWhere((split) => split.expenseId == expenseId);
    
    final splitsJson = splits.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_splitsKey, splitsJson);
  }
}