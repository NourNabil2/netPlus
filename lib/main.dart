import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // فرض الوضع الأفقي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

// شاشة التحميل
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String macAddress = 'Unknown MAC';
  String androidId = 'Unknown ID';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {

    String? id = await DeviceInfo.getIOSId();

    setState(() {

      androidId = id ?? 'Unknown ID';
    });

    // الانتقال إلى الصفحة الرئيسية بعد 2 ثانية
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebPage(identifierForVendor: id!),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.yellow),
            const SizedBox(height: 20),
            const Text(
              "جارِ تحميل...",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


class DeviceInfo {
  /// استرجاع **identifierForVendor** للـ iOS فقط
  static Future<String?> getIOSId() async {
    if (Platform.isIOS) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        log('iOS identifierForVendor: ${iosInfo.identifierForVendor}');
        return iosInfo.identifierForVendor; // iOS Vendor ID
      } catch (e) {
        log("Failed to get iOS identifier: $e");
        return null;
      }
    }
    return null;
  }

}