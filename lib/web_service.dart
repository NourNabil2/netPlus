import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewService {
  static InAppWebViewController? webController;
  static ValueNotifier<bool> isPageLoading = ValueNotifier(false);
  static ValueNotifier<bool> canGoBack = ValueNotifier(false);

  static Widget getWebViewWidget({
    required String url,
    required BuildContext context,
    PullToRefreshController? pullToRefreshController, // ✅ دعم السحب للتحديث
  }) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      pullToRefreshController: pullToRefreshController, // ✅ إضافة التحكم بالسحب للتحديث
      initialSettings: InAppWebViewSettings(
        safeBrowsingEnabled: true,
        javaScriptEnabled: true,
        useHybridComposition: true,
        supportZoom: false,
        loadWithOverviewMode: true,
        useWideViewPort: true,
        displayZoomControls: false,
        builtInZoomControls: false,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false, // ✅ تشغيل الوسائط تلقائيًا
      ),
      onWebViewCreated: (controller) async {
        webController = controller;
        isPageLoading.value = true;
      },
      onLoadStart: (controller, url) {
        developer.log("Loading started: $url");
      },
      onLoadStop: (controller, url) async {
        canGoBack.value = await controller.canGoBack();
        isPageLoading.value = false;
        developer.log("Page loaded: $url");
      },
      onProgressChanged: (controller, progress) {
        isPageLoading.value = progress < 100;
      },
      onReceivedHttpError: (controller, request, response) {
        developer.log("HTTP Error: ${response.statusCode}");
      },
      onReceivedError: (controller, request, error) {
        developer.log("Web resource error: ${error.description}");
      },
    );
  }

  static Future<void> goBack() async {
    if (webController != null && await webController!.canGoBack()) {
      await webController!.goBack();
    }
  }

  static Future<void> reloadPage() async {
    if (webController != null) {
      await webController!.reload();
    }
  }

  static void dispose() {
    isPageLoading.dispose();
    canGoBack.dispose();
    webController = null;
  }
}
