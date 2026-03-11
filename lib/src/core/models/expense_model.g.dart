// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  payer: json['payer'] as String,
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String?,
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'category': instance.category,
  'payer': instance.payer,
  'date': instance.date.toIso8601String(),
  'description': ?instance.description,
};

ExpenseSplit _$ExpenseSplitFromJson(Map<String, dynamic> json) => ExpenseSplit(
  expenseId: json['expenseId'] as String,
  splitAmounts: (json['splitAmounts'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$ExpenseSplitToJson(ExpenseSplit instance) =>
    <String, dynamic>{
      'expenseId': instance.expenseId,
      'splitAmounts': instance.splitAmounts,
    };

Settlement _$SettlementFromJson(Map<String, dynamic> json) => Settlement(
  from: json['from'] as String,
  to: json['to'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$SettlementToJson(Settlement instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'amount': instance.amount,
    };
