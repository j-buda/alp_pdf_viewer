library alp_pdf_viewer;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

export 'src/document.dart' show PDFDocument;
export 'src/page.dart' show PDFPage;

typedef PDFViewCreatedCallback = void Function(PDFViewController controller);
typedef EndOfDocumentCallback = void Function();
typedef LinkHandlerCallback = void Function(String? url);
typedef ErrorCallback = void Function(dynamic error);

class AlpPdfViewer extends StatefulWidget {
  final String? filePath;
  final int endOfDocumentSpacing;
  final EndOfDocumentCallback? onEndOfDocument;
  final LinkHandlerCallback? onLinkHandler;
  final ErrorCallback? onError;

  const AlpPdfViewer({
    Key? key,
    this.filePath,
    this.endOfDocumentSpacing = 1,
    this.onEndOfDocument,
    this.onLinkHandler,
    this.onError,
  })  : assert(filePath != null),
        super(key: key);

  @override
  _AlpPdfViewerState createState() => _AlpPdfViewerState();
}

class _AlpPdfViewerState extends State<AlpPdfViewer> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.alpian.com/pdfview',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.alpian.com/pdfview',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the pdfview_flutter plugin');
  }

  void _onPlatformViewCreated(int id) {
    final PDFViewController controller = PDFViewController._(id, widget);
    _controller.complete(controller);
  }
}

class PDFViewController {
  final MethodChannel _channel;
  late _AlpPdfViewerSettings _settings;
  final AlpPdfViewer _widget;

  PDFViewController._(
    int id,
    this._widget,
  ) : _channel = MethodChannel('plugins.alpian.com/pdfview_$id') {
    _settings = _AlpPdfViewerSettings.fromWidget(_widget);
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onEndOfDocumentReached':
        if (_widget.onEndOfDocument != null) {
          _widget.onEndOfDocument!();
        }

        return null;
      case 'onLinkHandler':
        if (_widget.onLinkHandler != null) {
          _widget.onLinkHandler!(call.arguments);
        }

        return null;
      case 'onError':
        if (_widget.onError != null) {
          _widget.onError!(call.arguments['error']);
        }

        return null;
    }

    throw MissingPluginException(
        '${call.method} was invoked but has no handler');
  }
}

class _CreationParams {
  final String? filePath;
  final _AlpPdfViewerSettings? settings;

  _CreationParams({
    this.filePath,
    this.settings,
  });

  static _CreationParams fromWidget(AlpPdfViewer widget) {
    return _CreationParams(
      filePath: widget.filePath,
      settings: _AlpPdfViewerSettings.fromWidget(widget),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> params = {
      'filePath': filePath,
    };

    params.addAll(settings!.toMap());

    return params;
  }
}

class _AlpPdfViewerSettings {
  final int? endOfDocumentSpacing;

  _AlpPdfViewerSettings({this.endOfDocumentSpacing});

  static _AlpPdfViewerSettings fromWidget(AlpPdfViewer widget) {
    return _AlpPdfViewerSettings(
      endOfDocumentSpacing: widget.endOfDocumentSpacing,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'endOfDocumentSpacing': endOfDocumentSpacing,
    };
  }
}
