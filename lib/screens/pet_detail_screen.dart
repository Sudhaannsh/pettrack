// import 'package:flutter/material.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/services/auth_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
// // import 'package:pettrack/screens/map_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PetDetailScreen extends StatefulWidget {
//   final String? petId;

//   const PetDetailScreen({super.key, required this.petId});

//   @override
//   _PetDetailScreenState createState() => _PetDetailScreenState();
// }

// class _PetDetailScreenState extends State<PetDetailScreen> {
//   final PetService _petService = PetService();
//   final AuthService _authService = AuthService();
//   bool _isLoading = true;
//   PetModel? _pet;
//   String _errorMessage = '';
//   User? _petOwner;

//   @override
//   void initState() {
//     super.initState();
//     _loadPetDetails();
//   }

//   Future<void> _loadPetDetails() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       if (widget.petId == null) {
//         throw Exception("Pet ID is null");
//       }
//       final pet = await _petService.getPetById(widget.petId!);
//       setState(() {
//         _pet = pet;
//       });

//       // Load pet owner details if pet is found
//       if (pet != null) {
//         await _loadPetOwnerDetails(pet.userId);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading pet details: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadPetOwnerDetails(String userId) async {
//     try {
//       // Get user details from Firebase Auth or Firestore
//       // For now, we'll use the current user's email as a fallback
//       // In a real app, you'd fetch user details from Firestore
//       _petOwner = FirebaseAuth.instance.currentUser;
//     } catch (e) {
//       print('Error loading pet owner details: $e');
//     }
//   }

//   // Extract phone number from description
//   String? _extractPhoneNumber() {
//     if (_pet?.description == null) return null;

//     final phoneRegex = RegExp(r'Contact:\s*([+]?[\d\s\-KATEX_INLINE_OPENKATEX_INLINE_CLOSE]+)');
//     final match = phoneRegex.firstMatch(_pet!.description!);
//     return match?.group(1)?.trim();
//   }

//   // Extract pet type from description
//   String? _extractPetType() {
//     if (_pet?.description == null) return null;

//     final typeRegex = RegExp(r'Type:\s*([^,\n]+)');
//     final match = typeRegex.firstMatch(_pet!.description!);
//     return match?.group(1)?.trim();
//   }

//   // Extract pet size from description
//   String? _extractPetSize() {
//     if (_pet?.description == null) return null;

//     final sizeRegex = RegExp(r'Size:\s*([^,\n]+)');
//     final match = sizeRegex.firstMatch(_pet!.description!);
//     return match?.group(1)?.trim();
//   }

//   // Extract date from description
//   String? _extractDate() {
//     if (_pet?.description == null) return null;

//     final dateRegex = RegExp(r'(Last seen|Found):\s*(\d{1,2}/\d{1,2}/\d{4})');
//     final match = dateRegex.firstMatch(_pet!.description!);
//     return match?.group(2)?.trim();
//   }

//   Future<void> _makePhoneCall(String phoneNumber) async {
//     try {
//       // Clean the phone number - remove all non-digit characters except +
//       String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

//       final Uri launchUri = Uri(
//         scheme: 'tel',
//         path: cleanedNumber,
//       );

//       print('Attempting to call: $cleanedNumber with URI: $launchUri'); // Debug log

//       // Use the updated launchUrl method
//       if (!await launchUrl(launchUri)) {
//         throw Exception('Could not launch $launchUri');
//       }
//     } catch (e) {
//       print('Phone call error: $e'); // Debug log
//       _showErrorSnackBar('Error making phone call: $e');
//     }
//   }

//   Future<void> _sendEmailToOwner() async {
//     try {
//       // In a real app, you would fetch the owner's email from Firestore user collection
//       // For now, we'll create a contact form or use a placeholder
//       String ownerEmail = 'petowner@example.com'; // This should be fetched from user data

//       final Uri launchUri = Uri(
//         scheme: 'mailto',
//         path: ownerEmail,
//         queryParameters: {
//           'subject': 'Regarding your ${_pet!.status} pet "${_pet!.name}" on PetTrack',
//           'body': 'Hi,\n\nI saw your ${_pet!.status} pet "${_pet!.name}" on PetTrack app.\n\n'
//                   'Pet Details:\n'
//                   '- Name: ${_pet!.name}\n'
//                   '- Breed: ${_pet!.breed}\n'
//                   '- Color: ${_pet!.color}\n'
//                   '- Location: ${_pet!.location}\n\n'
//                   'Please contact me if you need any information.\n\n'
//                   'Best regards,\n'
//                   '${_authService.currentUser?.email ?? "PetTrack User"}'
//         },
//       );

//       print('Attempting to send email to: $ownerEmail with URI: $launchUri'); // Debug log

//       // Use the updated launchUrl method
//       if (!await launchUrl(launchUri)) {
//         throw Exception('Could not launch $launchUri');
//       }
//     } catch (e) {
//       print('Email error: $e'); // Debug log
//       _showErrorSnackBar('Error sending email: $e');
//     }
//   }

//   Future<void> _openGoogleMaps() async {
//     try {
//       // Check if coordinates are valid
//       if (_pet?.latitude == null || _pet?.longitude == null) {
//         throw Exception('Pet location coordinates are not available');
//       }

//       print('Pet coordinates: ${_pet!.latitude}, ${_pet!.longitude}'); // Debug log

//       final url = 'https://www.google.com/maps/search/?api=1&query=${_pet!.latitude},${_pet!.longitude}';
//       final uri = Uri.parse(url);

//       print('Attempting to open maps with URL: $url'); // Debug log

//       // Use the updated launchUrl method
//       if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//         throw Exception('Could not launch $url');
//       }
//     } catch (e) {
//       print('Error opening maps: $e'); // Debug log
//       _showErrorSnackBar('Error opening Google Maps: $e');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Pet Details'),
//         ),
//         body: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Pet Details'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 64,
//                 color: Colors.red.shade400,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _loadPetDetails,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_pet == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Pet Details'),
//         ),
//         body: const Center(
//           child: Text('Pet not found'),
//         ),
//       );
//     }

//     final formattedDate = DateFormat('MMMM d, yyyy').format(_pet!.timestamp);
//     final isCurrentUserPet = _authService.currentUser?.uid == _pet!.userId;
//     final phoneNumber = _extractPhoneNumber();
//     final petType = _extractPetType();
//     final petSize = _extractPetSize();
//     final lastSeenDate = _extractDate();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_pet!.name),
//         backgroundColor: _pet!.status == 'lost' ? Colors.red.shade400 : Colors.green.shade400,
//         foregroundColor: Colors.white,
//         actions: [
//           if (isCurrentUserPet)
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   _showInfoSnackBar('Edit functionality coming soon');
//                 } else if (value == 'delete') {
//                   _showDeleteConfirmation();
//                 } else if (value == 'mark_found') {
//                   _markAsFound();
//                 }
//               },
//               itemBuilder: (BuildContext context) {
//                 return [
//                   const PopupMenuItem<String>(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(Icons.edit),
//                         SizedBox(width: 8),
//                         Text('Edit'),
//                       ],
//                     ),
//                   ),
//                   if (_pet!.status == 'lost')
//                     const PopupMenuItem<String>(
//                       value: 'mark_found',
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.green),
//                           SizedBox(width: 8),
//                           Text('Mark as Found'),
//                         ],
//                       ),
//                     ),
//                   const PopupMenuItem<String>(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text('Delete'),
//                       ],
//                     ),
//                   ),
//                 ];
//               },
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Pet image
//             Hero(
//               tag: 'pet-image-${_pet!.id}',
//               child: CachedNetworkImage(
//                 imageUrl: _pet!.imageUrl,
//                 height: 300,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   height: 300,
//                   color: Colors.grey.shade300,
//                   child: const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   height: 300,
//                   color: Colors.grey.shade300,
//                   child: const Icon(
//                     Icons.error,
//                     color: Colors.red,
//                     size: 50,
//                   ),
//                 ),
//               ),
//             ),

//             // Status badge and date
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _pet!.status == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: _pet!.status == 'lost' ? Colors.red.shade300 : Colors.green.shade300,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           _pet!.status == 'lost' ? Icons.search : Icons.pets,
//                           color: _pet!.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _pet!.status.toUpperCase(),
//                           style: TextStyle(
//                             color: _pet!.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     'Posted $formattedDate',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Pet name
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 _pet!.name,
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Pet details card
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Pet Information',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(Icons.category, 'Breed', _pet!.breed),
//                       _buildDetailRow(Icons.palette, 'Color', _pet!.color),
//                       if (petType != null)
//                         _buildDetailRow(Icons.pets, 'Type', petType),
//                       if (petSize != null)
//                         _buildDetailRow(Icons.straighten, 'Size', petSize),
//                       if (lastSeenDate != null)
//                         _buildDetailRow(
//                                                     Icons.calendar_today,
//                           _pet!.status == 'lost' ? 'Last Seen' : 'Found On',
//                           lastSeenDate,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//                         // Location card
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _pet!.status == 'lost' ? 'Last Known Location' : 'Found Location',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, color: Colors.red.shade400),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               _pet!.location,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             print('Google Maps button pressed'); // Debug log
//                             _openGoogleMaps();
//                           },
//                           icon: const Icon(Icons.open_in_new),
//                           label: const Text('Open in Google Maps'),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Description card
//             if (_pet!.description != null && _pet!.description!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Additional Details',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           _cleanDescription(_pet!.description!),
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade800,
//                             height: 1.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 16),

//             // Contact section - Show for non-owners
//             if (!isCurrentUserPet)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.contact_phone,
//                               color: _pet!.status == 'lost'
//                                   ? Colors.red.shade400
//                                   : Colors.green.shade400,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               _pet!.status == 'lost'
//                                   ? 'Contact Pet Owner'
//                                   : 'Contact Finder',
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // Phone contact (if available)
//                         if (phoneNumber != null) ...[
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 print('Phone button pressed: $phoneNumber'); // Debug log
//                                 _makePhoneCall(phoneNumber);
//                               },
//                               icon: const Icon(Icons.phone),
//                               label: Text('Call $phoneNumber'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: _pet!.status == 'lost'
//                                     ? Colors.red.shade400
//                                     : Colors.green.shade400,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                         ],

//                         // Email contact - Always available
//                         SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               print('Email button pressed'); // Debug log
//                               _sendEmailToOwner();
//                             },
//                             icon: const Icon(Icons.email),
//                             label: Text(_pet!.status == 'lost'
//                                 ? 'Email Pet Owner'
//                                 : 'Email Finder'),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               side: BorderSide(
//                                 color: _pet!.status == 'lost'
//                                     ? Colors.red.shade400
//                                     : Colors.green.shade400,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // Contact instructions
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue.shade200),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.info, color: Colors.blue.shade600, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Contact Information',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blue.shade800,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 phoneNumber != null
//                                     ? '• Call directly using the phone number provided\n• Send an email through your email app'
//                                     : '• Send an email through your email app\n• No phone number was provided by the owner',
//                                 style: TextStyle(
//                                   color: Colors.blue.shade700,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 12),

//                         // Safety tip
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.amber.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.amber.shade200),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   _pet!.status == 'lost'
//                                       ? 'Safety Tip: If you find this pet, approach gently as they may be scared or confused.'
//                                       : 'Safety Tip: Please verify pet ownership by asking for photos or vet records before returning.',
//                                   style: TextStyle(
//                                     color: Colors.amber.shade800,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             // Owner's own pet message
//             if (isCurrentUserPet)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Card(
//                   elevation: 2,
//                   color: Colors.blue.shade50,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.person, color: Colors.blue.shade600),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'This is your pet post',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blue.shade800,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Use the menu (⋮) to edit, mark as found, or delete this post',
//                                     style: TextStyle(
//                                       color: Colors.blue.shade700,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (phoneNumber != null) ...[
//                           const SizedBox(height: 12),
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade50,
//                               borderRadius: BorderRadius.circular(6),
//                               border: Border.all(color: Colors.green.shade200),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   'Contact info: $phoneNumber',
//                                   style: TextStyle(
//                                     color: Colors.green.shade700,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey.shade600),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 80,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _cleanDescription(String description) {
//     // Remove the structured data and return only the user-written description
//     final lines = description.split('\n');
//     final cleanLines = <String>[];

//     for (final line in lines) {
//       // Skip lines that contain structured data
//       if (!line.startsWith('Contact:') &&
//           !line.startsWith('Last seen:') &&
//           !line.startsWith('Found:') &&
//           !line.startsWith('Type:') &&
//           !line.startsWith('Size:')) {
//         cleanLines.add(line);
//       }
//     }

//     return cleanLines.join('\n').trim();
//   }

//   void _showInfoSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.blue,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   void _markAsFound() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Mark as Found'),
//           content: const Text('Are you sure you want to mark this pet as found?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();

//                 // Show loading
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (context) => const Center(child: CircularProgressIndicator()),
//                 );

//                 try {
//                   // Update pet status to found
//                   final updatedPet = PetModel(
//                     id: _pet!.id,
//                     name: _pet!.name,
//                     breed: _pet!.breed,
//                     color: _pet!.color,
//                     location: _pet!.location,
//                     imageUrl: _pet!.imageUrl,
//                     status: 'found',
//                     timestamp: _pet!.timestamp,
//                     userId: _pet!.userId,
//                     latitude: _pet!.latitude,
//                     longitude: _pet!.longitude,
//                     description: _pet!.description,
//                   );

//                   await _petService.updatePet(updatedPet);

//                   if (mounted) {
//                     Navigator.of(context).pop(); // Close loading
//                     setState(() {
//                       _pet = updatedPet;
//                     });
//                     _showSuccessSnackBar('Pet marked as found successfully!');
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     Navigator.of(context).pop(); // Close loading
//                     _showErrorSnackBar('Error updating pet status: $e');
//                   }
//                 }
//               },
//               child: const Text('Mark as Found'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDeleteConfirmation() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Pet Post'),
//           content: const Text('Are you sure you want to delete this pet post? This action cannot be undone.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//                             onPressed: () async {
//                 Navigator.of(context).pop();

//                 // Show loading dialog
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (context) =>
//                       const Center(child: CircularProgressIndicator()),
//                 );

//                 try {
//                   await _petService.deletePet(_pet!.id!, _pet!.imageUrl);

//                   if (mounted) {
//                     Navigator.of(context).pop(); // Close loading dialog
//                     Navigator.of(context).pop(); // Go back to previous screen

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Pet post deleted successfully'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     Navigator.of(context).pop(); // Close loading dialog
//                     _showErrorSnackBar('Error deleting pet: $e');
//                   }
//                 }
//               },
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final PetService _petService = PetService();
  PetModel? _pet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPetDetails();
  }

  Future<void> _loadPetDetails() async {
    try {
      final pet = await _petService.getPetById(widget.petId);
      setState(() {
        _pet = pet;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pet details: $e')),
        );
      }
    }
  }

  Future<void> _contactOwner() async {
    if (_pet?.ownerContact != null) {
      final Uri phoneUri = Uri(scheme: 'tel', path: _pet!.ownerContact);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Pet not found', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    final pet = _pet!;
    final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          if (pet.ownerContact != null)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: _contactOwner,
              tooltip: 'Contact Owner',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Hero(
              tag: 'pet_${pet.id}',
              child: CachedNetworkImage(
                imageUrl: pet.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.pets, size: 100),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pet.status == 'lost'
                          ? Colors.red.shade100
                          : pet.status == 'found'
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pet.status.toUpperCase(),
                      style: TextStyle(
                        color: pet.status == 'lost'
                            ? Colors.red.shade900
                            : pet.status == 'found'
                                ? Colors.green.shade900
                                : Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pet Name
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Breed and Date
                  Row(
                    children: [
                      Icon(Icons.pets, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pet.breed,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Posted on $formattedDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Details Section
                  _buildDetailSection('Details', [
                    if (pet.color.isNotEmpty)
                      _buildDetailRow('Color', pet.color, Icons.palette),
                    if (pet.age.isNotEmpty)
                      _buildDetailRow('Age', pet.age, Icons.cake),
                    if (pet.weight.isNotEmpty)
                      _buildDetailRow(
                          'Weight', pet.weight, Icons.fitness_center),
                    if (pet.location.isNotEmpty)
                      _buildDetailRow(
                          'Location', pet.location, Icons.location_on),
                  ]),

                  // Description
                  if (pet.description != null &&
                      pet.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Description', [
                      Text(
                        pet.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ]),
                  ],

                  // Medical Notes
                  if (pet.medicalNotes != null &&
                      pet.medicalNotes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Medical Information', [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medical_services,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pet.medicalNotes!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade900,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 32),

                  // Contact Owner Button
                  if (pet.ownerContact != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _contactOwner,
                        icon: const Icon(Icons.phone),
                        label: const Text('Contact Owner'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
