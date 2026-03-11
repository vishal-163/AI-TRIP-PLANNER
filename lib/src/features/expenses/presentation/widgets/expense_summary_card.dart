import 'package:flutter/material.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double totalExpenses;
  final double perPersonExpense;
  final int numberOfTravelers;

  const ExpenseSummaryCard({
    super.key,
    required this.totalExpenses,
    required this.perPersonExpense,
    required this.numberOfTravelers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Expenses:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '₹${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Per Person ($numberOfTravelers travelers):',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Text(
                  '₹${perPersonExpense.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}