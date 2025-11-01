
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eco_frnd/camera.dart';
import 'package:eco_frnd/categories.dart';
import 'package:eco_frnd/location.dart';
import 'package:eco_frnd/login.dart';
import 'package:eco_frnd/qr_scanner.dart';
import 'package:eco_frnd/uploadproof.dart';
import 'package:eco_frnd/user_view_profile.dart';
import 'package:eco_frnd/view_reply.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EcoApp());
}

class EcoApp extends StatelessWidget {
  const EcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const EcoHomePage(),
    );
  }
}

class EcoHomePage extends StatefulWidget {
  const EcoHomePage({super.key});

  @override
  State<EcoHomePage> createState() => _EcoHomePageState();
}

class _EcoHomePageState extends State<EcoHomePage> {
  int _selectedIndex = 0;
  String totalPoints = "0";
  String tokens_ = "";

  final List<Map<String, dynamic>> ecoActions = [
    {
      "title": "Energy Saving",
      "subtitle": "Reduce electricity usage",
      "tokens": 150,
      "progress": 0.75,
      "icon": Icons.energy_savings_leaf,
      "color": Colors.green,
    },
    {
      "title": "Waste Management",
      "subtitle": "Proper waste segregation",
      "tokens": 120,
      "progress": 0.60,
      "icon": Icons.recycling,
      "color": Colors.blue,
    },
    {
      "title": "Carpooling",
      "subtitle": "Share rides to reduce carbon footprint",
      "tokens": 200,
      "progress": 0.40,
      "icon": Icons.directions_car,
      "color": Colors.green,
    },
    {
      "title": "Tree Planting",
      "subtitle": "Plant trees for the future",
      "tokens": 300,
      "progress": 0.85,
      "icon": Icons.park,
      "color": Colors.green,
    },
    {
      "title": "Eco Shopping",
      "subtitle": "Sustainable Purchase",
      "tokens": 100,
      "progress": 0.55,
      "icon": Icons.shopping_bag,
      "color": Colors.yellow,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPoints();
    _view_tokens();
  }

  Future<void> _loadPoints() async {
    // SharedPreferences sh = await SharedPreferences.getInstance();
    // setState(() {
    //   totalPoints = sh.getString('point') ?? "0"; // ✅ safe default
    // });

    _view_tokens();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ViewProfilePage(title: '')),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RewardsPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ViewReply(title: '')),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EcoLoginPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPoints,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top card with dynamic EcoTokens
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F1C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalPoints,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Text("EcoTokens",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.trending_up,
                                    color: Colors.green),
                              ),
                              const SizedBox(width: 8),
                              const Text("+10 Today",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.emoji_events,
                                    color: Colors.blue),
                              ),
                              const SizedBox(width: 8),
                              const Text("10 Day Streak",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      Icons.photo_camera,
                      "Photo",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UploadEcoActivity()),
                        ).then((_) => _loadPoints());
                      },
                    ),
                    _actionButton(
                      Icons.qr_code_scanner,
                      "QR Scan",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRScannerPage()),
                        );
                      },
                    ),
                    _actionButton(
                      Icons.location_on,
                      "Location",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LocationPage()),
                            );                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 Eco Actions header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Eco Actions",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text("View All", style: TextStyle(color: Colors.green)),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 Eco Action Cards
                Column(
                  children: ecoActions.map((action) {
                    return _ecoActionCard(
                      context,
                      title: action["title"],
                      subtitle: action["subtitle"],
                      tokens: action["tokens"],
                      progress: action["progress"],
                      icon: action["icon"],
                      color: action["color"],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1F1C),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Reply"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F1C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _ecoActionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required int tokens,
        required double progress,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                "+$tokens",
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(" tokens",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          const Text("Progress", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences sh = await SharedPreferences.getInstance();

                // Save the title and tokens if needed later
                await sh.setString("title", title);
                await sh.setInt("tokens", tokens);

                // 👇 Pass both title and tokens to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadImagePage(
                      title: title,
                      tokens: tokens,
                    ),
                  ),
                ).then((_) => _loadPoints());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Upload Proof",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),

          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       SharedPreferences sh = await SharedPreferences.getInstance();
          //
          //       // ✅ read current points
          //       // int currentPoints =
          //       //     int.tryParse(sh.getString("points") ?? "0") ?? 0;
          //
          //       // ✅ add new tokens
          //       // int updatedPoints = currentPoints + tokens;
          //
          //       // ✅ save back
          //       // await sh.setString("points", updatedPoints.toString());
          //       await sh.setString("title", title);
          //
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => const UploadImagePage()),
          //       ).then((_) => _loadPoints());
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: color,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       padding: const EdgeInsets.symmetric(vertical: 14),
          //     ),
          //     child: const Text("Upload Proof",
          //         style: TextStyle(fontSize: 16, color: Colors.white)),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _view_tokens() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String img_url = sh.getString('img_url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_view_tokens/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String tokens = jsonDecode(response.body)['points'].toString();

          setState(() {
            totalPoints = tokens;
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
