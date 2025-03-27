import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape mode
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
      home: SplashScreen(), // أول شاشة بتظهر
    );
  }
}

// شاشة الانتظار (Splash Screen)
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String macAddress = '';
  String androidId = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    String? mac = await DeviceInfo.getMacAddress();
    String? id = await DeviceInfo.getAndroidId();

    setState(() {
      macAddress = mac ?? 'Unknown MAC';
      androidId = id ?? 'Unknown ID';
    });

    // بعد 2 ثانية، ينتقل إلى الصفحة الرئيسية
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebPage(macAddress: macAddress, androidId: androidId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // لون الخلفية
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.yellow), // مؤشر التحميل
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

// كلاس استرجاع بيانات الجهاز
class DeviceInfo {
  static const platform = MethodChannel('com.example.device_info');

  static Future<String?> getAndroidId() async {
    try {
      final String? androidId = await platform.invokeMethod<String>('getAndroidId');
      log('ANDROID_ID: $androidId');
      return androidId;
    } on PlatformException catch (e) {
      log("Failed to get Android ID: ${e.message}", error: e);
      return null;
    }
  }

  static Future<String?> getMacAddress() async {
    try {
      final String? macAddress = await platform.invokeMethod<String>('getMacAddress');
      log('MAC_ADDRESS: $macAddress');
      return macAddress;
    } on PlatformException catch (e) {
      log("Failed to get MAC address: ${e.message}", error: e);
      return null;
    }
  }
}
