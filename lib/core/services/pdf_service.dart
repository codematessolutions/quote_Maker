import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/quotation_item.dart';
import '../errors/app_exception.dart';

class PdfService {
  Future<void> generateQuotationPdf(
    List<QuotationItem> items,
    double grandTotal,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Quotation',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontSize: 16.sp,
                  fontWeight: pw.FontWeight.bold
                ),
                headers: ['Material', 'Brand', 'Qty', 'Rating', 'Warranty'],
                cellStyle: pw.TextStyle(   fontWeight: pw.FontWeight.normal,fontSize: 15.sp),
                data: items
                    .map(
                      (e) => [
                        e.material,
                        e.brand,
                        e.qty,
                        e.rating,
                        e.warranty,
                      ],
                    )
                    .toList(),
              ),
              // pw.Divider(),
              // pw.Align(
              //   alignment: pw.Alignment.centerRight,
              //   child: pw.Text('Grand Total: ₹$grandTotal'),
              // )
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (_) => pdf.save());
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
