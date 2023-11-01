import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rev_scanner/pages/ocr_url_tarama.dart';

class OcrTarama extends StatefulWidget {
  const OcrTarama({super.key});

  @override
  State<OcrTarama> createState() => _OcrTaramaState();
}

class _OcrTaramaState extends State<OcrTarama> {
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

  void chooseFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _ocr(pickedFile.path);
    }
  }

  void chooseFromCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _ocr(pickedFile.path);
    }
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
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
                                    await FlutterTesseractOcr
                                        .getTessdataPath());
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
                                  String dir = await FlutterTesseractOcr
                                      .getTessdataPath();

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Color(0xffA73121))),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Tarama Tipi Seçiniz'),
                                content: SizedBox(
                                  height: 150,
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                    style: const ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Color(
                                                                    0xffA73121))),
                                                    onPressed: () async {
                                                      chooseFromGallery();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const SizedBox(
                                                      width: 90,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .image_search,
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text('Galeri'),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                  height: 10,
                                                ),
                                                ElevatedButton(
                                                    style: const ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Color(
                                                                    0xffA73121))),
                                                    onPressed: () async {
                                                      chooseFromCamera();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const SizedBox(
                                                      width: 90,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .camera_alt_outlined,
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text('Kamera'),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                    style: const ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Color(
                                                                    0xffA73121))),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const OcrUrlTarama()));
                                                    },
                                                    child: const SizedBox(
                                                      width: 90,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              Icons.link,
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text('URL'),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Kapat'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const SizedBox(
                          width: 200,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.document_scanner_outlined,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('Görsel Tarat'),
                              ],
                            ),
                          ),
                        )),
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
                ))
              ],
            ),
          ),
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
    );
  }
}
