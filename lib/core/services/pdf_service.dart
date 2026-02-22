import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';

import '../../data/models/profile.dart';
import '../../data/models/quotation_item.dart';
import '../errors/app_exception.dart';
import 'package:quatation_making/features/quotation/data/summary_model.dart';

class PdfService {
  Future<void> generateQuotationPdf(
    List<QuotationItem> items,
    double grandTotal, {
    required PaymentSummary summary,
  }) async {
    try {
      final pdf = pw.Document();
      final ttf = pw.Font.ttf(
        await rootBundle.load('assets/fonts/noto-sans.regular.ttf'),);

      final ByteData imageData = await rootBundle.load(AppAssets.solar);
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      final ByteData logo = await rootBundle.load(AppAssets.appLogo);
      final Uint8List logoImage = logo.buffer.asUint8List();
      final pw.MemoryImage image = pw.MemoryImage(imageBytes);
      final pw.MemoryImage logoImage2 = pw.MemoryImage(logoImage);

      final ByteData mImage = await rootBundle.load(AppAssets.mudra);
      final Uint8List mImage1 = mImage.buffer.asUint8List();
      final pw.MemoryImage mudraImage = pw.MemoryImage(mImage1);
      final theme = pw.ThemeData.withFont(
        base: ttf,
        bold: ttf,
      );
      // COVER PAGE (similar to first image)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Center(
                  child: pw.Image(
                    image,
                    width: context.page.pageFormat.availableWidth,
                    height: 190,
                    fit: pw.BoxFit.cover,
                  ),
                ),
                pw.SizedBox(height: 50),
                pw.Text(
                  'PROPOSAL',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Image(
                    logoImage2,
                    width: context.page.pageFormat.availableWidth,
                    height: 100,
                    fit: pw.BoxFit.contain,
                  ),
                ),

                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Image(
                    mudraImage,
                    width: context.page.pageFormat.availableWidth,
                    height: 90,
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  '+91 77366 84546, +91 80861 38435',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'energyecovolt71@gmail.com',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey,),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'ecovoltenergy',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey,),
                ),
                pw.SizedBox(height: 40),
              ],
            );
          },
        ),
      );

      // MATERIAL LIST + PAYMENT SUMMARY (similar to second image)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          theme: theme,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  color: PdfColors.blueAccent,
                  child: pw.Center(
                    child: pw.Text(
                      '3KW ONGRID PROJECT MATERIAL LIST',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(3),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(2),
                    4: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.blue100,),
                      children: [
                        _tableHeaderCell('MATERIALS'),
                        _tableHeaderCell('COMPANY'),
                        _tableHeaderCell('WARRANTY'),
                        _tableHeaderCell('RATING'),
                        _tableHeaderCell('QTY'),
                      ],
                    ),
                    ...items.map(
                      (e) => pw.TableRow(
                        children: [
                          _tableCell(e.material),
                          _tableCell(e.brand),
                          _tableCell(e.warranty),
                          _tableCell(e.rating.toString()),
                          _tableCell(e.qty.toString(), alignRight: true),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(2),
                  },
                  children: [
                    _summaryTableRow(
                      'TOTAL AMOUNT',
                      summary.totalAmount,
                      bold: true,
                      shaded: true,
                    ),
                    _summaryTableRow(
                      'SUBSIDY\n(Subsidy cheque to be submitted at the time of registration)',
                      summary.subsidy,
                      isSubsidy: true,
                    ),
                    _summaryTableRow(
                      'PAYABLE AMOUNT AFTER SUBSIDY',
                      summary.payableAfterSubsidy,
                    ),
                    _summaryTableRow(
                      'NEW YEAR SPECIAL OFFER',
                      summary.specialOffer,
                      emphasisRed: true,
                    ),
                    _summaryTableRow(
                      'FINAL PAYABLE AMOUNT',
                      summary.finalPayableAmount,
                      bold: true,
                      shaded: true,
                    ),
                    _summaryTableRow(
                      'PAYMENT SCHEDULE',
                      0,
                      isHeaderRow: true,
                    ),
                    _summaryTableRow(
                      'ADVANCE (Payable on material delivery)',
                      summary.advance,
                    ),
                    _summaryTableRow(
                      'AFTER INSTALLATION',
                      summary.afterInstallation,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'KSEB REGISTRATION FEES, KSEB SINGLE PHASE NET METER AND STRUCTURE WORK GI INCLUDED',
                  style:  pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      // TERMS & CONDITIONS (similar to third image)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(18),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.SizedBox(height: 15),
                pw.Center(
                  child: pw.Text(
                    'TERMS AND CONDITIONS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.black,
                      // decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(4),
                  },
                  children: [
                    _termsRow(
                      'PAYMENT',
                      'ADVANCE PAYMENT AND SIGNED SUBSIDY CHEQUE LEAVES MUST BE ISSUED UPON MATERIAL DELIVERY.',
                    ),
                    _termsRow(
                      'DELIVERY',
                      'MATERIALS WILL BE DELIVERED WITHIN 10 DAYS FROM THE DATE OF WORK ORDER.',
                    ),
                    _termsRow(
                      'TAX',
                      'GST INCLUDED.',
                    ),
                    _termsRow(
                      'TRANSPORTATION & LIFTING CHARGES',
                      'INCLUDED.',
                    ),
                    _termsRow(
                      'KSEB REGISTRATION & AGREEMENT',
                      'INCLUDED.',
                    ),
                    _termsRow(
                      'WARRANTY',
                      'INVERTER – 10 YEARS (MANUFACTURER SERVICE WARRANTY)\n'
                      'PV MODULES – 30 YEARS (MANUFACTURER WARRANTY)\n'
                      '(WARRANTY DOES NOT COVER NATURAL CALAMITIES; APPLICABLE ONLY FOR MANUFACTURER-RELATED TECHNICAL ISSUES).',
                    ),
                    _termsRow(
                      'Bank Details',
                      'Bank: HDFC Bank\n'
                      'Account Name: BAYMENT SOLAR LLP\n'
                      'A/C No: 50200112480222\n'
                      'IFSC: HDFC0003494',
                    ),
                    _termsRow(
                      'GST IN:',
                      '32AEBFS66M1ZC',
                    ),
                    _termsRow(
                      'FINISHING TIME',
                      '20 TO 30 DAYS',
                    ),
                    _termsRow(
                      'COMMISSIONING TIME',
                      '20 TO 30 DAYS',
                    ),
                    _termsRow(
                      'PRODUCTION ONGRID',
                      '3 TO 6 UNITS FROM 1000W/DAY',
                    ),
                    _termsRow(
                      'CUSTOMER CARE',
                      '7561831000',
                    ),
                    _termsRow(
                      'VALIDITY OF THE QUOTE',
                      '20 DAYS',
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'NB: 1. WARRANTY PAPERS WILL BE HANDED OVER TO THE CUSTOMER ONLY AFTER PAYMENT CLEARED.\n'
                  '2. ADDITIONAL STRUCTURE COST WILL BE APPLIED FOR OTHER THAN FLAT ROOF.',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (_) => pdf.save());
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

pw.Widget _tableHeaderCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _tableCell(String text, {bool alignRight = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Align(
      alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9,color: PdfColors.grey900),
      ),
    ),
  );
}

pw.Widget _summaryRow(
  String label,
  double amount, {
  bool bold = false,
  bool shaded = false,
  bool emphasisRed = false,
  String? note,
}) {
  final valueText = _formatINR(amount);
  return pw.Container(
    color: shaded ? PdfColors.grey200 : null,
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: emphasisRed ? PdfColors.red : PdfColors.black,
                ),
              ),
              if (note != null)
                pw.SizedBox(height: 2),
              if (note != null)
                pw.Text(
                  note,
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
            ],
          ),
        ),
        pw.Text(
          valueText,
          style: pw.TextStyle(
            fontSize: 11,
            // fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontWeight: pw.FontWeight.bold,
            color: emphasisRed ? PdfColors.red : PdfColors.black,
          ),
        ),
      ],
    ),
  );
}

String _formatINR(double amount) {
  final rounded = amount.toStringAsFixed(0);
  final chars = rounded.split('').reversed.toList();
  final buf = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i == 3 || (i > 3 && (i - 1) % 2 == 0)) {
      buf.write('');
    }
    buf.write(chars[i]);
  }
  final withCommas = buf.toString().split('').reversed.join();
  return '₹$withCommas';
}

pw.TableRow _termsRow(String title, String value) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 10,
          ),
        ),
      ),
    ],
  );
}

pw.TableRow _summaryTableRow(
  String label,
  double amount, {
  bool bold = false,
  bool shaded = false,
  bool emphasisRed = false,
  bool isSubsidy = false,
  bool isHeaderRow = false,
}) {
  final isAmountRow = !isHeaderRow;
  final valueText = isAmountRow ? _formatINR(amount) : '';
  return pw.TableRow(
    decoration:
        shaded ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: bold || isHeaderRow
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            color: emphasisRed
                ? PdfColors.green
                :PdfColors.black,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Align(
          alignment:
               pw.Alignment.center,
          child: pw.Text(
            valueText,
            style: pw.TextStyle(
              fontSize: 13,
              // fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontWeight:  pw.FontWeight.bold,
              color: emphasisRed
                  ? PdfColors.green
                  : PdfColors.black,
            ),
          ),
        ),
      ),
    ],
  );
}
