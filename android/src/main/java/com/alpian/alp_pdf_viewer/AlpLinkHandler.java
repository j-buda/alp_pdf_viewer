package com.alpian.alp_pdf_viewer;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.link.LinkHandler;
import com.github.barteksc.pdfviewer.model.LinkTapEvent;

import io.flutter.plugin.common.MethodChannel;

public class AlpLinkHandler implements LinkHandler {
    PDFView pdfView;
    Context context;
    MethodChannel methodChannel;

    public AlpLinkHandler(Context context, PDFView pdfView, MethodChannel methodChannel) {
        this.context = context;
        this.pdfView = pdfView;
        this.methodChannel = methodChannel;
    }

    @Override
    public void handleLinkEvent(LinkTapEvent event) {
        String uri = event.getLink().getUri();
        Integer page = event.getLink().getDestPageIdx();
        if (uri != null && !uri.isEmpty()) {
            handleUri(uri);
        }
    }

    private void handleUri(String uri) {
        this.onLinkHandler(uri);
    }

    // Notify Flutter of Link request
    private void onLinkHandler(String uri) {
        this.methodChannel.invokeMethod("onLinkHandler", uri);
    }
}
