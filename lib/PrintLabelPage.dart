import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class PrintLabelPage extends StatelessWidget {
  final Map<String, dynamic> shipment;

  const PrintLabelPage({super.key, required this.shipment});

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    // Load company logo (make sure it's in assets/images/logo.png)
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero, // no margin to allow full background color
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white, // background color light blue
            child: pw.Center(
              child: pw.Container(
                width: 350, // <-- controls the facture width
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.white, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // ---------------- HEADER ----------------
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(logo, width: 80),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("Yan Ship S.A.R.L",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text("Casablanca, Maroc",
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text("Tél: +212 600 000 000",
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text("Email: contact@yanship.ma",
                                style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 16),

                    // ---------------- TITLE ----------------
                    pw.Center(
                      child: pw.Text(
                        "FACTURE",
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                    ),

                    pw.SizedBox(height: 16),

                    // ---------------- BARCODE ----------------
                    pw.Center(
                      child: pw.BarcodeWidget(
                        data: shipment['trackingNumber'] ?? '',
                        barcode: pw.Barcode.code128(),
                        width: 180,
                        height: 50,
                      ),
                    ),

                    pw.SizedBox(height: 16),

                    // ---------------- INFO TABLE ----------------
                    pw.Table(
                      border: pw.TableBorder.all(
                          width: 0.8, color: PdfColors.black),
                      children: [
                        _tableRow("Tracking Number", shipment['trackingNumber']),
                        _tableRow("Receiver", shipment['receiver']),
                        _tableRow("City", shipment['city']),
                        _tableRow("Address", shipment['address']),
                        _tableRow("Price", "${shipment['price']} MAD"),
                        _tableRow("Sender", shipment['sender']),
                        _tableRow("Date", "${DateTime.now().toLocal()}"),
                      ],
                    ),

                    pw.SizedBox(height: 24),

                    // ---------------- FOOTER ----------------
                    pw.Divider(),
                    pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        "Merci pour votre confiance - Yan Ship S.A.R.L",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return pdf;
  }

  // Helper for table rows
  pw.TableRow _tableRow(String label, String? value) {
    return pw.TableRow(children: [
      pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold))),
      pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value ?? '', style: const pw.TextStyle(fontSize: 10))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Facture"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdf = await _generatePdf();
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdf.save(),
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async => (await _generatePdf()).save(),
      ),
    );
  }
}
