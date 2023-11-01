import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:path_provider/path_provider.dart';

class OcrUrlTarama extends StatefulWidget {
  const OcrUrlTarama({super.key});

  @override
  State<OcrUrlTarama> createState() => _OcrUrlTaramaState();
}

class _OcrUrlTaramaState extends State<OcrUrlTarama> {
  String _ocrText = '';

  var langList = ["Türkçe", "İngilizce"];
  var selectList = ["tur", "eng"];
  String path = "";
  bool bload = false;

  bool bDownloadtessFile = false;
  var urlEditController = TextEditingController();

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _ocr(url) async {
    if (selectList.isEmpty) {
      return;
    }
    path = url;
    if (kIsWeb == false &&
        (url.indexOf("http://") == 0 || url.indexOf("https://") == 0)) {
      Directory tempDir = await getTemporaryDirectory();
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      String dir = tempDir.path;

      File file = File('$dir/test.jpg');
      await file.writeAsBytes(bytes);
      url = file.path;
    }
    var langs = selectList.join("+");

    bload = true;
    setState(() {});

    _ocrText =
        await FlutterTesseractOcr.extractText(url, language: langs, args: {
      "preserve_interword_spaces": "1",
    });

    bload = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2E8C6),
      appBar: AppBar(
        backgroundColor: const Color(0xffA73121),
        title: const Text('Bağlantı Adresi İle Tarama'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  child: Text('Dil Seçiniz'),
                ),
                ...langList.map((e) {
                  return Row(children: [
                    Checkbox(
                        activeColor: const Color(0xffa73121),
                        value: selectList.contains(e),
                        onChanged: (v) async {
                          if (kIsWeb == false) {
                            Directory dir = Directory(
                                await FlutterTesseractOcr.getTessdataPath());
                            if (!dir.existsSync()) {
                              dir.create();
                            }
                            bool isInstalled = false;
                            dir.listSync().forEach((element) {
                              String name = element.path.split('/').last;

                              isInstalled |= name == '$e.traineddata';
                            });
                            if (!isInstalled) {
                              bDownloadtessFile = true;
                              setState(() {});
                              HttpClient httpClient = HttpClient();
                              HttpClientRequest request =
                                  await httpClient.getUrl(Uri.parse(
                                      'https://github.com/tesseract-ocr/tessdata/raw/main/$e.traineddata'));
                              HttpClientResponse response =
                                  await request.close();
                              Uint8List bytes =
                                  await consolidateHttpClientResponseBytes(
                                      response);
                              String dir =
                                  await FlutterTesseractOcr.getTessdataPath();

                              File file = File('$dir/$e.traineddata');
                              await file.writeAsBytes(bytes);
                              bDownloadtessFile = false;
                              setState(() {});
                            }
                          }
                          if (!selectList.contains(e)) {
                            selectList.add(e);
                          } else {
                            selectList.remove(e);
                          }
                          setState(() {});
                        }),
                    Text(e)
                  ]);
                }).toList(),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Resim Bağlantısı Giriniz',
                    ),
                    controller: urlEditController,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Color(0xffA73121))),
                  onPressed: () {
                    _ocr(urlEditController.text);
                  },
                  child: const SizedBox(
                    width: 50,
                    child: Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.document_scanner_outlined,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Tara'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
            Expanded(
                child: ListView(
              children: [
                path.isEmpty
                    ? Container()
                    : path.contains("http")
                        ? Image.network(path)
                        : Image.file(File(path)),
                const SizedBox(
                  height: 10,
                ),
                bload
                    ? const Column(children: [CircularProgressIndicator()])
                    : SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            Container(
                              width: 300,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xffDAD4B5)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SelectableText(
                                      _ocrText,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            )),
            Container(
              color: Colors.black26,
              child: bDownloadtessFile
                  ? const Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text('Dil Paketleri Yükleniyor Lütfen Bekleyiniz...')
                      ],
                    ))
                  : const SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}
