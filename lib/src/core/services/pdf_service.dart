import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/expense_model.dart';
import '../../core/models/itinerary_model.dart';

class PdfService {

  static Future<String> generateExpenseReport(
    List<Expense> expenses,
    ItineraryModel? itinerary,
  ) async {
    final pdf = pw.Document();
    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          // Title Section
          pw.Column(
            children: [
              pw.Text(
                'Trip Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (itinerary != null)
                pw.Text(
                  itinerary.summary.tripTitle,
                  style: const pw.TextStyle(fontSize: 18),
                ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on ${DateTime.now().toString().split(' ')[0]}',
                style: const pw.TextStyle(
                  color: PdfColors.grey,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 30),
            ],
          ),

          // Expense Summary Section
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Expense Summary',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Estimated Cost: ₹${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              if (itinerary != null)
                pw.Text(
                  'Per Person (${itinerary.summary.numberOfTravelers} travelers): ₹${(totalAmount / itinerary.summary.numberOfTravelers).toStringAsFixed(2)}',
                  style: const pw.TextStyle(
                    fontSize: 14,
                  ),
                ),
              pw.SizedBox(height: 30),
            ],
          ),

          // Detailed Expenses Section
          pw.Text(
            'Detailed Expenses',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Title', 'Category', 'Amount', 'Paid By', 'Date'],
            data: [
              ...expenses.map((expense) => [
                    expense.title,
                    expense.category,
                    pw.Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    expense.payer,
                    expense.date.toString().split(' ')[0],
                  ]),
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    );

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/expense_report.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
  
  /// Generate a PDF of the itinerary
  static Future<String> generateItineraryReport(ItineraryModel itinerary) async {
    final pdf = pw.Document();

    // Add title page with enhanced styling
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              itinerary.summary.tripTitle,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              '${itinerary.summary.origin} → ${itinerary.summary.destinations.join(', ')}',
              style: pw.TextStyle(
                fontSize: 18,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${DateFormat('MMM dd, yyyy').format(itinerary.summary.startDate)} - ${DateFormat('MMM dd, yyyy').format(itinerary.summary.endDate)}',
              style: pw.TextStyle(
                fontSize: 16,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${itinerary.summary.numberOfTravelers} Traveler${itinerary.summary.numberOfTravelers > 1 ? 's' : ''}',
              style: pw.TextStyle(
                fontSize: 16,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: itinerary.summary.interests.map((interest) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    interest,
                    style: pw.TextStyle(
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Generated on ${DateTime.now().toString().split(' ')[0]}',
              style: const pw.TextStyle(
                color: PdfColors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    // Add estimated budget section with improved formatting
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Estimated Budget',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Cost:',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '₹${itinerary.estimatedBudget.totalEstimatedCost.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Per Person:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                      pw.Text(
                        '₹${itinerary.estimatedBudget.perPersonCost.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Cost Breakdown:',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 12),
            ...itinerary.estimatedBudget.costBreakdown.entries.map((entry) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12.0),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                    pw.Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.normal,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );

    // Add daily itinerary with improved formatting
    for (final day in itinerary.dailyItinerary) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue600,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  'Day ${day.dayNumber}: ${day.title}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                DateFormat('EEEE, MMM dd, yyyy').format(day.date),
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 16),
              ...day.activities.asMap().entries.map((activityEntry) {
                final activityIndex = activityEntry.key;
                final activity = activityEntry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                '${activity.time} - ${activity.title}',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue800,
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue100,
                                borderRadius: pw.BorderRadius.circular(12),
                              ),
                              child: pw.Text(
                                activity.category,
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.blue800,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          activity.description,
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Duration: ${activity.durationMinutes} mins',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                            if (activity.cost != null)
                              pw.Text(
                                'Cost: ₹${activity.cost!.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.green700,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          activity.location,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }

    // Add recommendations with improved styling
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Recommended Places',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 20),
            ...itinerary.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              recommendation.name,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ),
                          if (recommendation.rating != null)
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.amber100,
                                borderRadius: pw.BorderRadius.circular(12),
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Icon(pw.IconData(0x2605), color: PdfColors.amber800, size: 12),
                                  pw.SizedBox(width: 4),
                                  pw.Text(
                                    recommendation.rating.toString(),
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: PdfColors.amber800,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          recommendation.category,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue800,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        recommendation.description,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        recommendation.address,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                      if (recommendation.averageCost != null)
                        pw.SizedBox(height: 12),
                      if (recommendation.averageCost != null)
                        pw.Text(
                          'Average Cost: ₹${recommendation.averageCost!.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.green700,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );

    // Add travel tips if available with improved styling
    if (itinerary.travelTips != null && itinerary.travelTips!.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Travel Tips',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 20),
              ...itinerary.travelTips!.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text(
                                '💡 Tip: ', 
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColors.blue800,
                                  fontWeight: pw.FontWeight.bold,
                                )
                              ),
                              pw.SizedBox(width: 8),
                              pw.Expanded(
                                child: pw.Text(
                                  tip.title,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          tip.description,
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/itinerary_report.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
}