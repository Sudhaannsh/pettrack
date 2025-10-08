import 'package:flutter/material.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

class PetQRScreen extends StatefulWidget {
  final PetModel pet;

  const PetQRScreen({super.key, required this.pet});

  @override
  _PetQRScreenState createState() => _PetQRScreenState();
}

class _PetQRScreenState extends State<PetQRScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isLoading = false;

  // Create QR code data - Store pet ID only
  String _generateQRData() {
    // Store just the pet ID - will be used to fetch pet details
    return widget.pet.id ?? '';
  }

  Future<void> _shareQRCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/${widget.pet.name}_qr_code.png',
        ).create();
        await file.writeAsBytes(byteData.buffer.asUint8List());

        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'QR Code for ${widget.pet.name}. Scan this to get instant access to pet details!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing QR code: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name}\'s QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _shareQRCode,
            tooltip: 'Share QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pet image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.pet.imageUrl,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.pets, size: 100),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // QR Code
                        RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: _generateQRData(),
                              version: QrVersions.auto,
                              size: 250,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Pet details
                        Text(
                          widget.pet.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.pet.breed,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (widget.pet.color.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.pet.color,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'How to use this QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Print this QR code and attach it to ${widget.pet.name}\'s collar or tag\n\n'
                      '2. Anyone who finds your pet can scan this code\n\n'
                      '3. They will instantly see your pet\'s details and contact you',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Share button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _shareQRCode,
                  icon: _isLoading
                      ? const SizedBox(
                                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(_isLoading ? 'Sharing...' : 'Share QR Code'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
