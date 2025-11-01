import 'package:eco_frnd/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main(){
  runApp(ippage());
}

class ippage extends StatelessWidget {
  const ippage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "IP Page",
      home: ip_page(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ip_page extends StatefulWidget {
  const ip_page({super.key});

  @override
  State<ip_page> createState() => _ip_pageState();
}

class _ip_pageState extends State<ip_page> {

  final _formkey=GlobalKey<FormState>();
  final _ipaddr=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IP PAGE"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.20),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _ipaddr,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Enter IP Address';
                  }
                  final ipRegex = RegExp(
                      r'^(25[0-5]|2[0-4][0-9]|1\d{2}|[1-9]?\d)\.'
                      r'(25[0-5]|2[0-4][0-9]|1\d{2}|[1-9]?\d)\.'
                      r'(25[0-5]|2[0-4][0-9]|1\d{2}|[1-9]?\d)\.'
                      r'(25[0-5]|2[0-4][0-9]|1\d{2}|[1-9]?\d)$'
                  );
                  if (!ipRegex.hasMatch(value)) {
                    return 'Enter a valid IPv4 address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: (){
                    if(_formkey.currentState!.validate()){
                      senddata();
                    }
                    else{
                      Fluttertoast.showToast(msg: 'Please fill something');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Colors.green,
                    minimumSize:const Size(double.infinity,50),
                  ),
                  child:const Text("IP Address"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> senddata() async {
    String ip=_ipaddr.text;
    String url="http://"+ip+":8000";

    SharedPreferences sh= await SharedPreferences.getInstance();
    sh.setString("url", url).toString();
    sh.setString("img_url", url).toString();

    Navigator.push(context, MaterialPageRoute(builder: (context)=>EcoLoginPage()));
  }
}


