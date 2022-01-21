package com.alpian.alp_pdf_viewer;

import android.content.Context;
import android.view.View;
import android.net.Uri;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.PDFView.Configurator;
import com.github.barteksc.pdfviewer.listener.*;
import com.github.barteksc.pdfviewer.util.Constants;
import com.github.barteksc.pdfviewer.util.FitPolicy;

import com.github.barteksc.pdfviewer.link.LinkHandler;

public class AlpPdfView implements PlatformView, MethodCallHandler {
    private final PDFView pdfView;
    private final MethodChannel methodChannel;
    private final LinkHandler linkHandler;

    @SuppressWarnings("unchecked")
    AlpPdfView(Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {
        pdfView = new PDFView(context, null);
        methodChannel = new MethodChannel(messenger, "plugins.alpian.com/pdfview_" + id);
        methodChannel.setMethodCallHandler(this);

        linkHandler = new AlpLinkHandler(context, pdfView, methodChannel);

        Configurator config = null;
        String filePath = (String) params.get("filePath");
        config = pdfView.fromUri(getURI(filePath));

        if (config != null) {
            config
                .enableAnnotationRendering(true)
                .linkHandler(linkHandler)
                .enableAntialiasing(false)
                .onPageChange(new OnPageChangeListener() {
                    @Override
                    public void onPageChanged(int page, int total) {
                        if ((page+1) >= total) {
                            Map<String, Object> args = new HashMap<>();
                            methodChannel.invokeMethod("onEndOfDocumentReached", args);
                        }
                    }
                })
                .onError(new OnErrorListener() {
                    @Override
                    public void onError(Throwable t) {
                        Map<String, Object> args = new HashMap<>();
                        args.put("error", t.toString());
                        methodChannel.invokeMethod("onError", args);
                    }
                })
                .load();
        }
    }

    @Override
    public View getView() {
        return pdfView;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
        result.notImplemented();
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }

    private Uri getURI(final String uri) {
        Uri parsed = Uri.parse(uri);

        if (parsed.getScheme() == null || parsed.getScheme().isEmpty()) {
            return Uri.fromFile(new File(uri));
        }
        return parsed;
    }
}