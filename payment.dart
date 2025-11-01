import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PayAmount extends StatefulWidget {
  final String title;
  final String pid;
  final String token;

  const PayAmount({
    super.key,
    required this.title,
    required this.pid,
    required this.token,
  });

  @override
  State<PayAmount> createState() => _PayAmountState();
}

class _PayAmountState extends State<PayAmount> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Listen for Razorpay callbacks
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Automatically open Razorpay checkout when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openCheckout();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // 🔹 Razorpay checkout configuration
  void openCheckout() {
    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe', // your Razorpay test key
      'amount': int.parse(widget.token) * 100, // Razorpay expects paise
      'name': 'Redeem Tokens',
      'description': 'Payment for reward: ${widget.title}',
      'prefill': {'contact': '9747360170', 'email': 'test@gmail.com'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      Fluttertoast.showToast(msg: "Error opening payment: $e");
    }
  }

  // 🔹 On Payment Success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "Payment Successful!");
    await _sendData(response.paymentId ?? "");
    Navigator.pop(context, true);
  }

  // 🔹 On Payment Error
  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
    Navigator.pop(context, false);
  }

  // 🔹 On External Wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  // 🔹 Send data to Django backend
  Future<void> _sendData(String paymentId) async {
    SharedPreferences sh = await SharedPreferences.getInstance();

    String url = sh.getString('url') ?? "";
    String? lid = sh.getString('lid');
    double? latitude = sh.getDouble('latitude');
    double? longitude = sh.getDouble('longitude');
    String? title = sh.getString('title');
    String? proofPath = sh.getString('proof_path'); // optional proof image

    if (url.isEmpty) {
      Fluttertoast.showToast(msg: "❌ Server URL not found in SharedPreferences");
      return;
    }

    final uri = Uri.parse('$url/makepayment/');
    var request = http.MultipartRequest('POST', uri);

    // 🔸 Required fields
    request.fields['lid'] = lid ?? '';
    request.fields['payment_id'] = paymentId;
    request.fields['latitude'] = latitude?.toString() ?? '';
    request.fields['longitude'] = longitude?.toString() ?? '';
    request.fields['title'] = title ?? widget.title;
    request.fields['token'] = widget.token;

    // 🔸 Optional proof file (if stored earlier)
    if (proofPath != null && proofPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('photo', proofPath));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg:
          "✅ Payment saved successfully!\n${data['added_points']} points added.",
          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg:
          "⚠️ Server error: ${data['message'] ?? 'Unknown error'}",
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❌ Network Error: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text("Processing Payment...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
