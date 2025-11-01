import 'package:eco_frnd/homepage.dart';
import 'package:eco_frnd/user_change_password.dart';
import 'package:eco_frnd/user_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ViewProfile());
}

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViewProfilePage(title: 'View Profile'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  String name_ = "";
  String email_ = "";
  String phone_ = "";
  String place_ = "";
  String post_ = "";
  String pin_ = "";
  String district_ = "";
  String state_ = "";
  String dob_ = "";
  String gender_ = "";
  String photo_ = "";

  _ViewProfilePageState() {
    _send_data();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EcoHomePage()),
        );
        return false; // prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          backgroundColor: Colors.green,
          title: Text("Profile"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(photo_),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name_,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Divider(height: 30, thickness: 1.5),
                    const SizedBox(height: 10),
                    Text(
                      phone_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      dob_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      gender_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      place_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      post_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      pin_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      district_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      state_,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // SharedPreferences sh = await SharedPreferences.getInstance();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => edit_profile(title: 'Edit Profile')));
                      },
                      icon: Icon(Icons.edit),
                      label: Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // SharedPreferences sh = await SharedPreferences.getInstance();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePassword()));
                      },
                      icon: Icon(Icons.lock),
                      label: Text("Change Password"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String img_url = sh.getString('img_url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_view_profile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String name = jsonDecode(response.body)['name'].toString();
          String email = jsonDecode(response.body)['email'].toString();
          String phone = jsonDecode(response.body)['phone'].toString();
          String place = jsonDecode(response.body)['place'].toString();
          String pin = jsonDecode(response.body)['pin'].toString();
          String post = jsonDecode(response.body)['post'].toString();
          String district = jsonDecode(response.body)['district'].toString();
          String state = jsonDecode(response.body)['state'].toString();
          String dob = jsonDecode(response.body)['dob'].toString();
          String gender = jsonDecode(response.body)['gender'].toString();
          String photo= img_url+jsonDecode(response.body)['photo'].toString();

          setState(() {
            name_ = name;
            dob_ = dob;
            gender_ = gender;
            email_ = email;
            phone_ = phone;
            place_ = place;
            pin_ = pin;
            post_ = post;
            state_ = state;
            district_ = district;
            photo_ = photo;
          });
        }else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      }
      else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    }
    catch (e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
