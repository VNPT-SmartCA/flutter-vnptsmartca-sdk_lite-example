// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vnpt_smartca_module/main.dart';

void main() {
  runZonedGuarded(() async {
    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    // debugPrint("error log ${error}");
  });
}

@pragma('vm:entry-point')
void VNPTSmartCAEntryponit() => bootstrapSmartCAApp();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VNPT SmartCA Lite SDK Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const MyHomePage(title: 'VNPT SmartCA Lite SDK'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel("com.vnpt.flutter/partner");
  final _customerIdController = TextEditingController(text: "");
  final _trandIdController =
      TextEditingController(text: "");
  bool _isProdEnv = false;

  @override
  void initState() {
    super.initState();
    initMethod();
  }

  initMethod() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "getAuthenticationResult") {
        debugPrint("getAuthenticationResult");
        if (call.arguments is Map && call.arguments["status"] == 0) {
          // Xử lý khi thành công
          final data = jsonDecode(call.arguments["data"]);
          showDialogMessage(context, "Serial Cert: ${data["serial"]}");
        } else {
          // Xử lý khi thất bại
          showDialogMessage(
              context, call.arguments["data"] ?? call.arguments["statusDesc"]);
        }
      } else if (call.method == "getMainInfoResult") {
        debugPrint("getMainInfoResult");
      } else if (call.method == "getWaitingTransactionResult") {
        debugPrint("getWaitingTransactionResult");
        if (call.arguments is Map && call.arguments["status"] == 0) {
          // Xử lý khi thành công
          showDialogMessage(context, "Ký số thành công");
        } else {
          // Xử lý khi thất bại
          showDialogMessage(
              context, "Giao dịch thất bại: ${call.arguments["statusDesc"]}");
        }
      } else if (call.method == "signOutResult") {
        debugPrint("signOut success");
        showDialogMessage(context, "Đăng xuất thành công");
      } else if (call.method == "createAccountResult") {
        debugPrint("createAccountResult");
      }
    });
  }

  showDialogMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thông báo'),
        content: Text(message),
      ),
    );
  }

  Future<void> getAuthentication() async {
    final customerId = _customerIdController.text.trim();
    if (customerId.isEmpty) {
      showDialogMessage(context, "Vui lòng nhập Customer ID");
      return;
    }
    final result = await platform.invokeMethod('getAuthentication', customerId);
    showDialogMessage(context, result);
  }

  Future<void> getWaitingTransaction() async {
    final tranId = _trandIdController.text.trim();
    if (tranId.isEmpty) {
      showDialogMessage(context, "Vui lòng nhập TranID");
      return;
    }
    await platform.invokeMethod('getWaitingTransaction', tranId);
  }

  Future<void> toMainPage() async {
    await platform.invokeMethod('getMainInfo');
  }

//
  Future<void> createAccount() async {
    await platform.invokeMethod('createAccount');
  }

  Future<void> switchEnvironment(bool toProd) async {
    final env = toProd ? 'PROD' : 'DEMO';
    try {
      await platform.invokeMethod('switchEnvironment', env);
      setState(() {
        _isProdEnv = toProd;
      });
      showDialogMessage(context, 'Đã chuyển môi trường sang $env');
    } catch (e) {
      showDialogMessage(context, 'Chuyển môi trường thất bại: $e');
    }
  }

  Future<void> signOut() async {
    await platform.invokeMethod('signOut');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Môi trường hiện tại: ${_isProdEnv ? 'PROD' : 'DEMO'}'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => switchEnvironment(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProdEnv ? Colors.grey : Colors.blue,
                  ),
                  child: Text('DEMO'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => switchEnvironment(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProdEnv ? Colors.blue : Colors.grey,
                  ),
                  child: Text('PROD'),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(
                labelText: "Số CCCD",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: getAuthentication, child: Text("getAuthentication")),
            SizedBox(height: 20),
            TextField(
              controller: _trandIdController,
              decoration: InputDecoration(
                labelText: "Mã giao dịch (TranID)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: getWaitingTransaction,
                child: Text("getWaitingTransaction")),
            // SizedBox(height: 20),
            // ElevatedButton(onPressed: toMainPage, child: Text("getMainPage")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signOut, child: Text("sign Out")),
            // ElevatedButton(onPressed: createAccount, child: Text("Create Acc")),
          ],
        ),
      ),
    );
  }
}
