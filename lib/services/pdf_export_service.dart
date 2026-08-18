import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../services/hive_service.dart';

class PdfExportService {
  static Future<File> generateJournalPdf() async {
    final pdf = pw.Document();
    final journals = HiveService.getAllJournals();
    final moods = HiveService.getAllMoods();

    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // ── Header ──
          pw.Header(
            level: 0,
            child: pw.Text('HealMind Journal Export', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Generated: $dateStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 20),

          // ── Mood Summary ──
          pw.Header(level: 1, text: 'Mood Summary'),
          if (moods.isNotEmpty) ...[
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Mood', 'Note'],
              data: moods.map((m) => [
                '${m.date.day}/${m.date.month}/${m.date.year}',
                '${m.mood.emoji} ${m.mood.label}',
                m.note ?? '-',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
              border: pw.TableBorder.all(color: PdfColors.grey300),
            ),
          ] else ...[
            pw.Text('No mood entries yet.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ],
          pw.SizedBox(height: 20),

          // ── Journal Entries ──
          pw.Header(level: 1, text: 'Journal Entries'),
          if (journals.isNotEmpty) ...[
            for (final j in journals) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${j.title}  —  ${j.date.day}/${j.date.month}/${j.date.year}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(j.content, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
            ],
          ] else ...[
            pw.Text('No journal entries yet.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/healmind_journal_export.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> shareJournalPdf() async {
    final file = await generateJournalPdf();
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'HealMind Journal Export'));
  }
}