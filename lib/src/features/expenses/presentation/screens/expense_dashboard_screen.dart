import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/expense_provider.dart';
import '../../../../core/providers/trip_provider.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/models/expense_model.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/expense_summary_card.dart';

class ExpenseDashboardScreen extends ConsumerWidget {
  const ExpenseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final itinerary = ref.watch(itineraryProvider);
    final tripMembers = ref.watch(tripMembersProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final settlements = ref.watch(settlementsProvider);

    final perPersonExpense = tripMembers.isEmpty ? 0.0 : totalExpenses / tripMembers.length;

    Future<void> exportToPdf() async {
      HapticFeedback.mediumImpact();
      try {
        final path = await PdfService.generateExpenseReport(expenses, itinerary);
        if (context.mounted) {
          // Share the file instead of trying to open it directly
          await Share.shareXFiles(
            [XFile(path)],
            text: 'Here is the trip expense report!',
            subject: 'Trip Expense Report',
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to share PDF: $e')),
          );
        }
      }
    }

    return GradientScaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: expenses.isEmpty ? null : exportToPdf,
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => _showManageMembersDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _showAddMemberDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ExpenseSummaryCard(
                totalExpenses: totalExpenses,
                perPersonExpense: perPersonExpense,
                numberOfTravelers: tripMembers.length,
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
              const SizedBox(height: 24),
              
              if (settlements.isNotEmpty) ...[
                _buildSettlementsSection(context, settlements)
                    .animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
                const SizedBox(height: 24),
              ],
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Expenses', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/add-expense');
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),
              
              expenses.isEmpty
                  ? SizedBox(
                      height: 300,
                      child: _buildEmptyState(context),
                    ).animate().fadeIn(delay: 500.ms)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpenseListItem(
                            expense: expense,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push('/add-expense', extra: expense.id);
                            },
                          ),
                        ).animate().slideX(begin: 1, end: 0, delay: Duration(milliseconds: 100 * index), duration: 500.ms, curve: Curves.easeOutBack).fadeIn();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final memberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Trip Member', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: memberController,
          decoration: InputDecoration(
            labelText: 'Member Name',
            hintText: 'Enter member name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          onSubmitted: (_) => _addMember(context, ref, memberController),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addMember(context, ref, memberController),
            child: const Text('Add'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _addMember(BuildContext context, WidgetRef ref, TextEditingController controller) {
    if (controller.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
      final members = ref.read(tripMembersProvider);
      if (!members.contains(controller.text.trim())) {
        ref.read(tripMembersProvider.notifier).state = [...members, controller.text.trim()];
      }
      Navigator.of(context).pop();
    }
  }

  void _showManageMembersDialog(BuildContext context, WidgetRef ref) {
    final tripMembers = ref.read(tripMembersProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Members', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tripMembers.length,
            itemBuilder: (context, index) {
              final member = tripMembers[index];
              return ListTile(
                title: Text(member, style: GoogleFonts.poppins()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final members = ref.read(tripMembersProvider);
                    ref.read(tripMembersProvider.notifier).state = 
                        members.where((m) => m != member).toList();
                    Navigator.of(context).pop(); // Close to refresh (simple way) or use StatefulBuilder
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildSettlementsSection(BuildContext context, List<Settlement> settlements) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settlements', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...settlements.map((settlement) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${settlement.from} owes ${settlement.to}',
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                  ),
                  Text(
                    '₹${settlement.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No expenses yet', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap + to add one', style: GoogleFonts.poppins(color: Colors.grey[500])),
        ],
      ),
    );
  }
}