package com.alpian.alp_pdf_viewer;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;

public class AlpPdfViewerPlugin implements FlutterPlugin {
  /**
   * Plugin registration.
   */
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    binding
            .getPlatformViewRegistry()
            .registerViewFactory("plugins.alpian.com/pdfview", new AlpPdfViewFactory(binding.getBinaryMessenger()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
