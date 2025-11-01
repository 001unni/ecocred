import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRScannerPage(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  Barcode? _barcode;
  bool _isScanning = true;
  final MobileScannerController _scannerController = MobileScannerController();

  void _handleBarcode(BarcodeCapture barcodes) {
    if (!_isScanning) return; // prevent multiple detections

    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null) {
      setState(() {
        _barcode = barcode;
        _isScanning = false;
      });

      // stop camera preview temporarily
      _scannerController.stop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: ${barcode.rawValue!}')),
      );
    }
  }

  void _resetScanner() {
    setState(() {
      _barcode = null;
      _isScanning = true;
    });
    _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),

          // dark overlay at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _barcode != null
                        ? "✅ Scanned Result:\n${_barcode!.rawValue}"
                        : "📷 Point camera at a QR code",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!_isScanning)
                    ElevatedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text("Scan Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
