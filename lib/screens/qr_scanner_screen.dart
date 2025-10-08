// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/screens/pet_detail_screen.dart';

// class QRScannerScreen extends StatefulWidget {
//   const QRScannerScreen({super.key});

//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController();
//   bool isScanning = true;
//   bool hasPermission = false;
//   bool isProcessing = false;
//   bool isTorchOn = false; // Add this to track torch state
//   final PetService _petService = PetService();

//   @override
//   void initState() {
//     super.initState();
//     _checkCameraPermission();
//   }

//   Future<void> _checkCameraPermission() async {
//     final status = await Permission.camera.status;
//     if (status.isGranted) {
//       setState(() {
//         hasPermission = true;
//       });
//     } else {
//       final result = await Permission.camera.request();
//       setState(() {
//         hasPermission = result.isGranted;
//       });
//     }
//   }

//   void _onDetect(BarcodeCapture capture) {
//     if (!isScanning || isProcessing) return;

//     final List<Barcode> barcodes = capture.barcodes;
//     if (barcodes.isNotEmpty) {
//       final String? code = barcodes.first.rawValue;
//       if (code != null) {
//         setState(() {
//           isProcessing = true;
//           isScanning = false;
//         });
//         _handleScannedData(code);
//       }
//     }
//   }

//   Future<void> _handleScannedData(String data) async {
//     try {
//       // Show processing indicator
//       _showProcessingDialog();

//       // Check if the scanned data is a pet ID
//       String petId = '';
      
//       if (data.startsWith('pettrack://pet/')) {
//         petId = data.replaceFirst('pettrack://pet/', '');
//       } else if (data.length >= 10) { // Assuming pet IDs are at least 10 characters
//         petId = data;
//       } else {
//         // Invalid QR code
//         Navigator.of(context).pop(); // Close processing dialog
//         _showErrorDialog('Invalid QR Code', 'This QR code is not associated with any pet in PetTrack.');
//         return;
//       }

//       await _navigateToPetDetail(petId);
//     } catch (e) {
//       Navigator.of(context).pop(); // Close processing dialog
//       _showErrorDialog('Error', 'Failed to process QR code: $e');
//     }
//   }

//   void _showProcessingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Searching for pet...'),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _navigateToPetDetail(String petId) async {
//     try {
//       // Check if pet exists
//       final pet = await _petService.getPetById(petId);
      
//       if (mounted) {
//         Navigator.of(context).pop(); // Close processing dialog
        
//         if (pet != null) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => PetDetailScreen(petId: petId),
//             ),
//           );
//         } else {
//           _showErrorDialog('Pet Not Found', 'No pet found with this QR code. The pet may have been removed or the QR code is invalid.');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.of(context).pop(); // Close processing dialog
//         _showErrorDialog('Error', 'Failed to find pet: $e');
//       }
//     }
//   }

//   void _showErrorDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _resetScanner();
//               },
//               child: const Text('Try Again'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop(); // Go back to home
//               },
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _resetScanner() {
//     setState(() {
//       isScanning = true;
//       isProcessing = false;
//     });
//   }

//   Future<void> _toggleTorch() async {
//     try {
//       await cameraController.toggleTorch();
//       setState(() {
//         isTorchOn = !isTorchOn;
//       });
//     } catch (e) {
//       print('Error toggling torch: $e');
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!hasPermission) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('QR Scanner'),
//           backgroundColor: Colors.blue.shade600,
//           foregroundColor: Colors.white,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.camera_alt_outlined,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Camera Permission Required',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'PetTrack needs camera access to scan QR codes on pet collars.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: _checkCameraPermission,
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text('Grant Permission'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade600,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Pet QR Code'),
//         backgroundColor: Colors.blue.shade600,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
//             onPressed: _toggleTorch,
//             tooltip: isTorchOn ? 'Turn off flash' : 'Turn on flash',
//           ),
//           IconButton(
//             icon: const Icon(Icons.flip_camera_ios),
//             onPressed: () => cameraController.switchCamera(),
//             tooltip: 'Switch camera',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Instructions
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: Colors.blue.shade50,
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.qr_code_scanner,
//                   color: Colors.blue.shade600,
//                   size: 32,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Point your camera at the QR code on the pet\'s collar',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.blue.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Make sure the QR code is clearly visible and well-lit',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // QR Scanner
//           Expanded(
//             flex: 4,
//             child: Stack(
//               children: [
//                 MobileScanner(
//                   controller: cameraController,
//                   onDetect: _onDetect,
//                 ),
                
//                 // Scanning overlay
//                 Container(
//                   decoration: ShapeDecoration(
//                     shape: QrScannerOverlayShape(
//                       borderColor: Colors.blue.shade600,
//                       borderRadius: 10,
//                       borderLength: 30,
//                       borderWidth: 10,
//                       cutOutSize: 250,
//                     ),
//                   ),
//                 ),
                
//                 // Scanning indicator
//                 if (isScanning && !isProcessing)
//                   Positioned(
//                     bottom: 20,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Scanning...',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
          
//           // Bottom section with tips
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.lightbulb_outline, color: Colors.amber.shade600),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Tips for better scanning:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   '• Hold your phone steady\n'
//                   '• Ensure good lighting (use flash if needed)\n'
//                   '• Keep the QR code within the frame\n'
//                   '• Clean the camera lens if needed',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Manual entry option
//                 OutlinedButton.icon(
//                   onPressed: () {
//                     _showManualEntryDialog();
//                   },
//                   icon: const Icon(Icons.edit),
//                   label: const Text('Enter Pet ID Manually'),
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 45),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showManualEntryDialog() {
//     final TextEditingController petIdController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Enter Pet ID'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('If you have the pet ID, you can enter it manually:'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: petIdController,
//                 decoration: const InputDecoration(
//                   labelText: 'Pet ID',
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter the pet ID from the collar tag',
//                 ),
//                 textCapitalization: TextCapitalization.characters,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 if (petIdController.text.isNotEmpty) {
//                   _handleScannedData(petIdController.text.trim());
//                 }
//               },
//               child: const Text('Search'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // Custom overlay shape for QR scanner
// class QrScannerOverlayShape extends ShapeBorder {
//   const QrScannerOverlayShape({
//     this.borderColor = Colors.red,
//     this.borderWidth = 3.0,
//     this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
//     this.borderRadius = 0,
//     this.borderLength = 40,
//     this.cutOutSize = 250,
//   });

//   final Color borderColor;
//   final double borderWidth;
//   final Color overlayColor;
//   final double borderRadius;
//   final double borderLength;
//   final double cutOutSize;

//   @override
//   EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//     return Path()
//       ..fillType = PathFillType.evenOdd
//       ..addPath(getOuterPath(rect), Offset.zero);
//   }

//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     Path getLeftTopPath(Rect rect) {
//       return Path()
//         ..moveTo(rect.left, rect.bottom)
//         ..lineTo(rect.left, rect.top)
//         ..lineTo(rect.right, rect.top);
//     }

//     return getLeftTopPath(rect)
//       ..lineTo(rect.right, rect.bottom)
//       ..lineTo(rect.left, rect.bottom)
//       ..lineTo(rect.left, rect.top);
//   }

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
//     final width = rect.width;
//     final borderWidthSize = width / 2;
//     final height = rect.height;
//     final borderOffset = borderWidth / 2;
//     final mBorderLength = borderLength > borderWidthSize / 2 ? borderWidthSize / 2 : borderLength;
//     final mCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

//         final backgroundPaint = Paint()
//       ..color = overlayColor
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderWidth;

//     final boxPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOut;

//     final cutOutRect = Rect.fromLTWH(
//       rect.left + (width - mCutOutSize) / 2 + borderOffset,
//       rect.top + (height - mCutOutSize) / 2 + borderOffset,
//       mCutOutSize - borderOffset * 2,
//       mCutOutSize - borderOffset * 2,
//     );

//     canvas
//       ..saveLayer(rect, backgroundPaint)
//       ..drawRect(rect, backgroundPaint)
//       // Draw top right corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.right - mBorderLength,
//           cutOutRect.top,
//           cutOutRect.right,
//           cutOutRect.top + mBorderLength,
//           topRight: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw top left corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.left,
//           cutOutRect.top,
//           cutOutRect.left + mBorderLength,
//           cutOutRect.top + mBorderLength,
//           topLeft: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw bottom right corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.right - mBorderLength,
//           cutOutRect.bottom - mBorderLength,
//           cutOutRect.right,
//           cutOutRect.bottom,
//           bottomRight: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw bottom left corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.left,
//           cutOutRect.bottom - mBorderLength,
//           cutOutRect.left + mBorderLength,
//           cutOutRect.bottom,
//           bottomLeft: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       ..drawRRect(
//         RRect.fromRectAndRadius(
//           cutOutRect,
//           Radius.circular(borderRadius),
//         ),
//         boxPaint,
//       )
//       ..restore();
//   }

//   @override
//   ShapeBorder scale(double t) {
//     return QrScannerOverlayShape(
//       borderColor: borderColor,
//       borderWidth: borderWidth,
//       overlayColor: overlayColor,
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';

// class QRScannerScreen extends StatefulWidget {
//   const QRScannerScreen({super.key});

//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController();
//   bool isScanning = true;
//   bool hasPermission = false;
//   bool isProcessing = false;
//   bool isTorchOn = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkCameraPermission();
//   }

//   Future<void> _checkCameraPermission() async {
//     final status = await Permission.camera.status;
//     if (status.isGranted) {
//       setState(() {
//         hasPermission = true;
//       });
//     } else {
//       final result = await Permission.camera.request();
//       setState(() {
//         hasPermission = result.isGranted;
//       });
//     }
//   }

//   void _onDetect(BarcodeCapture capture) {
//     if (!isScanning || isProcessing) return;

//     final List<Barcode> barcodes = capture.barcodes;
//     if (barcodes.isNotEmpty) {
//       final String? code = barcodes.first.rawValue;
//       if (code != null) {
//         setState(() {
//           isProcessing = true;
//           isScanning = false;
//         });
//         _handleScannedData(code);
//       }
//     }
//   }

//   Future<void> _handleScannedData(String data) async {
//     try {
//       // Show result dialog
//       _showResultDialog(data);
//     } catch (e) {
//       _showErrorDialog('Error', 'Failed to process QR code: $e');
//     }
//   }

//   void _showResultDialog(String data) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         final bool isUrl = _isValidUrl(data);

//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(
//                 isUrl ? Icons.link : Icons.qr_code,
//                 color: Colors.blue.shade600,
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   isUrl ? 'Link Found' : 'QR Code Scanned',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Scanned content:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: SelectableText(
//                   data,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),
//               if (isUrl) ...[
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Icon(Icons.info_outline,
//                         size: 16, color: Colors.blue.shade600),
//                     const SizedBox(width: 4),
//                     const Expanded(
//                       child: Text(
//                         'This appears to be a web link',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: data));
//                 Navigator.of(context).pop();
//                 _showSnackBar('Copied to clipboard');
//                 _resetScanner();
//               },
//               child: const Text('Copy'),
//             ),
//             if (isUrl)
//               ElevatedButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   await _openUrl(data);
//                   _resetScanner();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Open Link'),
//               )
//             else
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _resetScanner();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('OK'),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   bool _isValidUrl(String data) {
//     try {
//       final uri = Uri.parse(data);
//       return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> _openUrl(String url) async {
//     try {
//       final Uri uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         _showErrorDialog('Error', 'Cannot open this URL');
//       }
//     } catch (e) {
//       _showErrorDialog('Error', 'Failed to open URL: $e');
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showErrorDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _resetScanner();
//               },
//               child: const Text('Try Again'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop(); // Go back to previous screen
//               },
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _resetScanner() {
//     setState(() {
//       isScanning = true;
//       isProcessing = false;
//     });
//   }

//   Future<void> _toggleTorch() async {
//     try {
//       await cameraController.toggleTorch();
//       setState(() {
//         isTorchOn = !isTorchOn;
//       });
//     } catch (e) {
//       print('Error toggling torch: $e');
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!hasPermission) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('QR Scanner'),
//           backgroundColor: Colors.blue.shade600,
//           foregroundColor: Colors.white,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.camera_alt_outlined,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Camera Permission Required',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'QR Scanner needs camera access to scan QR codes.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: _checkCameraPermission,
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text('Grant Permission'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade600,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 24, vertical: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Code Scanner'),
//         backgroundColor: Colors.blue.shade600,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
//             onPressed: _toggleTorch,
//             tooltip: isTorchOn ? 'Turn off flash' : 'Turn on flash',
//           ),
//           IconButton(
//             icon: const Icon(Icons.flip_camera_ios),
//             onPressed: () => cameraController.switchCamera(),
//             tooltip: 'Switch camera',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Instructions
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: Colors.blue.shade50,
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.qr_code_scanner,
//                   color: Colors.blue.shade600,
//                   size: 32,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Point your camera at any QR code',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.blue.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Make sure the QR code is clearly visible and well-lit',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // QR Scanner
//           Expanded(
//             flex: 4,
//             child: Stack(
//               children: [
//                 MobileScanner(
//                   controller: cameraController,
//                   onDetect: _onDetect,
//                 ),

//                 // Scanning overlay
//                 Container(
//                   decoration: ShapeDecoration(
//                     shape: QrScannerOverlayShape(
//                       borderColor: Colors.blue.shade600,
//                       borderRadius: 10,
//                       borderLength: 30,
//                       borderWidth: 10,
//                       cutOutSize: 250,
//                     ),
//                   ),
//                 ),

//                 // Scanning indicator
//                 if (isScanning && !isProcessing)
//                   Positioned(
//                     bottom: 20,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.blue.shade300),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Scanning...',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // Bottom section with tips
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.lightbulb_outline, color: Colors.amber.shade600),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Tips for better scanning:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   '• Hold your phone steady\n'
//                   '• Ensure good lighting (use flash if needed)\n'
//                   '• Keep the QR code within the frame\n'
//                   '• Clean the camera lens if needed',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),

//                 // Manual entry option
//                 OutlinedButton.icon(
//                   onPressed: () {
//                     _showManualEntryDialog();
//                   },
//                   icon: const Icon(Icons.edit),
//                   label: const Text('Enter Text Manually'),
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 45),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showManualEntryDialog() {
//     final TextEditingController textController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Enter Text Manually'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Enter any text or URL you want to process:'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: textController,
//                 decoration: const InputDecoration(
//                   labelText: 'Text or URL',
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter text or URL here',
//                 ),
//                 maxLines: 3,
//                 minLines: 1,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 if (textController.text.isNotEmpty) {
//                   _handleScannedData(textController.text.trim());
//                 }
//               },
//               child: const Text('Process'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // Custom overlay shape for QR scanner
// class QrScannerOverlayShape extends ShapeBorder {
//   const QrScannerOverlayShape({
//     this.borderColor = Colors.red,
//     this.borderWidth = 3.0,
//     this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
//     this.borderRadius = 0,
//     this.borderLength = 40,
//     this.cutOutSize = 250,
//   });

//   final Color borderColor;
//   final double borderWidth;
//   final Color overlayColor;
//   final double borderRadius;
//   final double borderLength;
//   final double cutOutSize;

//   @override
//   EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//     return Path()
//       ..fillType = PathFillType.evenOdd
//       ..addPath(getOuterPath(rect), Offset.zero);
//   }

//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     Path getLeftTopPath(Rect rect) {
//       return Path()
//         ..moveTo(rect.left, rect.bottom)
//         ..lineTo(rect.left, rect.top)
//         ..lineTo(rect.right, rect.top);
//     }

//     return getLeftTopPath(rect)
//       ..lineTo(rect.right, rect.bottom)
//       ..lineTo(rect.left, rect.bottom)
//       ..lineTo(rect.left, rect.top);
//   }

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
//     final width = rect.width;
//     final borderWidthSize = width / 2;
//     final height = rect.height;
//     final borderOffset = borderWidth / 2;
//     final mBorderLength =
//         borderLength > borderWidthSize / 2 ? borderWidthSize / 2 : borderLength;
//     final mCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

//     final backgroundPaint = Paint()
//       ..color = overlayColor
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderWidth;

//     final boxPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOut;

//     final cutOutRect = Rect.fromLTWH(
//       rect.left + (width - mCutOutSize) / 2 + borderOffset,
//       rect.top + (height - mCutOutSize) / 2 + borderOffset,
//       mCutOutSize - borderOffset * 2,
//       mCutOutSize - borderOffset * 2,
//     );

//     canvas
//       ..saveLayer(rect, backgroundPaint)
//       ..drawRect(rect, backgroundPaint)
//       // Draw top right corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.right - mBorderLength,
//           cutOutRect.top,
//           cutOutRect.right,
//           cutOutRect.top + mBorderLength,
//           topRight: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw top left corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.left,
//           cutOutRect.top,
//           cutOutRect.left + mBorderLength,
//           cutOutRect.top + mBorderLength,
//           topLeft: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw bottom right corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.right - mBorderLength,
//           cutOutRect.bottom - mBorderLength,
//           cutOutRect.right,
//           cutOutRect.bottom,
//           bottomRight: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw bottom left corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.left,
//           cutOutRect.bottom - mBorderLength,
//           cutOutRect.left + mBorderLength,
//           cutOutRect.bottom,
//           bottomLeft: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       ..drawRRect(
//         RRect.fromRectAndRadius(
//           cutOutRect,
//           Radius.circular(borderRadius),
//         ),
//         boxPaint,
//       )
//       ..restore();
//   }

//   @override
//   ShapeBorder scale(double t) {
//     return QrScannerOverlayShape(
//       borderColor: borderColor,
//       borderWidth: borderWidth,
//       overlayColor: overlayColor,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/screens/pet_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final PetService _petService = PetService();
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // The QR code should contain the pet ID
      final petId = code.trim();

      if (petId.isEmpty) {
        throw Exception('Invalid QR code');
      }

      // Fetch pet details from Firestore
      final pet = await _petService.getPetById(petId);

      if (pet == null) {
        throw Exception('Pet not found');
      }

      // Navigate to pet detail screen
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PetDetailScreen(petId: petId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Allow scanning again after error
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _toggleTorch() async {
    await cameraController.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  void _switchCamera() async {
    await cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScannedCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Scanning overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(color: Colors.transparent),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(color: Colors.transparent),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.transparent, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(color: Colors.transparent),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.transparent,
                    child: const Center(
                      child: Text(
                        'Position QR code within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading pet details...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
