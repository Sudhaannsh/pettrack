import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLostFoundPetScreen extends StatefulWidget {
  final LostFoundPetModel pet;

  const EditLostFoundPetScreen({super.key, required this.pet});

  @override
  State<EditLostFoundPetScreen> createState() => _EditLostFoundPetScreenState();
}

class _EditLostFoundPetScreenState extends State<EditLostFoundPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final LostFoundPetService _lostFoundPetService = LostFoundPetService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _colorController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _locationController;

  File? _imageFile;
  bool _isLoading = false;
  bool _isLocationLoading = false;
  String _errorMessage = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  DateTime? _lastSeenDate;
  String _selectedPetType = 'Dog';
  String _selectedSize = 'Medium';

  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> _sizes = ['Small', 'Medium', 'Large'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _colorController = TextEditingController(text: widget.pet.color);
    _descriptionController = TextEditingController(text: widget.pet.description ?? '');
    _contactPhoneController = TextEditingController(text: widget.pet.contactPhone ?? '');
    _locationController = TextEditingController(text: widget.pet.location);
  }

  void _initializeData() {
    _latitude = widget.pet.latitude;
    _longitude = widget.pet.longitude;
    _lastSeenDate = widget.pet.lastSeenDate;
    _selectedPetType = widget.pet.petType ?? 'Dog';
    _selectedSize = widget.pet.size ?? 'Medium';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _contactPhoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLocationLoading = true;
      _errorMessage = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Location permissions are denied';
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
            _locationController.text = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
            _isLocationLoading = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error getting location: $e';
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

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final userId = _authService.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not logged in');
        }

        // Check if user owns this pet
        final isOwner = await _lostFoundPetService.isUserOwnerOfPet(widget.pet.id!, userId);
        if (!isOwner) {
          throw Exception('You can only edit your own pets');
        }

        final petData = {
          'name': _nameController.text.trim(),
          'breed': _breedController.text.trim(),
          'color': _colorController.text.trim(),
          'location': _locationController.text.trim(),
          'latitude': _latitude,
          'longitude': _longitude,
          'description': _descriptionController.text.trim(),
          'contactPhone': _contactPhoneController.text.trim(),
          'petType': _selectedPetType,
          'size': _selectedSize,
          'lastSeenDate': _lastSeenDate,
        };

        if (_imageFile != null) {
          // Update with new image
          await _lostFoundPetService.updateLostFoundPetWithImage(
            widget.pet.id!,
            petData,
            _imageFile!,
          );
        } else {
          // Update without changing image
          await _lostFoundPetService.updateLostFoundPet(widget.pet.id!, petData);
        }

        if (!mounted) return;
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating pet: $e';
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
        title: Text('Edit ${widget.pet.name}'),
        backgroundColor: widget.pet.status == 'lost' ? Colors.red.shade400 : Colors.green.shade400,
        foregroundColor: Colors.white,
              ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current/New Image Section
                    Text(
                      'Pet Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                      'Update Pet Photo',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
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
                                            icon:
                                                const Icon(Icons.photo_library),
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
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: widget.pet.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey.shade200,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            size: 32, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Tap to update photo',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),

                    if (_imageFile != null) ...[
                      const SizedBox(height: 8),
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
                            const Text(
                              'New photo selected',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Pet Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter pet name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Breed
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter breed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Color
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.palette),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter color';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pet Type and Size in a row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPetType,
                            decoration: const InputDecoration(
                              labelText: 'Pet Type',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.pets),
                            ),
                            items: _petTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPetType = newValue!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSize,
                            decoration: const InputDecoration(
                              labelText: 'Size',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            items: _sizes.map((String size) {
                              return DropdownMenuItem<String>(
                                value: size,
                                child: Text(size),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSize = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Last seen date
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
                            Icon(Icons.calendar_today,
                                color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Text(
                              _lastSeenDate != null
                                  ? '${widget.pet.status == 'lost' ? 'Last Seen' : 'Found On'}: ${_lastSeenDate!.day}/${_lastSeenDate!.month}/${_lastSeenDate!.year}'
                                  : 'Select ${widget.pet.status == 'lost' ? 'last seen' : 'found'} date',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText:
                            '${widget.pet.status == 'lost' ? 'Last Known' : 'Found'} Location *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: _isLocationLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location),
                                onPressed: _getCurrentLocation,
                                tooltip: 'Use current location',
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Phone
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

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Details',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText:
                            'Behavior, distinctive marks, circumstances, etc.',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide some details';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.pet.status == 'lost'
                              ? Colors.red.shade400
                              : Colors.green.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Update Pet Information',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info card
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
                                'Update Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Update any information that has changed\n'
                            '• Add a new photo if you have a better one\n'
                            '• Make sure contact information is current\n'
                            '• Update location if the pet was seen elsewhere',
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
