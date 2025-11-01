
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class UploadImagePage extends StatefulWidget {
  final String title;
  final int tokens;

  const UploadImagePage({
    super.key,
    required this.title,
    required this.tokens,
  });

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _selectedImage;
  String photo = '';
  double? latitude, longitude;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getLocation(); // ✅ Fetch location as soon as page opens
  }

  // Pick image from gallery
  Future<void> _pickFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        photo = base64Encode(_selectedImage!.readAsBytesSync());
      });
      await _getLocation();
    }
  }

  // Pick image from camera
  Future<void> _pickFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        photo = base64Encode(_selectedImage!.readAsBytesSync());
      });
      await _getLocation();
    }
  }

  // Get current location
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: "Location permissions are permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error getting location: $e");
    }
  }

  // Upload proof to backend
  Future<void> sendData() async {
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

    final uri = Uri.parse('$url/myapp/user_upload_proof/');
    var request = http.MultipartRequest('POST', uri);

    // ✅ Add fields
    request.fields['lid'] = lid;
    request.fields['latitude'] = latitude?.toString() ?? '';
    request.fields['longitude'] = longitude?.toString() ?? '';
    request.fields['tokens'] = widget.tokens.toString();
    request.fields['title'] = widget.title.toString();

    // ✅ Add image
    request.files.add(await http.MultipartFile.fromPath(
      'photo',
      _selectedImage!.path,
    ));

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        // int added = data['added_points'];
        // int total = data['total_points'];
        //
        // // Save updated total in SharedPreferences
        // await sh.setInt('points', total);

        Fluttertoast.showToast(
            msg: "Upload successful!");

        Navigator.pop(context); // ✅ Back to previous page
      } else {
        Fluttertoast.showToast(
            msg: data['message'] ?? "Upload failed. Try again.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111315),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.title}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pick options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _optionButton(
                      icon: Icons.camera_alt,
                      label: "Take Photo",
                      onTap: _pickFromCamera),
                  _optionButton(
                      icon: Icons.upload_file,
                      label: "Upload File",
                      onTap: _pickFromGallery),
                ],
              ),
              const SizedBox(height: 20),

              // Image preview
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload,
                        color: Colors.green, size: 40),
                    SizedBox(height: 10),
                    Text("Upload your proof",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Location display
              if (latitude != null && longitude != null)
                Text(
                  "Lat: $latitude, Lng: $longitude",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sendData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Upload",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Option button widget
  Widget _optionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2421),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
