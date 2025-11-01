import 'dart:convert';
import 'dart:io';
import 'package:eco_frnd/login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const userregister());
}

class userregister extends StatelessWidget {
  const userregister({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: user_register());
  }
}

class user_register extends StatefulWidget {
  const user_register({super.key});

  @override
  State<user_register> createState() => _user_registerState();
}

class _user_registerState extends State<user_register> {
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String gender = "Male";
  File? _selectedImage;
  String photo = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('User Register'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                // Image Picker
                if (_selectedImage != null)
                  InkWell(
                    onTap: _chooseAndUploadImage,
                    child: Image.file(_selectedImage!, height: 150),
                  )
                else
                  InkWell(
                    onTap: _chooseAndUploadImage,
                    child: Column(
                      children: [
                        Image.network(
                          'https://cdn.pixabay.com/photo/2017/11/10/05/24/select-2935439_1280.png',
                          height: 150,
                          width: 150,
                        ),
                        const Text('Select Image', style: TextStyle(color: Colors.green))
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter your Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only letters allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mobile
                TextFormField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: "Enter your Mobile Number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mobile number is required';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Pin
                TextFormField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: "Enter your pin code",
                    prefixIcon: Icon(Icons.push_pin),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pin code is required';
                    } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'Enter a valid 6-digit pin code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: postController,
                  decoration: const InputDecoration(
                    labelText: "Enter your post",
                    prefixIcon: Icon(Icons.post_add),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'post code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Place
                TextFormField(
                  controller: placeController,
                  decoration: const InputDecoration(
                    labelText: "Enter your Place",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Place is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // District
                TextFormField(
                  controller: districtController,
                  decoration: const InputDecoration(
                    labelText: "Enter your District",
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'District is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(
                    labelText: "Enter your state code",
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'state code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date of Birth
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      setState(() {
                        dobController.text = formattedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Gender Radio Buttons
                RadioListTile(
                    value: "Male",
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                    title: const Text("Male")),
                RadioListTile(
                    value: "Female",
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                    title: const Text("Female")),
                RadioListTile(
                    value: "Other",
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                    title: const Text("Other")),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Enter your Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Enter your Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 3) {
                      return 'Password must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Confirm your Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedImage == null) {
                        Fluttertoast.showToast(msg: "Please select an image");
                      } else {
                        _sendData();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Register", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _sendData() async {
    String name = nameController.text;
    String mobile = mobileController.text;
    String place = placeController.text;
    String post = postController.text;
    String email = emailController.text;
    String pin = pinController.text;
    String district = districtController.text;
    String state = stateController.text;
    String password = passwordController.text;
    String cpassword = confirmPasswordController.text;
    String dob = dobController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/myapp/user_signup_post/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] =name ;
    request.fields['phone'] = mobile;
    request.fields['place'] = place;
    request.fields['post'] = post;
    request.fields['email'] = email;
    request.fields['pin'] = pin;
    request.fields['district'] =district ;
    request.fields['state'] =state ;
    request.fields['password'] = password;
    request.fields['confirmpass'] = cpassword;
    request.fields['dob'] = dob;
    request.fields['gender'] = gender;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const EcoLoginPage()));

      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        photo = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }
}
