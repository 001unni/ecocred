import 'dart:convert';
import 'package:eco_frnd/homepage.dart';
import 'package:eco_frnd/send_complaint.dart';
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
      home: ViewReply(title: 'View Reply'),
    );
  }
}

class ViewReply extends StatefulWidget {
  const ViewReply({super.key, required this.title});
  final String title;

  @override
  State<ViewReply> createState() => _ViewReplyState();
}

class _ViewReplyState extends State<ViewReply> {
  List<Map<String, dynamic>> complaints = [];
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
      String lid = sh.getString('lid') ?? '';
      String apiUrl = '$urls/myapp/user_view_reply/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'],
            'date': item['date'],
            'complaint': item['complaint'],
            'reply': item['reply'],
            'statuss': item['status'],
          });
        }
        setState(() {
          complaints = tempList;
          filteredUsers = tempList
              .where((user) => user['id']
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              complaints.map((e) => e['id'].toString()).toSet().toList();
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
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 26, 147, 31),
          title: const Text(' Reply'),
        ),
        body: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index]; // Fixed from complaints[index]
            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 5,
              child: ListTile(
                title: Text(user['complaint'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${user['date']}"),
                    Text("Reply: ${user['reply']}"),
                    Text("Status: ${user['statuss']}"),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
          onPressed: () {
            // Navigate to send complaint page when FAB is clicked
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => sendcomplaint(title: '')));
          },
        ),
      ),
    );
  }
}
