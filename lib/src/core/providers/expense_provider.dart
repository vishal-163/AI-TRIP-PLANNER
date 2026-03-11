import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/expense_repository.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl();
});

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier(ref.read(expenseRepositoryProvider));
});

final expenseSplitsProvider = StateNotifierProvider<ExpenseSplitsNotifier, List<ExpenseSplit>>((ref) {
  return ExpenseSplitsNotifier(ref.read(expenseRepositoryProvider));
});

// Provider for managing trip members
final tripMembersProvider = StateProvider<List<String>>((ref) {
  return []; // Start with empty list
});

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final ExpenseRepository _repository;
  
  ExpensesNotifier(this._repository) : super([]) {
    _loadExpenses();
  }
  
  Future<void> _loadExpenses() async {
    final expenses = await _repository.getExpenses();
    state = expenses;
  }
  
  Future<void> addExpense(Expense expense) async {
    await _repository.saveExpense(expense);
    await _loadExpenses();
  }
  
  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await _loadExpenses();
  }
  
  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    await _loadExpenses();
  }
}

class ExpenseSplitsNotifier extends StateNotifier<List<ExpenseSplit>> {
  final ExpenseRepository _repository;
  
  ExpenseSplitsNotifier(this._repository) : super([]) {
    _loadSplits();
  }
  
  Future<void> _loadSplits() async {
    final splits = await _repository.getExpenseSplits();
    state = splits;
  }
  
  Future<void> addSplit(ExpenseSplit split) async {
    await _repository.saveExpenseSplit(split);
    await _loadSplits();
  }
  
  Future<void> removeSplit(String expenseId) async {
    await _repository.deleteExpenseSplit(expenseId);
    await _loadSplits();
  }
}

// Computed providers for expense calculations
final totalExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
});

final perPersonExpenseProvider = Provider.family<double, int>((ref, numberOfPeople) {
  if (numberOfPeople <= 0) return 0.0;
  
  final total = ref.watch(totalExpensesProvider);
  return total / numberOfPeople;
});

// Enhanced settlements provider that calculates who owes what to whom based on actual trip members
final settlementsProvider = Provider<List<Settlement>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final tripMembers = ref.watch(tripMembersProvider);
  
  if (expenses.isEmpty || tripMembers.isEmpty) {
    return [];
  }
  
  // Calculate total expenses
  final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  
  // Calculate per person share
  final perPersonShare = totalExpenses / tripMembers.length;
  
  // Track how much each person has paid
  final Map<String, double> paidAmounts = {};
  
  // Initialize all members with 0 paid amount
  for (final member in tripMembers) {
    paidAmounts[member] = 0.0;
  }
  
  // Add amounts paid by each person
  for (final expense in expenses) {
    if (expense.payer.isNotEmpty && paidAmounts.containsKey(expense.payer)) {
      paidAmounts[expense.payer] = (paidAmounts[expense.payer] ?? 0) + expense.amount;
    }
  }
  
  // Calculate net amounts (paid - owed)
  final Map<String, double> netAmounts = {};
  for (final person in tripMembers) {
    netAmounts[person] = (paidAmounts[person] ?? 0) - perPersonShare;
  }
  
  // Create settlements - positive means they should receive money, negative means they owe money
  final List<Settlement> settlements = [];
  
  // Separate creditors (positive net) and debtors (negative net)
  final creditors = <String, double>{};
  final debtors = <String, double>{};
  
  netAmounts.forEach((person, amount) {
    if (amount > 0.01) { // Positive balance - person is a creditor
      creditors[person] = amount;
    } else if (amount < -0.01) { // Negative balance - person is a debtor
      debtors[person] = amount.abs();
    }
  });
  
  // Create settlements by matching creditors and debtors
  final creditorEntries = creditors.entries.toList();
  final debtorEntries = debtors.entries.toList();
  
  int creditorIndex = 0;
  int debtorIndex = 0;
  
  while (creditorIndex < creditorEntries.length && debtorIndex < debtorEntries.length) {
    final creditor = creditorEntries[creditorIndex];
    final debtor = debtorEntries[debtorIndex];
    
    final amountToSettle = creditor.value < debtor.value 
        ? creditor.value 
        : debtor.value;
    
    settlements.add(Settlement(
      from: debtor.key,
      to: creditor.key,
      amount: amountToSettle,
    ));
    
    // Update remaining amounts
    creditorEntries[creditorIndex] = MapEntry(creditor.key, creditor.value - amountToSettle);
    debtorEntries[debtorIndex] = MapEntry(debtor.key, debtor.value - amountToSettle);
    
    // Move to next creditor/debtor if current one is settled
    if (creditorEntries[creditorIndex].value <= 0.01) {
      creditorIndex++;
    }
    if (debtorEntries[debtorIndex].value <= 0.01) {
      debtorIndex++;
    }
  }
  
  return settlements;
});