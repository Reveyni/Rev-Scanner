import 'package:flutter/material.dart';
import 'package:rev_scanner/pages/home.dart';

void main() {
  runApp(const RevScanner());
}

class RevScanner extends StatelessWidget {
  const RevScanner({super.key});

  @override
  Widget build(BuildContext context) {
     return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}