import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class PDFPage extends StatefulWidget {
  final String imgPath;
  final int num;
  final double? bottomPadding;

  PDFPage(this.imgPath, this.num, this.bottomPadding);

  @override
  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  late ImageProvider provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repaint();
  }

  @override
  void didUpdateWidget(PDFPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imgPath != widget.imgPath) {
      _repaint();
    }
  }

  _repaint() {
    provider = FileImage(File(widget.imgPath));
    final resolver = provider.resolve(createLocalImageConfiguration(context));
    resolver.addListener(ImageStreamListener((imgInfo, alreadyPainted) {
      if (!alreadyPainted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: null,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding ?? 0),
        child: Image(image: provider),
      ),
    );
  }
}
