import 'dart:async';
import 'dart:io';

import 'package:alp_pdf_viewer/alp_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pdf;

  void _loadDocument(String filename) async {
    final file = await _getFileFromAssets('$filename.pdf');
    setState(() {
      _pdf = file.path;
    });
  }

  Future<File> _getFileFromAssets(String filename) async {
    final byteData = await rootBundle.load('assets/$filename');

    final file = File('${(await getTemporaryDirectory()).path}/$filename');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Widget _item(String label, String asset) {
    return ListTile(
      title: Text(label),
      onTap: () {
        _loadDocument(asset);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('AlpPdfViewer Example'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            _item('Single page with links', 'single-page'),
            _item('Multi page with links', 'multi-page'),
            _item('Long file multiple pages', 'sample'),
          ],
        ),
      ),
      body: _pdf == null
          ? SizedBox.shrink()
          : AlpPdfViewer(
              filePath: _pdf,
              endOfDocumentSpacing: 200,
              onLinkHandler: (url) => print(url),
              onEndOfDocument: () => print('End of document'),
            ),
    ));
  }
}
