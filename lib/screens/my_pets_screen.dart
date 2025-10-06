import 'package:flutter/material.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:pettrack/screens/pet_qr_screen.dart';
import 'package:pettrack/screens/post_pet_screen.dart';
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
        builder: (context) => const PostPetScreen(),
      ),
    );
    if (result == true && mounted) {
      _loadPets();
    }
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
                        child: const Text('Add a Pet'),
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
                          leading: CircleAvatar(
                            backgroundImage: pet.imageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(pet.imageUrl)
                                : null,
                            child: pet.imageUrl.isEmpty
                                ? const Icon(Icons.pets)
                                : null,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(pet.breed),
                          trailing: IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PetQRScreen(pet: pet),
                                ),
                              );
                            },
                            tooltip: 'Generate QR Code',
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}