import 'dart:convert';
import 'package:eco_frnd/homepage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RewardsApp());
}

class RewardsApp extends StatelessWidget {
  const RewardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RewardsPage(),
    );
  }
}

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  String selectedCategory = "All";
  double? latitude, longitude;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _getLocation();
    fetchProducts("");
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

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
        Fluttertoast.showToast(msg: "Location permissions permanently denied");
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

  Future<void> fetchProducts(String searchValue) async {
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
          String category = item['category']?.toString() ?? "";

          if (category.isEmpty) {
            String name = item['name'].toString().toLowerCase();
            if (name.contains("voucher")) {
              category = "Vouchers";
            } else if (name.contains("experience")) {
              category = "Experience";
            } else {
              category = "Products";
            }
          }

          tempList.add({
            'id': item['id'].toString(),
            'title': item['name'].toString(),
            'tokens': int.parse(item['tokens'].toString()),
            'desc': item['description'].toString(),
            'category': category,
            'image': img + item['image'].toString(),
          });
        }
        setState(() {
          products = tempList;
          filterProducts();
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  void filterProducts() {
    setState(() {
      filteredProducts = selectedCategory == "All"
          ? products
          : products
          .where((item) => item["category"] == selectedCategory)
          .toList();
    });
  }

  void openCheckout(Map<String, dynamic> item) {
    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe', // test key
      'amount': item["tokens"] * 100,
      'name': 'Redeem Reward',
      'description': 'Payment for ${item["title"]}',
      'prefill': {'contact': '9876543210', 'email': 'test@gmail.com'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
      selectedReward = item;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Map<String, dynamic>? selectedReward;

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "✅ Payment Successful!");
    await _sendData(response.paymentId ?? "");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "❌ Payment Failed!");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  Future<void> _sendData(String paymentId) async {
    if (selectedReward == null) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? "";
    String? lid = sh.getString('lid');

    final uri = Uri.parse('$url/myapp/update_tokens/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['lid'] = lid ?? '';
    // request.fields['payment_id'] = paymentId;
    request.fields['latitude'] = latitude?.toString() ?? '';
    request.fields['longitude'] = longitude?.toString() ?? '';
    request.fields['title'] = selectedReward!["title"];
    request.fields['token'] = selectedReward!["tokens"].toString();
    request.fields['pid'] = selectedReward!["id"].toString();

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
            msg:
            "✅ Payment saved! ${data['added_points'] ?? ''} points credited.",
            backgroundColor: Colors.green);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  EcoHomePage(),
              ),
            );
      } else {
        Fluttertoast.showToast(
            msg: "⚠️ Server Error", backgroundColor: Colors.orange);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "❌ Network Error: $e", backgroundColor: Colors.red);
    }
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Rewards"),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              if (latitude != null && longitude != null)
                Text("📍 Lat: $latitude, Lng: $longitude",
                    style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    categoryButton("All", Icons.all_inclusive),
                    const SizedBox(width: 8),
                    categoryButton("Vouchers", Icons.card_giftcard),
                    const SizedBox(width: 8),
                    categoryButton("Products", Icons.shopping_cart),
                    const SizedBox(width: 8),
                    categoryButton("Experience", Icons.favorite),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              filteredProducts.isEmpty
                  ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("No rewards available",
                        style: TextStyle(color: Colors.white70)),
                  ))
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 230,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  return rewardCard(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryButton(String name, IconData icon) {
    final bool selected = selectedCategory == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = name;
          filterProducts();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.grey[850],
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : Colors.white70, size: 18),
            const SizedBox(width: 6),
            Text(name,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget rewardCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item["title"],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("${item["tokens"]} tokens",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          if (item["image"].isNotEmpty)
            Center(
              child: Image.network(item["image"], height: 60, fit: BoxFit.cover),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => openCheckout(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Redeem", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
