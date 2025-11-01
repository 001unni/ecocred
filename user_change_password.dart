import 'dart:convert';
import 'package:eco_frnd/homepage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(home: ChangePassword()));
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>EcoHomePage()),
        );
        return false; // prevent default pop
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Change Password"),
            backgroundColor: Colors.green,
          ),
          body: Padding(
          padding: const EdgeInsets.all(20.0),
      child: Center(
      child: Form(
      key: _formKey,
      child: ListView(
      shrinkWrap: true,
      children: [
      // Icon(Icons.password, size: 60, color: Colors.deepPurple),
      SizedBox(height: 30),

      // Current Password
      TextFormField(
      controller: currentPasswordController,
      obscureText: _obscureCurrent,
      decoration: InputDecoration(
      labelText: 'Current Password',
      // prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
      icon: Icon(
      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
      setState(() {
      _obscureCurrent = !_obscureCurrent;
      });
      },
      ),
      border: OutlineInputBorder(),
      ),
      validator: (value) {
      if (value == null || value.isEmpty) {
      return 'Please enter your current password';
      }
      return null;
      },
      ),
      SizedBox(height: 20),

      // New Password
      TextFormField(
      controller: newPasswordController,
      obscureText: _obscureNew,
      decoration: InputDecoration(
      labelText: 'New Password',
      // prefixIcon: Icon(Icons.lock_outline),
      suffixIcon: IconButton(
      icon: Icon(
      _obscureNew ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
      setState(() {
      _obscureNew = !_obscureNew;
      });
      },
      ),
      border: OutlineInputBorder(),
      ),
      validator: (value) {
      if (value == null || value.isEmpty) {
      return 'Please enter new password';
      } else if (value.length < 2) {
      return 'Password must be at least 3 characters';
      }
      return null;
      },
      ),
      SizedBox(height: 20),

      // Confirm Password
      TextFormField(
      controller: confirmPasswordController,
      obscureText: _obscureConfirm,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        // prefixIcon: Icon(Icons.lock_open),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirm = !_obscureConfirm;
            });
          },
        ),
        border: OutlineInputBorder(),
      ),
        validator: (value) {
          if (value != newPasswordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
        SizedBox(height: 30),

        // Submit Button
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              changePassword();
            }
          },
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text("Change Password", style: TextStyle(fontSize: 16)),
        ),
      ],
      ),
      ),
      ),
          ),
      ),
    );
  }

  Future<void> changePassword() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';

    final response = await http.post(
      Uri.parse('$url/myapp/user_change_password/'),
      body: {
        'lid': lid,
        'currentpassword': currentPasswordController.text,
        'newpassword': newPasswordController.text,
        'confirmpassword': confirmPasswordController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 'ok') {
        Fluttertoast.showToast(msg: 'Password changed successfully');
        Navigator.pop(context);
      } else if (jsonData['status'] == 'no') {
        Fluttertoast.showToast(msg: 'Current password is incorrect');
      } else if (jsonData['data'] == 'not') {
        Fluttertoast.showToast(msg: 'New and Confirm Password do not match');
      } else {
        Fluttertoast.showToast(msg: 'invalid password');
      }
    } else {
      Fluttertoast.showToast(msg: 'Network Error');
    }
  }
}