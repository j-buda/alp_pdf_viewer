package com.alpian.alp_pdf_viewer;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import android.graphics.pdf.PdfRenderer;
import android.os.ParcelFileDescriptor;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import android.os.HandlerThread;
import android.os.Process;
import android.os.Handler;

public class AlpPdfViewerPlugin implements FlutterPlugin, MethodCallHandler {
  private HandlerThread handlerThread;
  private Handler backgroundHandler;
  private final Object pluginLocker = new Object();
  private static String channelName = "plugins.alpian.com/pdfdocument";

  /**
   * Plugin registration.
   */
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    binding
            .getPlatformViewRegistry()
            .registerViewFactory("plugins.alpian.com/pdfview", new AlpPdfViewFactory(binding.getBinaryMessenger()));

    final MethodChannel channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), channelName);

    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), channelName);
    channel.setMethodCallHandler(new AlpPdfViewerPlugin());
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    synchronized (pluginLocker) {
      if (backgroundHandler == null) {
        handlerThread = new HandlerThread("AlpFlutterPdfViewer", Process.THREAD_PRIORITY_BACKGROUND);
        handlerThread.start();
        backgroundHandler = new Handler(handlerThread.getLooper());
      }
    }
    final Handler mainThreadHandler = new Handler();
    backgroundHandler.post(//
      new Runnable() {
        @Override
        public void run() {
          switch (call.method) {
            case "pageCount":
              final String numResult = getPageCount((String) call.argument("filePath"));
              mainThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                  result.success(numResult);
                }
              });
              break;
            default:
              result.notImplemented();
              break;
          }
        }
      }
    );
  }

  private String getPageCount(String filePath) {
    File pdf = new File(filePath);
    try {
      PdfRenderer renderer = new PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY));
      final int pageCount = renderer.getPageCount();
      return String.format("%d", pageCount);
    } catch (Exception ex) {
      ex.printStackTrace();
    }
    return null;
  }
}
