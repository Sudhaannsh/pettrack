// import 'package:flutter/material.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/services/auth_service.dart';
// import 'package:pettrack/screens/pet_qr_screen.dart';
// import 'package:pettrack/screens/add_edit_pet_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class MyPetsScreen extends StatefulWidget {
//   const MyPetsScreen({super.key});

//   @override
//   State<MyPetsScreen> createState() => _MyPetsScreenState();
// }

// class _MyPetsScreenState extends State<MyPetsScreen> {
//   final PetService _petService = PetService();
//   final AuthService _authService = AuthService();
//   List<PetModel> _pets = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPets();
//   }

//   Future<void> _loadPets() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final userId = _authService.currentUser?.uid;
//       print('Current user ID: $userId'); // Debug log

//       if (userId != null) {
//         final pets = await _petService.getPetsByUserId(userId);
//         print('Loaded ${pets.length} pets'); // Debug log

//         setState(() {
//           _pets = pets;
//         });
//       } else {
//         print('No user logged in'); // Debug log
//       }
//     } catch (e) {
//       print('Error loading pets: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading pets: $e')),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _navigateToAddPet() async {
//     final result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const AddEditPetScreen(),
//       ),
//     );
//     if (result == true && mounted) {
//       _loadPets();
//     }
//   }

//   void _navigateToEditPet(PetModel pet) async {
//     final result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => AddEditPetScreen(pet: pet),
//       ),
//     );
//     if (result == true && mounted) {
//       _loadPets();
//     }
//   }

//   Future<void> _deletePet(PetModel pet) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Pet'),
//         content: Text('Are you sure you want to delete ${pet.name}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _petService.deletePet(pet.id!);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('${pet.name} deleted successfully')),
//           );
//           _loadPets();
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error deleting pet: $e')),
//           );
//         }
//       }
//     }
//   }

//   void _showPetOptions(PetModel pet) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.qr_code),
//               title: const Text('View QR Code'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => PetQRScreen(pet: pet),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Edit'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _navigateToEditPet(pet);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text('Delete', style: TextStyle(color: Colors.red)),
//               onTap: () {
//                 Navigator.pop(context);
//                 _deletePet(pet);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Pets'),
//         actions: [
//           // Add refresh button for debugging
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadPets,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAddPet,
//         child: const Icon(Icons.add),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _pets.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.pets,
//                         size: 64,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No pets added yet',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: _navigateToAddPet,
//                         child: const Text('Add Your First Pet'),
//                       ),
//                       const SizedBox(height: 16),
//                       // Debug info
//                       Text(
//                         'User ID: ${_authService.currentUser?.uid ?? 'Not logged in'}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadPets,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: _pets.length,
//                     itemBuilder: (context, index) {
//                       final pet = _pets[index];
//                       return Card(
//                         elevation: 2,
//                         margin: const EdgeInsets.symmetric(
//                           vertical: 8,
//                           horizontal: 4,
//                         ),
//                         child: ListTile(
//                           leading: Hero(
//                             tag: 'pet_${pet.id}',
//                             child: CircleAvatar(
//                               radius: 30,
//                               backgroundImage: pet.imageUrl.isNotEmpty
//                                   ? CachedNetworkImageProvider(pet.imageUrl)
//                                   : null,
//                               child: pet.imageUrl.isEmpty
//                                   ? const Icon(Icons.pets, size: 30)
//                                   : null,
//                             ),
//                           ),
//                           title: Text(
//                             pet.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 4),
//                               Text(pet.breed),
//                               // Fixed: Check if age exists and is not empty
//                               if (pet.age.isNotEmpty)
//                                 Text(
//                                   pet.age,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                               // Show status for debugging
//                               Text(
//                                 'Status: ${pet.status}',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey.shade400,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.more_vert),
//                             onPressed: () => _showPetOptions(pet),
//                           ),
//                           onTap: () => _showPetOptions(pet),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:pettrack/screens/pet_qr_screen.dart';
import 'package:pettrack/screens/add_edit_pet_screen.dart';
import 'package:pettrack/screens/report_lost_pet_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final PetService _petService = PetService();
  final AuthService _authService = AuthService();
  List<PetModel> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final pets = await _petService.getPetsByUserId(userId);
        setState(() {
          _pets = pets;
        });
      }
    } catch (e) {
      print('Error loading pets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pets: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddPet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditPetScreen(),
      ),
    );
    if (result == true && mounted) {
      _loadPets();
    }
  }

  void _navigateToEditPet(PetModel pet) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditPetScreen(pet: pet),
      ),
    );
    if (result == true && mounted) {
      _loadPets();
    }
  }

  void _navigateToReportLost(PetModel pet) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportLostPetScreen(pet: pet),
      ),
    );
    if (result == true && mounted) {
      _loadPets();
    }
  }

  Future<void> _deletePet(PetModel pet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _petService.deletePet(pet.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} deleted successfully')),
          );
          _loadPets();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting pet: $e')),
          );
        }
      }
    }
  }

  Future<void> _markAsFound(PetModel pet) async {
    try {
      await _petService.markPetAsFound(pet.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pet.name} marked as found!')),
        );
        _loadPets();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating pet: $e')),
        );
      }
    }
  }

  void _showPetOptions(PetModel pet) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('View QR Code'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PetQRScreen(pet: pet),
                  ),
                );
              },
            ),
            if (!pet.isLost)
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Report as Lost'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToReportLost(pet);
                },
              ),
            if (pet.isLost)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Mark as Found'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsFound(pet);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditPet(pet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePet(pet);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPet,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pets added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _navigateToAddPet,
                        child: const Text('Add Your First Pet'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _pets.length,
                    itemBuilder: (context, index) {
                      final pet = _pets[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              Hero(
                                tag: 'pet_${pet.id}',
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: pet.imageUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(pet.imageUrl)
                                      : null,
                                  child: pet.imageUrl.isEmpty
                                      ? const Icon(Icons.pets, size: 30)
                                      : null,
                                ),
                              ),
                              if (pet.isLost)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pet.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (pet.isLost)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'LOST',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(pet.breed),
                              if (pet.age.isNotEmpty)
                                Text(
                                  pet.age,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!pet.isLost)
                                IconButton(
                                  icon: const Icon(Icons.warning,
                                      color: Colors.orange),
                                  onPressed: () => _navigateToReportLost(pet),
                                  tooltip: 'Report as Lost',
                                ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showPetOptions(pet),
                              ),
                            ],
                          ),
                          onTap: () => _showPetOptions(pet),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
