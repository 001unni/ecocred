import 'dart:convert';
import 'package:eco_frnd/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: view_products(title: 'View Users'),
    );
  }
}

class view_products extends StatefulWidget {
  const view_products({super.key, required this.title});
  final String title;

  @override
  State<view_products> createState() => _view_productsState();
}

class _view_productsState extends State<view_products> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/myapp/user_view_product/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'].toString(),
            'name': item['name'].toString(),
            'tokens': item['tokens'].toString(),
            'description': item['description'].toString(),
            'category': item['category'].toString(),
            'image': img + item['image'].toString(),
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) =>
              user['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions = users.map((e) => e['name'].toString()).toSet().toList();
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
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
          return false; // Prevent default pop
        },
        child:Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("Products"),
        ),
          body: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['image']),
                    radius: 30,
                  ),
                  title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tokens: ${user['tokens']}"),
                      Text("Description: ${user['description']}"),
                      Text("Category: ${user['category']}"),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}