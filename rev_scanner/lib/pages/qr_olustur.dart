import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class QrOlustur extends StatefulWidget {
  const QrOlustur({super.key});

  @override
  State<QrOlustur> createState() => _QrOlusturState();
}

Future<Uint8List> _captureWithRepaintBoundary(GlobalKey key) async {
  RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  if (byteData != null) {
    Uint8List uint8List = byteData.buffer.asUint8List();
    return uint8List;
  } else {
    
    return Uint8List(0); 
  }
}

class _QrOlusturState extends State<QrOlustur> {
  final TextEditingController _textEditingController = TextEditingController();
  String _girilenVeri = '';
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2E8C6),
      appBar: AppBar(
        backgroundColor: const Color(0xffA73121),
        title: const Text('QR Kod Oluştur'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        
                        border: OutlineInputBorder(
                          
                          borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        labelText: 'Veri Giriniz',
                        
                      ),
                      onChanged: (text) {
                        setState(() {
                          _girilenVeri = text; 
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RepaintBoundary(
                    key: globalKey,
                    child:
                     QrImageView(
                      data: _girilenVeri,
                      version: QrVersions.auto,
                      size: 250.0,
                      
                      backgroundColor: Colors.white,
                    ), 
                  )
                  
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   ElevatedButton(
                    style: 
                    const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Color(0xffA73121))
                    ),
                    onPressed: (
                    ) async {
                
                      final img = await _captureWithRepaintBoundary(globalKey);
           
                      var status = await Permission.storage.status;
                      if (!status.isGranted) {
                        await Permission.storage.request();
                      }
      
                      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(img));
                      if (result != null && result['isSuccess']) {
                        showDialog(
                          context: context, 
                          builder: (BuildContext context) =>
                             AlertDialog(
                            title: const Text('Başarılı'),
                            content:  const SingleChildScrollView(
                              child: ListBody(
                                
                                children: <Widget>[
                                  Text('QR Kodunuz Başarılı Bir Şekilde İndirildi.'),
                                  Text('Lütfen Galerinizi Kontrol Ediniz.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Tamam'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                         );
                       
                         
                      } else {
                        showDialog(
                          context: context, 
                          builder: (BuildContext context) =>
                             AlertDialog(
                            title: const Text('HATA!!'),
                            content:  const SingleChildScrollView(
                              child: ListBody(
                                
                                children: <Widget>[
                                  Text('QR Kodunuz İndirilirken Bir Hata Oluştu!'),
                                  Text('Lütfen Tekrar Deneyiniz.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Tamam'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                         );
                      }
                    },
                    child: const SizedBox(
                      width: 120,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.download,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('QR Kodu İndir'),
                          ],
                        ),
                      ),
                    ),
              ),
                ],
              )
             
            ],
          ),
        ),
      ),
    );
  }
}