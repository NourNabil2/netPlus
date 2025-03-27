import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'web_service.dart';

class WebPage extends StatefulWidget {

  final String identifierForVendor;

  const WebPage({super.key, required this.identifierForVendor});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  String? url;
  bool isLoading = true;
  bool hasError = false;
  bool isConnected = true;
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged.map((event) => event.first);

    _connectivityStream.listen(_updateConnectionStatus);

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.yellow,
        backgroundColor: Colors.black,
      ),
      onRefresh: () async {
        await _refreshPage();
      },
    );

    loadWebPage();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      isConnected = result != ConnectivityResult.none;
    });

    if (isConnected && hasError) {
      _refreshPage();
    }
  }

  Future<void> loadWebPage() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("لا يوجد اتصال بالإنترنت");
      }

      setState(() {
        url = 'https://netplus.app/access-ipa.php?identifierForVendor=${widget.identifierForVendor}';
      });
    } catch (e) {
      log("Error loading web page: $e");
      setState(() {
        hasError = true;
      });
      Fluttertoast.showToast(msg: "فشل تحميل الصفحة: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPage() async {
    log("Refreshing WebView...");
    await loadWebPage();
    if (InAppWebViewService.webController != null && isConnected) {
      await InAppWebViewService.reloadPage();
    }
    pullToRefreshController?.endRefreshing();
  }

  Future<bool> _handleBackPress() async {
    // التحقق مما إذا كان يمكن الرجوع داخل WebView
    if (url != null &&
        await InAppWebViewService.webController!.canGoBack()) {
      await InAppWebViewService.goBack();
      return false;
    }

    // إذا كان في آخر صفحة، يظهر تنبيه تأكيد الخروج
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الخروج"),
        content: const Text("هل أنت متأكد أنك تريد الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // لا يخرج
            child: const Text("لا"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // يخرج
            child: const Text("نعم"),
          ),
        ],
      ),
    ) ??
        false;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: isLoading || !isConnected
              ? const Center(
            child: CircularProgressIndicator(color: Colors.yellow),
          )
              : InAppWebViewService.getWebViewWidget(
            url: url!,
            context: context,
            pullToRefreshController: pullToRefreshController, // ✅ تم تمريره الآن
          ),
        ),
      ),
    );
  }
}
