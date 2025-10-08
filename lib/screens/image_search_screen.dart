// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pettrack/services/mobilenet_similarity_service.dart';
// import 'package:pettrack/screens/pet_detail_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class ImageSearchScreen extends StatefulWidget {
//   const ImageSearchScreen({super.key});

//   @override
//   State<ImageSearchScreen> createState() => _ImageSearchScreenState();
// }

// class _ImageSearchScreenState extends State<ImageSearchScreen> {
//   final MobileNetSimilarityService _similarityService = MobileNetSimilarityService();
//   final ImagePicker _imagePicker = ImagePicker();
  
//   File? _selectedImage;
//   List<SimilarPetResult> _searchResults = [];
//   bool _isSearching = false;
//   bool _isInitializing = false;
//   String _errorMessage = '';
//   String _statusMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeModel();
//   }

//   Future<void> _initializeModel() async {
//     setState(() {
//       _isInitializing = true;
//       _statusMessage = 'Loading AI model...';
//     });

//     try {
//       await _similarityService.initializeModel();
//       setState(() {
//         _statusMessage = 'Model loaded successfully!';
//       });
      
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() {
//             _statusMessage = '';
//           });
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load AI model: $e';
//       });
//     } finally {
//       setState(() {
//         _isInitializing = false;
//       });
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//           _searchResults = [];
//           _errorMessage = '';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error picking image: $e';
//       });
//     }
//   }

//   Future<void> _searchSimilarPets() async {
//     if (_selectedImage == null) {
//       setState(() {
//         _errorMessage = 'Please select an image first';
//       });
//       return;
//     }

//     setState(() {
//       _isSearching = true;
//       _errorMessage = '';
//       _searchResults = [];
//       _statusMessage = 'Analyzing image...';
//     });

//     try {
//       final results = await _similarityService.searchSimilarPets(_selectedImage!);
      
//       setState(() {
//         _searchResults = results;
//         _statusMessage = results.isEmpty 
//             ? 'No similar pets found' 
//             : 'Found ${results.length} similar pets';
        
//         if (results.isEmpty) {
//           _errorMessage = 'No similar pets found. Try a different image or check if the image contains a clear view of a pet.';
//         }
//       });

//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() {
//             _statusMessage = '';
//           });
//         }
//       });
      
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Search failed: $e';
//         _statusMessage = '';
//       });
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
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Select Image Source',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.camera_alt),
//                       label: const Text('Camera'),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.camera);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.photo_library),
//                       label: const Text('Gallery'),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.gallery);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Find Similar Pets'),
//         backgroundColor: Colors.purple.shade400,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.help_outline),
//             onPressed: () => _showHelpDialog(),
//           ),
//         ],
//       ),
//       body: _isInitializing
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading AI model...'),
//                   SizedBox(height: 8),
//                   Text(
//                     'This may take a few moments on first launch',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildInstructionsCard(),
//                   const SizedBox(height: 24),
//                   _buildImageSelectionArea(),
//                   if (_statusMessage.isNotEmpty) ...[
//                     const SizedBox(height: 16),
//                     _buildStatusMessage(),
//                   ],
//                   if (_errorMessage.isNotEmpty) ...[
//                     const SizedBox(height: 16),
//                     _buildErrorMessage(),
//                   ],
//                   const SizedBox(height: 24),
//                   _buildSearchButton(),
//                   if (_searchResults.isNotEmpty) ...[
//                     const SizedBox(height: 32),
//                     _buildSearchResults(),
//                   ],
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildInstructionsCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.lightbulb, color: Colors.blue.shade600),
//               const SizedBox(width: 8),
//               Text(
//                 'How it works:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue.shade800,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '1. Upload a clear photo of the pet\n'
//             '2. AI analyzes visual features using MobileNet V2\n'
//             '3. Compares with pets in our database\n'
//             '4. Shows results ranked by similarity',
//             style: TextStyle(color: Colors.blue.shade700),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageSelectionArea() {
//     return GestureDetector(
//       onTap: _showImageSourceDialog,
//       child: Container(
//         height: 250,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: Colors.grey.shade300,
//             width: 2,
//             // Remove the dashed style - not available in all Flutter versions
//           ),
//         ),
//         child: _selectedImage != null
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   _selectedImage!,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),
//               )
//             : const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.add_photo_alternate,
//                     size: 64,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Tap to select an image',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Camera or Gallery',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildStatusMessage() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.info, color: Colors.green.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               _statusMessage,
//               style: TextStyle(color: Colors.green.shade700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorMessage() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error, color: Colors.red.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               _errorMessage,
//               style: TextStyle(color: Colors.red.shade700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchButton() {
//     return SizedBox(
//       height: 50,
//       child: ElevatedButton.icon(
//         onPressed: (_selectedImage == null || _isSearching || _isInitializing) 
//             ? null 
//             : _searchSimilarPets,
//         icon: _isSearching
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             : const Icon(Icons.search),
//         label: Text(
//           _isSearching ? 'Searching...' : 'Find Similar Pets',
//           style: const TextStyle(fontSize: 16),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.purple.shade400,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchResults() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Similar Pets Found (${_searchResults.length})',
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _searchResults.length,
//           itemBuilder: (context, index) {
//             final result = _searchResults[index];
//             return _buildResultCard(result, index + 1);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildResultCard(SimilarPetResult result, int rank) {
//     final pet = result.pet;
//     final similarity = (result.similarityScore * 100).round();
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => PetDetailScreen(petId: pet.id!),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: _getRankColor(rank),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     '$rank',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(width: 12),
              
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: CachedNetworkImage(
//                   imageUrl: pet.imageUrl,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     color: Colors.grey.shade200,
//                     child: const Icon(Icons.pets),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: Colors.grey.shade200,
//                     child: const Icon(Icons.error),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(width: 12),
              
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                                                 Expanded(
//                           child: Text(
//                             pet.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _getSimilarityColor(similarity),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             '$similarity% match',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${pet.breed} • ${pet.color}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: pet.status == 'lost'
//                                 ? Colors.red.shade100
//                                 : pet.status == 'found'
//                                     ? Colors.green.shade100
//                                     : Colors.blue.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             pet.status.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               color: pet.status == 'lost'
//                                   ? Colors.red.shade700
//                                   : pet.status == 'found'
//                                       ? Colors.green.shade700
//                                       : Colors.blue.shade700,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (pet.location.isNotEmpty)
//                           Expanded(
//                             child: Text(
//                               pet.location,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.grey.shade500,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getRankColor(int rank) {
//     switch (rank) {
//       case 1:
//         return Colors.amber;
//       case 2:
//         return Colors.grey.shade400;
//       case 3:
//         return Colors.brown.shade400;
//       default:
//         return Colors.blue.shade400;
//     }
//   }

//   Color _getSimilarityColor(int similarity) {
//     if (similarity >= 80) return Colors.green;
//     if (similarity >= 60) return Colors.orange;
//     if (similarity >= 40) return Colors.blue;
//     return Colors.grey;
//   }

//   void _showHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('How to get better results'),
//         content: const SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'For best results:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text('• Use clear, well-lit photos'),
//               Text('• Ensure the pet is the main subject'),
//               Text('• Avoid blurry or dark images'),
//               Text('• Include the pet\'s face if possible'),
//               Text('• Try different angles if first search doesn\'t work'),
//               SizedBox(height: 16),
//               Text(
//                 'The AI compares visual features like:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text('• Overall appearance and shape'),
//               Text('• Color patterns and markings'),
//               Text('• Size and proportions'),
//               Text('• Facial features'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _similarityService.dispose();
//     super.dispose();
//   }
// }
