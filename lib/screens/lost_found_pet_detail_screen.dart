// import 'package:flutter/material.dart';
// import 'package:pettrack/models/lost_found_pet_model.dart';
// import 'package:pettrack/services/lost_found_pet_service.dart';
// import 'package:pettrack/services/auth_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.dart';

// class LostFoundPetDetailScreen extends StatefulWidget {
//   final String petId;

//   const LostFoundPetDetailScreen({super.key, required this.petId});

//   @override
//   State<LostFoundPetDetailScreen> createState() => _LostFoundPetDetailScreenState();
// }

// class _LostFoundPetDetailScreenState extends State<LostFoundPetDetailScreen> {
//   final LostFoundPetService _lostFoundPetService = LostFoundPetService();
//   final AuthService _authService = AuthService();
//   LostFoundPetModel? _pet;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPetDetails();
//   }

//   Future<void> _loadPetDetails() async {
//     try {
//       final pet = await _lostFoundPetService.getLostFoundPetById(widget.petId);
//       setState(() {
//         _pet = pet;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading pet details: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _makePhoneCall(String phoneNumber) async {
//     try {
//       String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
//       final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);
      
//       if (!await launchUrl(launchUri)) {
//         throw Exception('Could not launch $launchUri');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error making phone call: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _sendEmail() async {
//     try {
//       final Uri launchUri = Uri(
//         scheme: 'mailto',
//         path: 'petowner@example.com',
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
      
//       if (!await launchUrl(launchUri)) {
//         throw Exception('Could not launch $launchUri');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error sending email: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _openGoogleMaps() async {
//     try {
//       if (_pet?.latitude == null || _pet?.longitude == null) {
//         throw Exception('Pet location coordinates are not available');
//       }
      
//       final url = 'https://www.google.com/maps/search/?api=1&query=${_pet!.latitude},${_pet!.longitude}';
//       final uri = Uri.parse(url);
      
//       if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//         throw Exception('Could not launch $url');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error opening Google Maps: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Pet Details')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_pet == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Pet Details')),
//         body: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.red),
//               SizedBox(height: 16),
//               Text('Pet not found', style: TextStyle(fontSize: 18)),
//             ],
//           ),
//         ),
//       );
//     }

//     final pet = _pet!;
//     final formattedDate = DateFormat('MMMM d, yyyy').format(pet.timestamp);
//     final isCurrentUserPet = _authService.currentUser?.uid == pet.userId;
//     final phoneNumber = pet.contactPhone;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(pet.name),
//         backgroundColor: pet.status == 'lost' ? Colors.red.shade400 : Colors.green.shade400,
//         foregroundColor: Colors.white,
//         actions: [
//           if (isCurrentUserPet)
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Edit functionality coming soon')),
//                   );
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
//                   if (pet.status == 'lost')
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
//               tag: 'pet-image-${pet.id}',
//               child: CachedNetworkImage(
//                 imageUrl: pet.imageUrl,
//                 height: 300,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   height: 300,
//                   color: Colors.grey.shade300,
//                   child: const Center(child: CircularProgressIndicator()),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   height: 300,
//                   color: Colors.grey.shade300,
//                   child: const Icon(Icons.error, color: Colors.red, size: 50),
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
//                       color: pet.status == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: pet.status == 'lost' ? Colors.red.shade300 : Colors.green.shade300,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           pet.status == 'lost' ? Icons.search : Icons.pets,
//                           color: pet.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           pet.status.toUpperCase(),
//                           style: TextStyle(
//                             color: pet.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
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
//                 pet.name,
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
//                       _buildDetailRow(Icons.category, 'Breed', pet.breed),
//                       _buildDetailRow(Icons.palette, 'Color', pet.color),
//                       if (pet.petType != null)
//                         _buildDetailRow(Icons.pets, 'Type', pet.petType!),
//                       if (pet.size != null)
//                         _buildDetailRow(Icons.straighten, 'Size', pet.size!),
//                       if (pet.lastSeenDate != null)
//                         _buildDetailRow(
//                           Icons.calendar_today,
//                           pet.status == 'lost' ? 'Last Seen' : 'Found On',
//                           DateFormat('MMM d, yyyy').format(pet.lastSeenDate!),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Location card
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
//                         pet.status == 'lost' ? 'Last Known Location' : 'Found Location',
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
//                               pet.location,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: _openGoogleMaps,
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
//             if (pet.description != null && pet.description!.isNotEmpty)
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
//                           pet.description!,
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
//                               color: pet.status == 'lost'
//                                   ? Colors.red.shade400
//                                   : Colors.green.shade400,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               pet.status == 'lost'
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
//                               onPressed: () => _makePhoneCall(phoneNumber),
//                               icon: const Icon(Icons.phone),
//                               label: Text('Call $phoneNumber'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: pet.status == 'lost'
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

//                         // Email contact
//                         SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton.icon(
//                             onPressed: _sendEmail,
//                             icon: const Icon(Icons.email),
//                             label: Text(pet.status == 'lost' 
//                                 ? 'Email Pet Owner' 
//                                 : 'Email Finder'),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               side: BorderSide(
//                                 color: pet.status == 'lost'
//                                     ? Colors.red.shade400
//                                     : Colors.green.shade400,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 16),

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
//                                   pet.status == 'lost'
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
//                     child: Row(
//                       children: [
//                         Icon(Icons.person, color: Colors.blue.shade600),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'This is your pet post',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue.shade800,
//                                 ),
//                               ),
//                               Text(
//                                 'Use the menu (⋮) to edit, mark as found, or delete this post',
//                                 style: TextStyle(
//                                   color: Colors.blue.shade700,
//                                   fontSize: 14,
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
                
//                 try {
//                   await _lostFoundPetService.updateLostFoundPet(_pet!.id!, {
//                     'status': 'found',
//                   });
                  
//                   if (mounted) {
//                     setState(() {
//                       _pet = LostFoundPetModel(
//                         id: _pet!.id,
//                         name: _pet!.name,
//                         breed: _pet!.breed,
//                         color: _pet!.color,
//                         location: _pet!.location,
//                         imageUrl: _pet!.imageUrl,
//                         status: 'found',
//                         timestamp: _pet!.timestamp,
//                         userId: _pet!.userId,
//                         latitude: _pet!.latitude,
//                         longitude: _pet!.longitude,
//                         description: _pet!.description,
//                         contactPhone: _pet!.contactPhone,
//                         petType: _pet!.petType,
//                         size: _pet!.size,
//                         lastSeenDate: _pet!.lastSeenDate,
//                         tags: _pet!.tags,
//                       );
//                     });
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Pet marked as found successfully!'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Error updating pet status: $e'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
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
//               onPressed: () async {
//                 Navigator.of(context).pop();
                
//                 try {
//                   await _lostFoundPetService.deleteLostFoundPet(_pet!.id!);
                  
//                   if (mounted) {
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Pet post deleted successfully'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Error deleting pet: $e'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
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
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pettrack/screens/edit_lost_found_pet_screen.dart';
import 'package:intl/intl.dart';

class LostFoundPetDetailScreen extends StatefulWidget {
  final String petId;

  const LostFoundPetDetailScreen({super.key, required this.petId});

  @override
  State<LostFoundPetDetailScreen> createState() => _LostFoundPetDetailScreenState();
}

class _LostFoundPetDetailScreenState extends State<LostFoundPetDetailScreen> {
  final LostFoundPetService _lostFoundPetService = LostFoundPetService();
  final AuthService _authService = AuthService();
  LostFoundPetModel? _pet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPetDetails();
  }

  Future<void> _loadPetDetails() async {
    try {
      final pet = await _lostFoundPetService.getLostFoundPetById(widget.petId);
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

  // Helper method to get contact phone number
  String? _getContactPhone() {
    if (_pet == null) return null;
    
    // Check contactPhone field first
    if (_pet!.contactPhone != null && _pet!.contactPhone!.isNotEmpty) {
      return _pet!.contactPhone;
    }
    
    // Check contactInfo field as fallback

    return null;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);
      
      if (!await launchUrl(launchUri)) {
        throw Exception('Could not launch $launchUri');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    try {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: 'petowner@example.com',
        queryParameters: {
          'subject': 'Regarding your ${_pet!.status} pet "${_pet!.name}" on PetTrack',
          'body': 'Hi,\n\nI saw your ${_pet!.status} pet "${_pet!.name}" on PetTrack app.\n\n'
                  'Pet Details:\n'
                  '- Name: ${_pet!.name}\n'
                  '- Breed: ${_pet!.breed}\n'
                  '- Color: ${_pet!.color}\n'
                  '- Location: ${_pet!.location}\n\n'
                  'Please contact me if you need any information.\n\n'
                  'Best regards,\n'
                  '${_authService.currentUser?.email ?? "PetTrack User"}'
        },
      );
      
      if (!await launchUrl(launchUri)) {
        throw Exception('Could not launch $launchUri');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    try {
      if (_pet?.latitude == null || _pet?.longitude == null) {
        throw Exception('Pet location coordinates are not available');
      }
      
      final url = 'https://www.google.com/maps/search/?api=1&query=${_pet!.latitude},${_pet!.longitude}';
      final uri = Uri.parse(url);
      
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Google Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
// Add this method to your LostFoundPetDetailScreen
  void _navigateToEdit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditLostFoundPetScreen(pet: _pet!),
      ),
    );

    if (result == true) {
      // Reload pet details after edit
      _loadPetDetails();
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
    final formattedDate = DateFormat('MMMM d, yyyy').format(pet.timestamp);
    final isCurrentUserPet = _authService.currentUser?.uid == pet.userId;
    final phoneNumber = _getContactPhone(); // FIXED: Use helper method

    // DEBUG: Print contact information
    print('=== DEBUG: Contact Information ===');
    print('contactPhone: ${pet.contactPhone}');
    print('Extracted phone: $phoneNumber');
    print('Current user: ${_authService.currentUser?.uid}');
    print('Pet owner: ${pet.userId}');
    print('Is current user pet: $isCurrentUserPet');

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: pet.status == 'lost' ? Colors.red.shade400 : Colors.green.shade400,
        foregroundColor: Colors.white,
        actions: [
          if (isCurrentUserPet)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEdit();
                } else if (value == 'delete') {
                  _showDeleteConfirmation();
                } else if (value == 'mark_found') {
                  _markAsFound();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (pet.status == 'lost')
                    const PopupMenuItem<String>(
                      value: 'mark_found',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Mark as Found'),
                        ],
                      ),
                    ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet image
            Hero(
              tag: 'pet-image-${pet.id}',
              child: CachedNetworkImage(
                imageUrl: pet.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error, color: Colors.red, size: 50),
                ),
              ),
            ),
            
            // Status badge and date
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: pet.status == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: pet.status == 'lost' ? Colors.red.shade300 : Colors.green.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pet.status == 'lost' ? Icons.search : Icons.pets,
                          color: pet.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.status.toUpperCase(),
                          style: TextStyle(
                            color: pet.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Posted $formattedDate',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Pet name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                pet.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pet details card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pet Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.category, 'Breed', pet.breed),
                      _buildDetailRow(Icons.palette, 'Color', pet.color),
                      if (pet.petType != null)
                        _buildDetailRow(Icons.pets, 'Type', pet.petType!),
                      if (pet.size != null)
                        _buildDetailRow(Icons.straighten, 'Size', pet.size!),
                      if (pet.lastSeenDate != null)
                        _buildDetailRow(
                          Icons.calendar_today,
                          pet.status == 'lost' ? 'Last Seen' : 'Found On',
                          DateFormat('MMM d, yyyy').format(pet.lastSeenDate!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Location card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.status == 'lost' ? 'Last Known Location' : 'Found Location',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pet.location,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open in Google Maps'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),

            const SizedBox(height: 16),

            // Description card
            if (pet.description != null && pet.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Details',
                          style: TextStyle(
                            fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          pet.description!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
            // Contact section - Show for non-owners
            if (!isCurrentUserPet)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_phone,
                              color: pet.status == 'lost'
                                  ? Colors.red.shade400
                                  : Colors.green.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              pet.status == 'lost'
                                  ? 'Contact Pet Owner'
                                  : 'Contact Finder',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Maps style contact bar
                        if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Phone number display
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          phoneNumber,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          pet.status == 'lost'
                                              ? 'Pet Owner'
                                              : 'Finder',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Call button
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Material(
                                    color: pet.status == 'lost'
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _makePhoneCall(phoneNumber),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Call',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Email contact button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _sendEmail,
                            icon: const Icon(Icons.email),
                            label: Text(pet.status == 'lost'
                                ? 'Send Email to Owner'
                                : 'Send Email to Finder'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(
                                color: pet.status == 'lost'
                                    ? Colors.red.shade400
                                    : Colors.green.shade400,
                                width: 1.5,
                              ),
                              foregroundColor: pet.status == 'lost'
                                  ? Colors.red.shade600
                                  : Colors.green.shade600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Contact information display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info,
                                      color: Colors.blue.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contact Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                phoneNumber != null && phoneNumber.isNotEmpty
                                    ? '• Tap "Call" to contact directly\n• Use email for detailed messages\n• Be respectful and provide helpful information'
                                    : '• Send an email through your email app\n• No phone number was provided\n• Be respectful and provide helpful information',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Safety tip
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber,
                                  color: Colors.amber.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pet.status == 'lost'
                                      ? 'Safety Tip: If you find this pet, approach gently as they may be scared or confused.'
                                      : 'Safety Tip: Please verify pet ownership by asking for photos or vet records before returning.',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // // Contact section - Show for non-owners
            // if (!isCurrentUserPet)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Card(
            //       elevation: 2,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(16),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Row(
            //               children: [
            //                 Icon(
            //                   Icons.contact_phone,
            //                   color: pet.status == 'lost'
            //                       ? Colors.red.shade400
            //                       : Colors.green.shade400,
            //                 ),
            //                 const SizedBox(width: 8),
            //                 Text(
            //                   pet.status == 'lost'
            //                       ? 'Contact Pet Owner'
            //                       : 'Contact Finder',
            //                   style: const TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(height: 16),

            //             // Phone contact (if available)
            //             if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
            //               SizedBox(
            //                 width: double.infinity,
            //                 child: ElevatedButton.icon(
            //                   onPressed: () => _makePhoneCall(phoneNumber),
            //                   icon: const Icon(Icons.phone),
            //                   label: Text('Call $phoneNumber'),
            //                   style: ElevatedButton.styleFrom(
            //                     backgroundColor: pet.status == 'lost'
            //                         ? Colors.red.shade400
            //                         : Colors.green.shade400,
            //                     foregroundColor: Colors.white,
            //                     padding:
            //                         const EdgeInsets.symmetric(vertical: 12),
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(8),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               const SizedBox(height: 12),
            //             ],

            //             // Email contact - Always available
            //             SizedBox(
            //               width: double.infinity,
            //               child: OutlinedButton.icon(
            //                 onPressed: _sendEmail,
            //                 icon: const Icon(Icons.email),
            //                 label: Text(pet.status == 'lost'
            //                     ? 'Email Pet Owner'
            //                     : 'Email Finder'),
            //                 style: OutlinedButton.styleFrom(
            //                   padding: const EdgeInsets.symmetric(vertical: 12),
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(8),
            //                   ),
            //                   side: BorderSide(
            //                     color: pet.status == 'lost'
            //                         ? Colors.red.shade400
            //                         : Colors.green.shade400,
            //                   ),
            //                 ),
            //               ),
            //             ),

            //             const SizedBox(height: 16),

            //             // Contact information display
            //             Container(
            //               padding: const EdgeInsets.all(12),
            //               decoration: BoxDecoration(
            //                 color: Colors.blue.shade50,
            //                 borderRadius: BorderRadius.circular(8),
            //                 border: Border.all(color: Colors.blue.shade200),
            //               ),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Row(
            //                     children: [
            //                       Icon(Icons.info,
            //                           color: Colors.blue.shade600, size: 20),
            //                       const SizedBox(width: 8),
            //                       Text(
            //                         'Contact Information',
            //                         style: TextStyle(
            //                           fontWeight: FontWeight.bold,
            //                           color: Colors.blue.shade800,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   const SizedBox(height: 8),
            //                   Text(
            //                     phoneNumber != null && phoneNumber.isNotEmpty
            //                         ? '• Call directly using the phone number: $phoneNumber\n• Send an email through your email app'
            //                         : '• Send an email through your email app\n• No phone number was provided by the owner',
            //                     style: TextStyle(
            //                       color: Colors.blue.shade700,
            //                       fontSize: 13,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),

            //             const SizedBox(height: 12),

            //             // Safety tip
            //             Container(
            //               padding: const EdgeInsets.all(12),
            //               decoration: BoxDecoration(
            //                 color: Colors.amber.shade50,
            //                 borderRadius: BorderRadius.circular(8),
            //                 border: Border.all(color: Colors.amber.shade200),
            //               ),
            //               child: Row(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Icon(Icons.warning_amber,
            //                       color: Colors.amber.shade700, size: 20),
            //                   const SizedBox(width: 8),
            //                   Expanded(
            //                     child: Text(
            //                       pet.status == 'lost'
            //                           ? 'Safety Tip: If you find this pet, approach gently as they may be scared or confused.'
            //                           : 'Safety Tip: Please verify pet ownership by asking for photos or vet records before returning.',
            //                       style: TextStyle(
            //                         color: Colors.amber.shade800,
            //                         fontSize: 12,
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),

            // Owner's own pet message
            if (isCurrentUserPet)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'This is your pet post',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  Text(
                                    'Use the menu (⋮) to edit, mark as found, or delete this post',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green.shade600, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Contact info: $phoneNumber',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsFound() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Found'),
          content:
              const Text('Are you sure you want to mark this pet as found?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await _lostFoundPetService.updateLostFoundPet(_pet!.id!, {
                    'status': 'found',
                  });

                  if (mounted) {
                    setState(() {
                      _pet = LostFoundPetModel(
                        id: _pet!.id,
                        name: _pet!.name,
                        breed: _pet!.breed,
                        color: _pet!.color,
                        location: _pet!.location,
                        imageUrl: _pet!.imageUrl,
                        status: 'found',
                        timestamp: _pet!.timestamp,
                        userId: _pet!.userId,
                        latitude: _pet!.latitude,
                        longitude: _pet!.longitude,
                        description: _pet!.description,
                        contactPhone: _pet!.contactPhone,
                        petType: _pet!.petType,
                        size: _pet!.size,
                        lastSeenDate: _pet!.lastSeenDate,
                        tags: _pet!.tags,
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pet marked as found successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating pet status: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Mark as Found'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Pet Post'),
          content: const Text(
              'Are you sure you want to delete this pet post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await _lostFoundPetService.deleteLostFoundPet(_pet!.id!);

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pet post deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting pet: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
