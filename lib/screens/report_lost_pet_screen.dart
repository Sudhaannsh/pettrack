// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/lost_found_pet_service.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/services/auth_service.dart';

// class ReportLostPetScreen extends StatefulWidget {
//   final PetModel pet;

//   const ReportLostPetScreen({super.key, required this.pet});

//   @override
//   State<ReportLostPetScreen> createState() => _ReportLostPetScreenState();
// }

// class _ReportLostPetScreenState extends State<ReportLostPetScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _descriptionController = TextEditingController();
//   final _contactPhoneController = TextEditingController();

//   final LostFoundPetService _lostFoundPetService = LostFoundPetService();
//   final PetService _petService = PetService();
//   final AuthService _authService = AuthService();
//   final ImagePicker _imagePicker = ImagePicker();

//   File? _imageFile;
//   bool _isLoading = false;
//   bool _isLocationLoading = true;
//   String _errorMessage = '';
//   String _locationText = 'Fetching location...';
//   double _latitude = 0.0;
//   double _longitude = 0.0;
//   DateTime? _lastSeenDate;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _lastSeenDate = DateTime.now();
//   }

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     _contactPhoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _getCurrentLocation() async {
//     if (!mounted) return;
//     setState(() {
//       _isLocationLoading = true;
//       _locationText = 'Fetching location...';
//     });

//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (!mounted) return;
//           setState(() {
//             _locationText = 'Location permissions are denied';
//             _isLocationLoading = false;
//           });
//           return;
//         }
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );

//       if (!mounted) return;
//       setState(() {
//         _latitude = position.latitude;
//         _longitude = position.longitude;
//       });

//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );

//         if (placemarks.isNotEmpty) {
//           Placemark place = placemarks[0];
//           if (!mounted) return;
//           setState(() {
//             _locationText = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
//             _isLocationLoading = false;
//           });
//         } else {
//           if (!mounted) return;
//           setState(() {
//             _locationText = 'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
//             _isLocationLoading = false;
//           });
//         }
//       } catch (e) {
//         if (!mounted) return;
//         setState(() {
//           _locationText = 'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
//           _isLocationLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _locationText = 'Error getting location: $e';
//         _isLocationLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//           _errorMessage = '';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error picking image: $e';
//       });
//     }
//   }

//   Future<void> _takePicture() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//           _errorMessage = '';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error taking picture: $e';
//       });
//     }
//   }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _lastSeenDate ?? DateTime.now(),
//       firstDate: DateTime.now().subtract(const Duration(days: 30)),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _lastSeenDate) {
//       setState(() {
//         _lastSeenDate = picked;
//       });
//     }
//   }






//   // In your ReportLostPetScreen, when submitting:
// Future<void> _submitLostReport() async {
//   try {
//     setState(() => _isLoading = true);

//     final lostReportId = await _petService.reportPetAsLost(
//       widget.pet,
//       location: _locationController.text,
//       latitude: _selectedLocation?.latitude ?? 0.0,
//       longitude: _selectedLocation?.longitude ?? 0.0,
//       additionalDescription: _descriptionController.text,
//       contactInfo: _contactController.text,
//     );

//     if (mounted) {
//       Navigator.of(context).pop(true); // Return true to indicate success
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Pet reported as lost successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error reporting pet: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }




//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (_latitude == 0.0 && _longitude == 0.0) {
//         setState(() {
//           _errorMessage = 'Location not available. Please wait for location to load or refresh.';
//         });
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       try {
//         final userId = _authService.currentUser?.uid;
//         if (userId == null) {
//           throw Exception('User not logged in');
//         }

//         String imageUrl = widget.pet.imageUrl; // Use existing pet image by default
        
//         // Upload new image if selected
//         if (_imageFile != null) {
//           imageUrl = await _lostFoundPetService.uploadImage(_imageFile!);
//         }

//         // Create lost pet data for lost_found_pets collection
//         final lostPetData = {
//           'name': widget.pet.name,
//           'breed': widget.pet.breed,
//           'color': widget.pet.color,
//           'location': _locationText,
//           'imageUrl': imageUrl,
//           'status': 'lost',
//           'timestamp': DateTime.now(),
//           'userId': userId,
//           'latitude': _latitude,
//           'longitude': _longitude,
//           'description': _descriptionController.text.trim(),
//           'contactPhone': _contactPhoneController.text.trim(),
//           'petType': 'Dog', // You can derive this from breed or add to PetModel
//           'size': 'Medium', // You can derive this or add to PetModel
//           'lastSeenDate': _lastSeenDate,
//         };

//         // Add to lost/found pets collection
//         await _lostFoundPetService.addLostFoundPet(lostPetData);

//         // Mark the owned pet as lost
//         await _petService.markPetAsLost(widget.pet.id!);

//         if (!mounted) return;
//         Navigator.of(context).pop(true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Pet reported as lost successfully'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'Error reporting pet as lost: $e';
//         });
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Report ${widget.pet.name} as Lost'),
//         backgroundColor: Colors.red.shade400,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Pet info card
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           widget.pet.imageUrl,
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                             width: 80,
//                             height: 80,
//                             color: Colors.grey.shade200,
//                             child: const Icon(Icons.pets),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.pet.name,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               widget.pet.breed,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                             Text(
//                               widget.pet.color,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.shade500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Optional: Add a different image
//               Text(
//                 'Recent Photo (Optional)',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Add a more recent photo if available',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               GestureDetector(
//                 onTap: () {
//                   showModalBottomSheet(
//                     context: context,
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                     ),
//                     builder: (BuildContext context) {
//                       return SafeArea(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Text(
//                                 'Add Recent Photo',
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 16),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: ElevatedButton.icon(
//                                       icon: const Icon(Icons.camera_alt),
//                                       label: const Text('Camera'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                         _takePicture();
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: ElevatedButton.icon(
//                                       icon: const Icon(Icons.photo_library),
//                                       label: const Text('Gallery'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                         _pickImage();
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 child: Container(
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: _imageFile != null
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.file(
//                             _imageFile!,
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                           ),
//                         )
//                       : const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add_photo_alternate,
//                               size: 32,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Tap to add recent photo',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),

//               if (_errorMessage.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Text(
//                     _errorMessage,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ),

//               const SizedBox(height: 24),

//               // Last seen date
//               Text(
//                 'When was your pet last seen?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               GestureDetector(
//                 onTap: _selectDate,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade400),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.calendar_today, color: Colors.grey.shade600),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Last Seen: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Last known location
//               Text(
//                 'Last Known Location',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade400),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     _isLocationLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.location_on, color: Colors.red),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(_locationText),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.refresh),
//                       onPressed: _isLocationLoading ? null : _getCurrentLocation,
//                       tooltip: 'Refresh location',
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Contact phone
//               TextFormField(
//                 controller: _contactPhoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Contact Phone *',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.phone),
//                   hintText: 'Your phone number',
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your contact number';
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 16),

//               // Additional details
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Additional Details',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.description),
//                   hintText: 'Behavior, distinctive marks, circumstances of loss, etc.',
//                 ),
//                 maxLines: 4,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please provide some details about your lost pet';
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 32),

//               // Submit button
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: (_isLoading || _isLocationLoading) ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade400,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           'Report as Lost',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Help text
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info, color: Colors.orange.shade600),
//                         const SizedBox(width: 8),
//                         Text(
//                           'What happens next:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange.shade800,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '• Your pet will be posted in the "Lost Pets" section\n'
//                       '• Other users can contact you if they find your pet\n'
//                       '• You can update or remove the post anytime\n'
//                       '• Consider posting on local social media groups too',
//                       style: TextStyle(color: Colors.orange.shade700),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/services/auth_service.dart';

class ReportLostPetScreen extends StatefulWidget {
  final PetModel pet;

  const ReportLostPetScreen({super.key, required this.pet});

  @override
  State<ReportLostPetScreen> createState() => _ReportLostPetScreenState();
}

class _ReportLostPetScreenState extends State<ReportLostPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  final LostFoundPetService _lostFoundPetService = LostFoundPetService();
  final PetService _petService = PetService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;
  bool _isLocationLoading = true;
  String _errorMessage = '';
  String _locationText = 'Fetching location...';
  double _latitude = 0.0;
  double _longitude = 0.0;
  DateTime? _lastSeenDate;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _lastSeenDate = DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLocationLoading = true;
      _locationText = 'Fetching location...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _locationText = 'Location permissions are denied';
            _isLocationLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          if (!mounted) return;
          setState(() {
            _locationText = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
            _isLocationLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _locationText = 'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
            _isLocationLoading = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _locationText = 'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationText = 'Error getting location: $e';
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error taking picture: $e';
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastSeenDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastSeenDate) {
      setState(() {
        _lastSeenDate = picked;
      });
    }
  }

  // Updated submit method using the new reportPetAsLost method
  Future<void> _submitLostReport() async {
    if (_formKey.currentState!.validate()) {
      if (_latitude == 0.0 && _longitude == 0.0) {
        setState(() {
          _errorMessage = 'Location not available. Please wait for location to load or refresh.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Prepare additional description with all the details
        String fullDescription = _descriptionController.text.trim();
        if (_lastSeenDate != null) {
          fullDescription += '\nLast seen: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}';
        }

        // Handle image upload if new image is selected
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _lostFoundPetService.uploadImage(_imageFile!);
        }

        // Use the new reportPetAsLost method from PetService
        await _petService.reportPetAsLost(
          widget.pet,
          location: _locationText,
          latitude: _latitude,
          longitude: _longitude,
          additionalDescription: fullDescription,
          contactInfo: _contactPhoneController.text.trim(),
          imageUrl: imageUrl, // Pass the new image URL if available
          lastSeenDate: _lastSeenDate,
        );

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pet reported as lost successfully!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error reporting pet as lost: $e';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reporting pet: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report ${widget.pet.name} as Lost'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.pet.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.pets),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pet.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.pet.breed,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              widget.pet.color,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Optional: Add a different image
              Text(
                'Recent Photo (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a more recent photo if available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Add Recent Photo',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Camera'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _takePicture();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Gallery'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _pickImage();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add recent photo',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 24),

              // Last seen date
              Text(
                'When was your pet last seen?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Last Seen: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Last known location
              Text(
                'Last Known Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _isLocationLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_locationText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed:
                          _isLocationLoading ? null : _getCurrentLocation,
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact phone
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Your phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Additional details
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText:
                      'Behavior, distinctive marks, circumstances of loss, etc.',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide some details about your lost pet';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isLocationLoading)
                      ? null
                      : _submitLostReport, // Changed method name
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Report as Lost',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'What happens next:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your pet will be posted in the "Lost Pets" section\n'
                      '• Other users can contact you if they find your pet\n'
                      '• You can update or remove the post anytime\n'
                      '• Consider posting on local social media groups too',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
