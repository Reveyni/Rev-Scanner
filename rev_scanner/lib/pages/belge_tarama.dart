import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class BelgeTarama extends StatefulWidget {
  const BelgeTarama({Key? key}) : super(key: key);

  @override
  State<BelgeTarama> createState() => _BelgeTaramaState();
}

class _BelgeTaramaState extends State<BelgeTarama> {
  List<String> _pictures = [];
  String _pdfPath = '';
  bool _processing = false;
  final TextEditingController _fileNameController = TextEditingController();

  Future<void> fotografCek() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted) return;
      setState(() {
        _pictures = pictures;
      });
    } catch (exception) {
      // Handle exception here
    }
  }

  Future<void> processAndSaveAsPDF() async {
    setState(() {
      _processing = true;
    });

    final fileName = _fileNameController.text.trim();
    final outputDir = await getExternalStorageDirectory();
    final pdfFilePath = '${outputDir?.path}/$fileName.pdf';

    // Create a PDF document
    final pdf = pw.Document();

    // Process and add each image to the PDF
    for (var picturePath in _pictures) {
      final image = decodeImage(File(picturePath).readAsBytesSync());
      if (image != null) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Image(
                pw.MemoryImage(Uint8List.fromList(encodePng(image))),
              );
            },
          ),
        );
      }
    }

    // Save the PDF to a file in the main isolate
    final pdfFile = File(pdfFilePath);
    await pdfFile.writeAsBytes(await pdf.save());

    setState(() {
      _pdfPath = pdfFilePath;
      _processing = false;
    });

    // Optionally open the PDF file
    if (_pdfPath.isNotEmpty) {
      await OpenFile.open(_pdfPath);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: fotografCek,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                child: const SizedBox(
                      width: 140,
                      child: Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Kamera'),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
           
            Container(
              margin: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20), 
              child: TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Dosya İsmi',
                  
                ),
                
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 0),
              child: ElevatedButton(
                onPressed: processAndSaveAsPDF,
               style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                child: const SizedBox(
                      width: 140,
                      child: Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('PDF Olarak Kaydet'),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            if (_processing)
              const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Text("Kaydediliyor..."),
                  ],
                ),
              ),
            if (_pdfPath.isNotEmpty)
              Expanded(
                child: PDFView(
                  filePath: _pdfPath,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
