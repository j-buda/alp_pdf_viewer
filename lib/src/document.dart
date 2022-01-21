import 'dart:async';
import 'dart:io';

import 'package:alp_pdf_viewer/src/page.dart';
import 'package:flutter/services.dart';

class PDFDocument {
  static const MethodChannel _channel =
      MethodChannel('plugins.alpian.com/pdfdocument');

  late String _filePath;
  late int count;
  List<PDFPage> _pages = [];
  bool _preloaded = false;

  String get filePath => _filePath;

  static Future<PDFDocument> fromFile(File f) async {
    PDFDocument document = PDFDocument();
    document._filePath = f.path;

    try {
      var pageCount =
          await _channel.invokeMethod('pageCount', {'filePath': f.path});
      document.count = int.parse(pageCount);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }

    return document;
  }
}
