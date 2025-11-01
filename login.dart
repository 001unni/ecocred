import 'dart:convert';

import 'package:eco_frnd/homepage.dart';
import 'package:eco_frnd/signup.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'forgotpassword.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const EcoLoginPage(),
    );
  }
}

class EcoLoginPage extends StatefulWidget {
  const EcoLoginPage({super.key});

  @override
  State<EcoLoginPage> createState() => _EcoLoginPageState();
}

class _EcoLoginPageState extends State<EcoLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Eco Icon
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green[100],
                child: Icon(
                  Icons.eco,
                  color: Colors.green[800],
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Eco Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 30),

              // Email field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    sendData();
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Register link
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>user_register()));
                },
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),
              SizedBox(height: 15,),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>forgot_password()));
                },
                child: Text(
                  "Forget your password? Click",
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendData() async {
    String uname = emailController.text;
    String pass = passwordController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/myapp/user_login_post/');
    try {
      final response = await http.post(urls, body: {
        'username': uname,
        'password': pass,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String lid = jsonDecode(response.body)['lid'];
          String point = jsonDecode(response.body)['point'];
          sh.setString("lid", lid);
          sh.setString("point", point);
          Fluttertoast.showToast(msg: 'Success');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  EcoHomePage(),
              ),
            );
        } else {
          Fluttertoast.showToast(msg: 'Invalid credentials');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

}
