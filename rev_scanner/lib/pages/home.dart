import 'package:flutter/material.dart';
import 'package:rev_scanner/pages/barkod_tarama.dart';
import 'package:rev_scanner/pages/belge_tarama.dart';
import 'package:rev_scanner/pages/ocr_tarama.dart';

import 'package:rev_scanner/pages/qr_tarama.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  final List<Widget> _pages = [
   
    const QrTarama(),
    const BarkodTarama(),
    const OcrTarama(),
    const BelgeTarama()
   
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      
      length: 4,
      child: Scaffold(
        
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xffA73121),
          title: const Text('Rev Scanner'),
          bottom: const TabBar(
            indicatorColor: Color(0xffffffff),
            tabs: [
              Tab(
                text: 'QR',
              ),
              Tab(
                text: 'Barkod',
              ),
              Tab(
                text: 'OCR' ,
              ),
              Tab(
                text: 'Belge' ,
              )
            ]),
        ),
        body: TabBarView(
          children: _pages,
        ),
      ) 
    );
  }
}