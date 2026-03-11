import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String payer;
  final DateTime date;
  final String? description;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.payer,
    required this.date,
    this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? payer,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      payer: payer ?? this.payer,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, category, payer, date];
}

@JsonSerializable()
class ExpenseSplit {
  final String expenseId;
  final Map<String, double> splitAmounts;

  ExpenseSplit({
    required this.expenseId,
    required this.splitAmounts,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSplitFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseSplitToJson(this);
}

@JsonSerializable()
class Settlement {
  final String from;
  final String to;
  final double amount;

  Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);

  Map<String, dynamic> toJson() => _$SettlementToJson(this);
}