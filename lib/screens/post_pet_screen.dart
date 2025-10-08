// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/services/auth_service.dart';

// class PostPetScreen extends StatefulWidget {
//   const PostPetScreen({super.key});

//   @override
//   _PostPetScreenState createState() => _PostPetScreenState();
// }

// class _PostPetScreenState extends State<PostPetScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _breedController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _contactPhoneController = TextEditingController();

//   final PetService _petService = PetService();
//   final AuthService _authService = AuthService();
//   final ImagePicker _imagePicker = ImagePicker();

//   File? _imageFile;
//   String _status = 'lost';
//   bool _isLoading = false;
//   bool _isLocationLoading = true;
//   String _errorMessage = '';
//   String _locationText = 'Fetching location...';
//   double _latitude = 0.0;
//   double _longitude = 0.0;

//   // Simplified essential fields only
//   String _petType = 'Dog';
//   String _size = 'Medium';
//   String _primaryColor = 'Brown';
//   DateTime? _lastSeenDate;

//   // Simple dropdown options
//   final List<String> _petTypes = ['Dog', 'Cat', 'Other'];
//   final List<String> _sizes = ['Small', 'Medium', 'Large'];
//   final List<String> _colors = ['Black', 'Brown', 'White', 'Golden', 'Gray', 'Mixed'];

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _lastSeenDate = DateTime.now();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _breedController.dispose();
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

//       if (permission == LocationPermission.deniedForever) {
//         if (!mounted) return;
//         setState(() {
//           _locationText = 'Location permissions are permanently denied';
//           _isLocationLoading = false;
//         });
//         return;
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

//   Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: DropdownButtonFormField<String>(
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         value: value,
//         items: options.map((String option) {
//           return DropdownMenuItem<String>(
//             value: option,
//             child: Text(option),
//           );
//         }).toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (_imageFile == null) {
//         setState(() {
//           _errorMessage = 'Please select an image of the pet';
//         });
//         return;
//       }

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

//         // Build simple description
//         String description = _descriptionController.text.trim();
//         if (_contactPhoneController.text.isNotEmpty) {
//           description += '\nContact: ${_contactPhoneController.text}';
//         }
//         if (_lastSeenDate != null) {
//           description += '\n${_status == 'lost' ? 'Last seen' : 'Found'}: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}';
//         }
//         description += '\nType: $_petType, Size: $_size';

//         final pet = PetModel(
//           name: _nameController.text.trim(),
//           breed: _breedController.text.trim(),
//           color: _primaryColor,
//           location: _locationText,
//           imageUrl: '',
//           status: _status,
//           timestamp: DateTime.now(),
//           userId: userId,
//           latitude: _latitude,
//           longitude: _longitude,
//           description: description,
//         );

//         await _petService.addPet(pet, _imageFile!);

//         if (!mounted) return;
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Pet posted successfully')),
//         );
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'Error posting pet: $e';
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
//         title: Text(_status == 'lost' ? 'Report Lost Pet' : 'Report Found Pet'),
//         backgroundColor: _status == 'lost' ? Colors.red.shade400 : Colors.green.shade400,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Status selector with better UI
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _status = 'lost'),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           decoration: BoxDecoration(
//                             color: _status == 'lost' ? Colors.red.shade400 : Colors.transparent,
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               bottomLeft: Radius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             'Lost Pet',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: _status == 'lost' ? Colors.white : Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _status = 'found'),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           decoration: BoxDecoration(
//                             color: _status == 'found' ? Colors.green.shade400 : Colors.transparent,
//                             borderRadius: const BorderRadius.only(
//                               topRight: Radius.circular(12),
//                               bottomRight: Radius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             'Found Pet',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: _status == 'found' ? Colors.white : Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Image picker
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
//                                 'Add Pet Photo',
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
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
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
//                               Icons.add_a_photo,
//                               size: 50,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Tap to add a photo',
//                               style: TextStyle(color: Colors.grey, fontSize: 16),
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

//               // Essential pet details
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Pet Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.pets),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter pet name';
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 16),

//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildDropdownField('Type', _petType, _petTypes, (value) {
//                       setState(() => _petType = value!);
//                     }),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                                         child: _buildDropdownField('Size', _size, _sizes, (value) {
//                       setState(() => _size = value!);
//                     }),
//                   ),
//                 ],
//               ),

//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _breedController,
//                       decoration: const InputDecoration(
//                         labelText: 'Breed',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.category),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter breed';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: _buildDropdownField('Color', _primaryColor, _colors,
//                         (value) {
//                       setState(() => _primaryColor = value!);
//                     }),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Date selector
//               GestureDetector(
//                 onTap: _selectDate,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade400),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.calendar_today, color: Colors.grey.shade600),
//                       const SizedBox(width: 12),
//                       Text(
//                         _status == 'lost'
//                             ? 'Last Seen: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}'
//                             : 'Found On: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Location display
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade400),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _status == 'lost'
//                           ? 'Last Known Location'
//                           : 'Found Location',
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         _isLocationLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child:
//                                     CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Icon(Icons.location_on, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(_locationText),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.refresh),
//                           onPressed:
//                               _isLocationLoading ? null : _getCurrentLocation,
//                           tooltip: 'Refresh location',
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Contact phone
//               TextFormField(
//                 controller: _contactPhoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Contact Phone',
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

//               // Description
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: _status == 'lost'
//                       ? 'Additional Details (behavior, distinctive marks, etc.)'
//                       : 'Condition & Details (where found, pet\'s condition, etc.)',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.description),
//                   hintText: _status == 'lost'
//                       ? 'e.g., Very friendly, has a scar on left ear, responds to "Buddy"'
//                       : 'e.g., Found near park, seems healthy, wearing red collar',
//                 ),
//                 maxLines: 3,
//               ),

//               const SizedBox(height: 32),

//               // Submit button
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed:
//                       (_isLoading || _isLocationLoading) ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _status == 'lost'
//                         ? Colors.red.shade400
//                         : Colors.green.shade400,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           _status == 'lost'
//                               ? 'Report Lost Pet'
//                               : 'Report Found Pet',
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Help text
//               Container(
//                 padding: const EdgeInsets.all(16),
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
//                         Icon(Icons.info, color: Colors.blue.shade600),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Tips for better results:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue.shade800,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _status == 'lost'
//                           ? '• Upload a clear, recent photo\n• Include distinctive features\n• Be specific about location\n• Update if pet is found'
//                           : '• Upload a clear photo\n• Describe where you found the pet\n• Note the pet\'s condition\n• Keep the pet safe until owner is found',
//                       style: TextStyle(color: Colors.blue.shade700),
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
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/services/auth_service.dart';

class PostPetScreen extends StatefulWidget {
  const PostPetScreen({super.key});

  @override
  _PostPetScreenState createState() => _PostPetScreenState();
}

class _PostPetScreenState extends State<PostPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  final PetService _petService = PetService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _imageFile;
  String _status = 'lost';
  bool _isLoading = false;
  bool _isLocationLoading = true;
  String _errorMessage = '';
  String _locationText = 'Fetching location...';
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Simplified essential fields only
  String _petType = 'Dog';
  String _size = 'Medium';
  String _primaryColor = 'Brown';
  DateTime? _lastSeenDate;

  // Simple dropdown options
  final List<String> _petTypes = ['Dog', 'Cat', 'Other'];
  final List<String> _sizes = ['Small', 'Medium', 'Large'];
  final List<String> _colors = [
    'Black',
    'Brown',
    'White',
    'Golden',
    'Gray',
    'Mixed'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _lastSeenDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
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

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationText = 'Location permissions are permanently denied';
          _isLocationLoading = false;
        });
        return;
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
            _locationText =
                '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
            _isLocationLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _locationText =
                'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
            _isLocationLoading = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _locationText =
              'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
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

  Widget _buildDropdownField(String label, String value, List<String> options,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        setState(() {
          _errorMessage = 'Please select an image of the pet';
        });
        return;
      }

      if (_latitude == 0.0 && _longitude == 0.0) {
        setState(() {
          _errorMessage =
              'Location not available. Please wait for location to load or refresh.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final userId = _authService.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not logged in');
        }

        // Build simple description
        String description = _descriptionController.text.trim();
        if (_contactPhoneController.text.isNotEmpty) {
          description += '\nContact: ${_contactPhoneController.text}';
        }
        if (_lastSeenDate != null) {
          description +=
              '\n${_status == 'lost' ? 'Last seen' : 'Found'}: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}';
        }
        description += '\nType: $_petType, Size: $_size';

        // FIXED: Upload image first, then create pet data map
        String imageUrl = await _petService.uploadImage(_imageFile!);

        // Create pet data map
        final petData = {
          'name': _nameController.text.trim(),
          'breed': _breedController.text.trim(),
          'color': _primaryColor,
          'location': _locationText,
          'imageUrl': imageUrl,
          'status': _status,
          'timestamp': DateTime.now(),
          'userId': userId,
          'ownerId': userId, // Add ownerId for consistency
          'latitude': _latitude,
          'longitude': _longitude,
          'description': description,
          'ownerContact': _contactPhoneController.text.trim(),
          'age': '', // Default empty
          'weight': '', // Default empty
          'medicalNotes': '', // Default empty
        };

        // Add pet to database
        await _petService.addPet(petData);

        if (!mounted) return;
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_status == 'lost' ? 'Lost' : 'Found'} pet reported successfully'),
            backgroundColor: _status == 'lost' ? Colors.red : Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Error posting pet: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_status == 'lost' ? 'Report Lost Pet' : 'Report Found Pet'),
        backgroundColor:
            _status == 'lost' ? Colors.red.shade400 : Colors.green.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status selector with better UI
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _status = 'lost'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _status == 'lost'
                                ? Colors.red.shade400
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Lost Pet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _status == 'lost'
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _status = 'found'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _status == 'found'
                                ? Colors.green.shade400
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Found Pet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _status == 'found'
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Image picker
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Add Pet Photo',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                        style: BorderStyle.solid),
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
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap to add a photo',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
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

              // Essential pet details
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField('Type', _petType, _petTypes,
                        (value) {
                      setState(() => _petType = value!);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField('Size', _size, _sizes, (value) {
                      setState(() => _size = value!);
                    }),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter breed';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField('Color', _primaryColor, _colors,
                        (value) {
                      setState(() => _primaryColor = value!);
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date selector
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _status == 'lost'
                            ? 'Last Seen: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}'
                            : 'Found On: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _status == 'lost'
                          ? 'Last Known Location'
                          : 'Found Location',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _isLocationLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.location_on, color: Colors.blue),
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Contact phone
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: _status == 'lost'
                      ? 'Additional Details (behavior, distinctive marks, etc.)'
                      : 'Condition & Details (where found, pet\'s condition, etc.)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  hintText: _status == 'lost'
                      ? 'e.g., Very friendly, has a scar on left ear, responds to "Buddy"'
                      : 'e.g., Found near park, seems healthy, wearing red collar',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _isLocationLoading) ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _status == 'lost'
                        ? Colors.red.shade400
                        : Colors.green.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _status == 'lost'
                              ? 'Report Lost Pet'
                              : 'Report Found Pet',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
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
                        Icon(Icons.info, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for better results:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status == 'lost'
                          ? '• Upload a clear, recent photo\n• Include distinctive features\n• Be specific about location\n• Update if pet is found'
                          : '• Upload a clear photo\n• Describe where you found the pet\n• Note the pet\'s condition\n• Keep the pet safe until owner is found',
                      style: TextStyle(color: Colors.blue.shade700),
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
