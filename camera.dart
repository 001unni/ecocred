import 'dart:convert';
import 'dart:io';
import 'package:eco_frnd/homepage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class UploadEcoActivity extends StatefulWidget {
  const UploadEcoActivity({super.key});

  @override
  State<UploadEcoActivity> createState() => _UploadEcoActivityState();
}

class _UploadEcoActivityState extends State<UploadEcoActivity> {
  File? _selectedImage;
  bool _loading = false;
  String _activity = '';
  int _points = 0;
  double? _latitude;
  double? _longitude;

  // 📸 Pick image from camera
  Future<void> _chooseImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      _getLocation(); // auto get location when image is selected
    }
  }

  // 📍 Get current location
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable location services');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permission permanently denied');
      return;
    }

    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  // ☁️ Upload image to Django backend
  Future<void> _uploadActivity() async {
    if (_selectedImage == null) {
      Fluttertoast.showToast(msg: "Please select an image first");
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Server URL or Login ID not found.");
      return;
    }

    setState(() {
      _loading = true;
    });

    final uri = Uri.parse('$url/myapp/user_upload_image/');
    var request = http.MultipartRequest('POST', uri);

    // ✅ Add form fields
    request.fields['lid'] = lid;
    request.fields['latitude'] = _latitude?.toString() ?? '';
    request.fields['longitude'] = _longitude?.toString() ?? '';
    request.fields['title'] = 'Eco Activity';

    // ✅ Add photo file
    request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        setState(() {
          _activity = data['activity'] ?? '';
          _points = data['points'] ?? 0;
        });

        Fluttertoast.showToast(
          msg: "✅ Upload successful! Activity: $_activity, Points: $_points",
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  EcoHomePage(),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Upload failed. Try again.",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // 🖼️ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Eco Activity'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image picker card
            InkWell(
              onTap: _chooseImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.green, size: 50),
                    SizedBox(height: 10),
                    Text("Tap to Capture Image",
                        style: TextStyle(color: Colors.green))
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_latitude != null && _longitude != null)
              Text("📍 Location: $_latitude , $_longitude",
                  style: const TextStyle(color: Colors.black87)),

            const SizedBox(height: 30),

            _loading
                ? const CircularProgressIndicator(color: Colors.green)
                : ElevatedButton.icon(
              onPressed: _uploadActivity,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Upload Activity"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 30),

            // Show activity + points after upload
            if (_activity.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text("🌿 Activity: $_activity",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("🏆 Points Earned: $_points",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
