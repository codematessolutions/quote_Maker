import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/quotation_item.dart';

class PdfService {
  Future<void> generateQuotationPdf(
      List<QuotationItem> items,
      double grandTotal,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Quotation',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Material', 'Brand', 'Qty', 'Rate', 'Total'],
              data: items
                  .map((e) => [
                e.material,
                e.brand,
                e.qty,
                e.price,
                e.total,
              ])
                  .toList(),
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Grand Total: ₹$grandTotal'),
            )
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}
