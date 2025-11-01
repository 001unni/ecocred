import 'dart:io';
import 'package:eco_frnd/homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart ';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const editprofile());
}

class editprofile extends StatelessWidget {
  const editprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Edit profile',
        home: edit_profile(title: 'Edit profile',)
    );
  }
}

class edit_profile extends StatefulWidget {
  const edit_profile({super.key, required this.title});
  final String title;

  @override
  State<edit_profile> createState() => _edit_profileState();
}
class _edit_profileState extends State<edit_profile> {
  _edit_profileState(){
    _get_data();
  }

  String gender = "Male";
  File? uploadimage;


  TextEditingController nameController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();
  TextEditingController phoneController= new TextEditingController();
  TextEditingController placeController= new TextEditingController();
  TextEditingController pinController= new TextEditingController();
  TextEditingController postController= new TextEditingController();
  TextEditingController districtController= new TextEditingController();
  TextEditingController stateController= new TextEditingController();
  TextEditingController dobController= new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EcoHomePage()),
        );
        return false; // prevent default pop
      },      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_selectedImage != null) ...{
                InkWell(
                  child:
                  Image.file(_selectedImage!, height: 400,),
                  radius: 399,
                  onTap: _checkPermissionAndChooseImage,
                  // borderRadius: BorderRadius.all(Radius.circular(200)),
                ),
              } else ...{
                // Image(image: NetworkImage(),height: 100, width: 70,fit: BoxFit.cover,),
                InkWell(
                  onTap: _checkPermissionAndChooseImage,
                  child:Column(
                    children: [
                      Image(image: NetworkImage(photo1),height: 200,width: 200,),
                      Text('Select Image',style: TextStyle(color: Colors.cyan))
                    ],
                  ),
                ),
              },

              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: "Name"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Email")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('Phone')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: placeController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('place')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: postController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('Post')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: pinController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('Pin')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: districtController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('District')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: stateController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('State')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: dobController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text('Dob')),
                ),
              ),
              RadioListTile(value: "Male", groupValue: gender, onChanged: (value) { setState(() {gender="Male";}); },title: Text("Male"),),
              RadioListTile(value: "Female", groupValue: gender, onChanged: (value) { setState(() {gender="Female";}); },title: Text("Female"),),
              RadioListTile(value: "Other", groupValue: gender, onChanged: (value) { setState(() {gender="Other";}); },title: Text("Other"),),

              ElevatedButton(
                onPressed: () {
                  _send_data() ;
                },
                child: Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _send_data() async{

    String uname=nameController.text;
    String uemail=emailController.text;
    String uphone=phoneController.text;
    String uplace=placeController.text;
    String upin=pinController.text;
    String upost=postController.text;
    String ustate=stateController.text;
    String udistrict=districtController.text;
    String udob=dobController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_edit_profile/');
    try {

      final response = await http.post(urls, body: {
        "name":uname,
        "email":uemail,
        "phone":uphone,
        "place":uplace,
        "pin":upin,
        "post":upost,
        "state":ustate,
        "gender":gender,
        "district":udistrict,
        "dob":udob,
        "photo":photo,
        "lid":lid,

      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {

          Fluttertoast.showToast(msg: 'Updated Successfull');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => EcoHomePage(),));
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
  File? _selectedImage;
  String? _encodedImage;
  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
        photo = _encodedImage.toString();
      });
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Please go to app settings and grant permission to choose an image.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String photo = '';
  String photo1 = '';
  
  void _get_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String id = sh.getString('id').toString();
    String img_url = sh.getString('img_url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_view_profile/');
    try {
      final response = await http.post(urls, body: {
        'lid': lid,
        'id' : id
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String name = jsonDecode(response.body)['name'].toString();
          String email = jsonDecode(response.body)['email'].toString();
          String phone = jsonDecode(response.body)['phone'].toString();
          String place = jsonDecode(response.body)['place'].toString();
          String pin = jsonDecode(response.body)['pin'].toString();
          String post = jsonDecode(response.body)['post'].toString();
          String state = jsonDecode(response.body)['state'].toString();
          String district = jsonDecode(response.body)['district'].toString();
          String dob = jsonDecode(response.body)['dob'].toString();
          String gender_ = jsonDecode(response.body)['gender'].toString();
          String photo_= img_url+jsonDecode(response.body)['photo'].toString();

          setState(() {

            nameController.text = name;
            emailController.text=email;
            phoneController.text=phone;
            placeController.text=place;
            pinController.text=pin;
            postController.text=post;
            districtController.text=district;
            stateController.text=state;
            gender = gender_;
            dobController.text = dob;
            photo1=photo_;
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
