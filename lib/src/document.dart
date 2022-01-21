import 'dart:async';
import 'dart:io';

import 'package:alp_pdf_viewer/src/page.dart';
import 'package:flutter/services.dart';

class PDFDocument {
  static const MethodChannel _channel =
      MethodChannel('plugins.alpian.com/pdfview');

  late String _filePath;
  late int count;
  List<PDFPage> _pages = [];
  bool _preloaded = false;

  String get filePath => _filePath;

  static Future<PDFDocument> fromFile(File f) async {
    PDFDocument document = PDFDocument();
    document._filePath = f.path;

    return document;
  }
}
