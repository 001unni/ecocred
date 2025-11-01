import 'dart:convert';
import 'package:eco_frnd/homepage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp( sendcomplaint(title: '',));
}

class sendcomplaint extends StatefulWidget {
  const sendcomplaint({super.key, required this.title});

  final String title;
  @override
  State<sendcomplaint> createState() => _sendcomplaintState();

}
class _sendcomplaintState extends State<sendcomplaint> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController complaintcontroller = TextEditingController();



  Future<void> _sendData() async {
    String com = complaintcontroller.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String lid = sh.getString('lid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/myapp/user_send_complaint/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['complaint'] = com;
    request.fields['lid'] = lid;


    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>EcoHomePage()));
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  EcoHomePage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Complaint"),
          // centerTitle: true,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                TextFormField(
                  maxLines: 5,
                  controller: complaintcontroller,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Complaint',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendData();
                    } else {
                      Fluttertoast.showToast(msg: "Please fix errors in the form");
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}