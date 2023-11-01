import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rev_scanner/pages/qr_olustur.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter_qr_scan/flutter_qr_scan.dart';

import 'package:image_picker/image_picker.dart';

class QrTarama extends StatefulWidget {
  const QrTarama({super.key});

  @override
  State<QrTarama> createState() => _QrTaramaState();
}

class _QrTaramaState extends State<QrTarama> {
  String _scanBarcode = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> openUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ffffff', 'İptal Et', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2E8C6),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xffDAD4B5)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text(
                                'Sonuç',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (_scanBarcode.startsWith('http://') ||
                                      _scanBarcode.startsWith('https://')) {
                                    final tarama =
                                        Uri.parse(_scanBarcode.toString());
                                    await launchUrl(tarama);
                                  } else {}
                                },
                                child: _scanBarcode.startsWith('http://') ||
                                        _scanBarcode.startsWith('https/')
                                    ? SizedBox(
                                        width: 350,
                                        child: Text(
                                          _scanBarcode,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color(0xffA73121),
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          softWrap: true,
                                        ),
                                      )
                                    : SizedBox(
                                        width: 350,
                                        child: SelectableText(
                                          _scanBarcode,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                height: 70,
                                
                                child: Row(
                                 
                                  children: [
                                    ElevatedButton(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Color(0xffA73121))),
                                        onPressed: () async {
                                          var image = await ImagePicker()
                                              .getImage(
                                                  source: ImageSource.gallery);
                                          if (image == null) return;
                                          final rest =
                                              await FlutterQrReader.imgScan(
                                                  File(image.path));
                              
                                          setState(() {
                                            _scanBarcode = rest!;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const SizedBox(
                                          width: 90,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.image_search,
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
                                    ),
                                    ElevatedButton(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Color(0xffA73121))),
                                        onPressed: () => scanQR() ,
                                        child: const SizedBox(
                                          width: 90,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
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
                                        )),
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
                        width: 90,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text('QR Tarat'),
                            ],
                          ),
                        ),
                      )),
                  ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Color(0xffA73121))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QrOlustur()));
                      },
                      child: const SizedBox(
                        width: 90,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.qr_code,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text('QR Oluştur'),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
