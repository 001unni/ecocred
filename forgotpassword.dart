import 'dart:convert';
import 'package:eco_frnd/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const forgotpassword());
}

class forgotpassword extends StatelessWidget {
  const forgotpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Forgot Password',
      home: forgot_password(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class forgot_password extends StatefulWidget {
  const forgot_password({super.key});

  @override
  State<forgot_password> createState() => _forgot_passwordState();
}

class _forgot_passwordState extends State<forgot_password> {
  final TextEditingController email = TextEditingController();

  Future<void> sendData() async {
    String femail = email.text.trim();
    if (femail.isEmpty || !femail.contains('@')) {
      Fluttertoast.showToast(msg: 'Enter a valid email');
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    final urls = Uri.parse('$url/myapp/android_forget_password_post/');

    try {
      final response = await http.post(urls, body: {
        'email': femail,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String status = data['status'];

        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Password sent to email');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EcoLoginPage()),
          );
        } else {
          Fluttertoast.showToast(msg: 'Email not found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your registered email address',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendData,
                child: const Text('Send Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
