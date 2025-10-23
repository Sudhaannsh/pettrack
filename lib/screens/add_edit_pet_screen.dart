import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADD this import
import 'dart:io';

class AddEditPetScreen extends StatefulWidget {
  final PetModel? pet; // null for add, non-null for edit

  const AddEditPetScreen({super.key, this.pet});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petService = PetService();
  final _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _colorController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _descriptionController;
  late TextEditingController _medicalNotesController;

  File? _imageFile;
  bool _isLoading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _colorController = TextEditingController(text: widget.pet?.color ?? '');
    _ageController = TextEditingController(text: widget.pet?.age ?? '');
    _weightController = TextEditingController(text: widget.pet?.weight ?? '');
    _descriptionController =
        TextEditingController(text: widget.pet?.description ?? '');
    _medicalNotesController =
        TextEditingController(text: widget.pet?.medicalNotes ?? '');
    _existingImageUrl = widget.pet?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('=== DEBUG: Saving pet ===');
      print('User ID: $userId');

      String imageUrl = _existingImageUrl ?? '';

      // Upload new image if selected
      if (_imageFile != null) {
        print('Uploading image...');
        imageUrl = await _petService.uploadImage(_imageFile!);
        print('Image uploaded: $imageUrl');
      }

      final petData = {
        'name': _nameController.text.trim(),
        'breed': _breedController.text.trim(),
        'color': _colorController.text.trim(),
        'age': _ageController.text.trim(),
        'weight': _weightController.text.trim(),
        'description': _descriptionController.text.trim(),
        'medicalNotes': _medicalNotesController.text.trim(),
        'imageUrl': imageUrl,
        'ownerId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isLost': false,
      };

      print('Pet data to save: $petData');

      if (widget.pet == null) {
        // Add new pet
        final petId = await _petService.addPet(petData);
        print('Pet added with ID: $petId');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet added successfully')),
          );
        }
      } else {
        // Update existing pet
        await _petService.updatePet(widget.pet!.id!, petData);
        print('Pet updated: ${widget.pet!.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet updated successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('ERROR saving pet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving pet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _savePet() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   if (_imageFile == null && _existingImageUrl == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a pet image')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final userId = _authService.currentUser?.uid;
  //     if (userId == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     String imageUrl = _existingImageUrl ?? '';

  //     // Upload new image if selected
  //     if (_imageFile != null) {
  //       imageUrl = await _petService.uploadImage(_imageFile!);
  //     }

  //     final petData = {
  //       'name': _nameController.text.trim(),
  //       'breed': _breedController.text.trim(),
  //       'color': _colorController.text.trim(),
  //       'age': _ageController.text.trim(),
  //       'weight': _weightController.text.trim(),
  //       'description': _descriptionController.text.trim(),
  //       'medicalNotes': _medicalNotesController.text.trim(),
  //       'imageUrl': imageUrl,
  //       'ownerId': userId,
  //       'timestamp': FieldValue.serverTimestamp(), // FIXED: Use FieldValue.serverTimestamp()
  //       'isLost': false, // ADD: Add isLost field
  //     };

  //     if (widget.pet == null) {
  //       // Add new pet
  //       await _petService.addPet(petData);
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Pet added successfully')),
  //         );
  //       }
  //     } else {
  //       // Update existing pet
  //       await _petService.updatePet(widget.pet!.id!, petData);
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Pet updated successfully')),
  //         );
  //       }
  //     }

  //     if (mounted) {
  //       Navigator.of(context).pop(true);
  //     }
  //   } catch (e) {
  //     print('Error saving pet: $e'); // ADD: Debug log
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error saving pet: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }
  // Future<void> _savePet() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   if (_imageFile == null && _existingImageUrl == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a pet image')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final userId = _authService.currentUser?.uid;
  //     if (userId == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     String imageUrl = _existingImageUrl ?? '';

  //     // Upload new image if selected
  //     if (_imageFile != null) {
  //       imageUrl = await _petService.uploadImage(_imageFile!);
  //     }

  //     final petData = {
  //       'name': _nameController.text.trim(),
  //       'breed': _breedController.text.trim(),
  //       'color': _colorController.text.trim(),
  //       'age': _ageController.text.trim(),
  //       'weight': _weightController.text.trim(),
  //       'description': _descriptionController.text.trim(),
  //       'medicalNotes': _medicalNotesController.text.trim(),
  //       'imageUrl': imageUrl,
  //       'ownerId': userId,
  //       'status': 'owned', // Status for owned pets
  //       'timestamp': DateTime.now(),
  //     };

  //     if (widget.pet == null) {
  //       // Add new pet
  //       await _petService.addPet(petData);
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Pet added successfully')),
  //         );
  //       }
  //     } else {
  //       // Update existing pet
  //       await _petService.updatePet(widget.pet!.id!, petData);
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Pet updated successfully')),
  //         );
  //       }
  //     }

  //     if (mounted) {
  //       Navigator.of(context).pop(true);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error saving pet: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pet' : 'Add New Pet'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _existingImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _existingImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 48,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to add pet photo',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
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

                    // Age and Weight in a row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 2 years',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 5 kg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Personality, habits, etc.',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Medical Notes
                    TextFormField(
                      controller: _medicalNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Medical Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_services),
                        hintText: 'Vaccinations, allergies, medications',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _savePet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Pet' : 'Add Pet',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
