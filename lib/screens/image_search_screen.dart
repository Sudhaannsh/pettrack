// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pettrack/services/image_search_service.dart';
// import 'package:pettrack/screens/pet_detail_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';

// class ImageSearchScreen extends StatefulWidget {
//   const ImageSearchScreen({super.key});

//   @override
//   State<ImageSearchScreen> createState() => _ImageSearchScreenState();
// }

// class _ImageSearchScreenState extends State<ImageSearchScreen> {
//   final ImagePicker _imagePicker = ImagePicker();
//   final ImageSearchService _imageSearchService = ImageSearchService();
  
//   File? _selectedImage;
//   List<PetMatchResult> _searchResults = [];
//   bool _isSearching = false;
//   String _searchType = 'lost';

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: source,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//           _searchResults = [];
//         });
//       }
//     } catch (e) {
//       _showErrorSnackBar('Error picking image: $e');
//     }
//   }

//   Future<void> _searchSimilarPets() async {
//     if (_selectedImage == null) {
//       _showErrorSnackBar('Please select an image first');
//       return;
//     }

//     setState(() {
//       _isSearching = true;
//     });

//     try {
//       List<PetMatchResult> results = await _imageSearchService.searchSimilarPets(
//         _selectedImage!,
//         _searchType,
//       );

//       setState(() {
//         _searchResults = results;
//       });

//       if (results.isEmpty) {
//         _showInfoSnackBar('No similar pets found. Try adjusting your search or check back later.');
//       } else {
//         _showInfoSnackBar('Found ${results.length} similar pets! Notifications sent to pet owners.');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Error searching: $e');
//     } finally {
//       setState(() {
//         _isSearching = false;
//       });
//     }
//   }

//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Select Image Source',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.camera_alt),
//                         label: const Text('Camera'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _pickImage(ImageSource.camera);
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.photo_library),
//                         label: const Text('Gallery'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _pickImage(ImageSource.gallery);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   void _showInfoSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.blue),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AI Pet Search'),
//         backgroundColor: Colors.blue.shade600,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Search type selector
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'What are you looking for?',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: RadioListTile<String>(
//                             title: const Text('Lost Pet'),
//                             subtitle: const Text('Find similar found pets'),
//                             value: 'lost',
//                             groupValue: _searchType,
//                             onChanged: (value) {
//                               setState(() {
//                                 _searchType = value!;
//                                 _searchResults = [];
//                               });
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           child: RadioListTile<String>(
//                             title: const Text('Found Pet'),
//                             subtitle: const Text('Find similar lost pets'),
//                             value: 'found',
//                             groupValue: _searchType,
//                             onChanged: (value) {
//                               setState(() {
//                                 _searchType = value!;
//                                 _searchResults = [];
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Image selection
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Upload Pet Image',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     GestureDetector(
//                       onTap: _showImageSourceDialog,
//                       child: Container(
//                         height: 200,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300, width: 2),
//                         ),
//                         child: _selectedImage != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Image.file(
//                                   _selectedImage!,
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                 ),
//                               )
//                             : const Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
//                                   SizedBox(height: 10),
//                                   Text('Tap to add a photo', style: TextStyle(color: Colors.grey, fontSize: 16)),
//                                   SizedBox(height: 4),
//                                   Text('AI will analyze the image', style: TextStyle(color: Colors.grey, fontSize: 12)),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Search button
//             ElevatedButton.icon(
//               onPressed: _selectedImage != null && !_isSearching ? _searchSimilarPets : null,
//               icon: _isSearching 
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                     )
//                   : const Icon(Icons.search),
//               label: Text(_isSearching ? 'Analyzing with AI...' : 'Search with AI'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Search results
//             if (_searchResults.isNotEmpty) ...[
//               Text(
//                 'AI Found ${_searchResults.length} Similar Pets',
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _searchResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _searchResults[index];
//                   return _buildSearchResultCard(result);
//                 },
//               ),
//             ],

//             // AI Info section
//             const SizedBox(height: 24),
//             Card(
//               color: Colors.green.shade50,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.psychology, color: Colors.green.shade600),
//                         const SizedBox(width: 8),
//                         Text(
//                           'AI-Powered Matching:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green.shade800,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '• Advanced image recognition using MobileNet\n'
//                       '• Analyzes colors, patterns, and features\n'
//                       '• Automatic notifications to pet owners\n'
//                       '• 85%+ accuracy in pet matching\n'
//                       '• Works offline for faster processing',
//                       style: TextStyle(color: Colors.green.shade700),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchResultCard(PetMatchResult result) {
//     final formattedDate = DateFormat('MMM d, yyyy').format(result.pet.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => PetDetailScreen(petId: result.pet.id!),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Pet image
//                   Hero(
//                     tag: 'search-pet-image-${result.pet.id}',
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: CachedNetworkImage(
//                         imageUrl: result.pet.imageUrl,
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.grey.shade300,
//                           child: const Icon(Icons.pets),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.grey.shade300,
//                           child: const Icon(Icons.error),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
                  
//                   // Pet details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               result.pet.name,
//                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: result.pet.status == 'lost' 
//                                     ? Colors.red.shade100 
//                                     : Colors.green.shade100,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 result.pet.status.toUpperCase(),
//                                 style: TextStyle(
//                                   color: result.pet.status == 'lost' 
//                                       ? Colors.red.shade800 
//                                       : Colors.green.shade800,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${result.pet.breed} • ${result.pet.color}',
//                           style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 result.pet.location,
//                                                                 style: TextStyle(
//                                     fontSize: 12, color: Colors.grey.shade600),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           formattedDate,
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade500),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // AI Match details
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.psychology,
//                             color: Colors.blue.shade600, size: 16),
//                         const SizedBox(width: 6),
//                         Text(
//                           'AI Match: ${result.similarity.toStringAsFixed(1)}%',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue.shade800,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: _getSimilarityColor(result.similarity),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             _getSimilarityLabel(result.similarity),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (result.matchReasons.isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         'Match reasons:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: Colors.blue.shade700,
//                           fontSize: 12,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       ...result.matchReasons
//                           .map((reason) => Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 8, bottom: 2),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.check_circle,
//                                         size: 12, color: Colors.green.shade600),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         reason,
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.blue.shade700,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ))
//                           .toList(),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getSimilarityColor(double similarity) {
//     if (similarity >= 80) return Colors.green;
//     if (similarity >= 70) return Colors.orange;
//     return Colors.red;
//   }

//   String _getSimilarityLabel(double similarity) {
//     if (similarity >= 80) return 'High Match';
//     if (similarity >= 70) return 'Good Match';
//     return 'Possible Match';
//   }
// }
