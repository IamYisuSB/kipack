import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../trips/models/trip.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';

/// Renders a trip's packing list as a simple, printable PDF — grouped by
/// category, same as the on-screen list, with a checkbox mark for items
/// already packed.
class PackingListPdfService {
  const PackingListPdfService();

  Future<Uint8List> build({
    required Trip trip,
    required List<PackingItem> items,
  }) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('d MMM yyyy', 'es');

    final byCategory = <PackingCategory, List<PackingItem>>{};
    for (final item in items) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            trip.destination,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${dateFormat.format(trip.startDate)}  —  ${dateFormat.format(trip.endDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          for (final entry in byCategory.entries) ...[
            pw.Text(
              entry.key.label,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            for (final item in entry.value)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Text(item.isPacked ? '[x]  ' : '[ ]  '),
                    pw.Expanded(child: pw.Text(item.name)),
                    if (item.quantity > 1) pw.Text('x${item.quantity}'),
                  ],
                ),
              ),
            pw.SizedBox(height: 14),
          ],
        ],
      ),
    );

    return doc.save();
  }
}

const packingListPdfService = PackingListPdfService();
