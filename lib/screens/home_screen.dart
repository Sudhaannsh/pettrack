import 'package:flutter/material.dart';
import 'package:pettrack/screens/login_screen.dart';
import 'package:pettrack/screens/post_pet_screen.dart';
import 'package:pettrack/screens/profile_screen.dart';
import 'package:pettrack/screens/pet_detail_screen.dart';
import 'package:pettrack/screens/qr_scanner_screen.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Use a getter for screens to always have the latest searchQuery
  List<Widget> get _screens => [
        FilterableHomeTab(
          searchQuery: _searchQuery,
          searchController: _searchController,
          onSearchChanged: _performSearch,
        ),
        const MapTab(),
        const Center(child: Text('Add Pet')), // Placeholder for add pet
        const QRScannerScreen(), // QR Scanner screen
        const ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Navigate to Add Pet screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PostPetScreen()),
      );
    } else if (index == 3) {
      // Navigate to QR Scanner screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Toggle search visibility or focus
              if (_searchController.text.isNotEmpty) {
                _searchController.clear();
                _performSearch('');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Filterable Home Tab
class FilterableHomeTab extends StatelessWidget {
  final String searchQuery;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  const FilterableHomeTab({
    super.key,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, breed, color...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          const TabBar(
            tabs: [
              Tab(text: 'Lost Pets'),
              Tab(text: 'Found Pets'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
          ),

          if (searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'Filtering: "$searchQuery"',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: TabBarView(
              children: [
                FilterablePetListView(status: 'lost', searchQuery: searchQuery),
                FilterablePetListView(
                    status: 'found', searchQuery: searchQuery),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Filterable Pet List View Widget
class FilterablePetListView extends StatelessWidget {
  final String status;
  final String searchQuery;
  final PetService _petService = PetService();

  FilterablePetListView({
    super.key,
    required this.status,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PetModel>>(
      stream: _petService.getPetsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allPets = snapshot.data ?? [];

        // Filter pets based on search query
        final List<PetModel> filteredPets = searchQuery.isEmpty
            ? allPets
            : allPets.where((pet) {
                return pet.name.toLowerCase().contains(searchQuery) ||
                    pet.breed.toLowerCase().contains(searchQuery) ||
                    pet.color.toLowerCase().contains(searchQuery) ||
                    pet.location.toLowerCase().contains(searchQuery) ||
                    (pet.description?.toLowerCase().contains(searchQuery) ??
                        false);
              }).toList();

        if (filteredPets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isEmpty ? Icons.pets : Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No ${status.toLowerCase()} pets found'
                      : 'No $status pets match "$searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or check other tab',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredPets.length,
          itemBuilder: (context, index) {
            final pet = filteredPets[index];
            return PetCard(pet: pet);
          },
        );
      },
    );
  }
}

// Pet Card Widget
class PetCard extends StatelessWidget {
  final PetModel pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PetDetailScreen(petId: pet.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: pet.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.breed,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
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
    );
  }
}

// Map Tab - Shows pets on map
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final PetService _petService = PetService();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadPetMarkers();
  }

  Future<void> _loadPetMarkers() async {
    try {
      final pets = await _petService.getAllPets().first;
      setState(() {
        _markers = pets
            .where((pet) => pet.latitude != 0 && pet.longitude != 0)
            .map((pet) {
          return Marker(
            width: 40,
            height: 40,
            point: LatLng(pet.latitude, pet.longitude),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PetDetailScreen(petId: pet.id),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: pet.status == 'lost'
                      ? Colors.red.withOpacity(0.8)
                      : Colors.green.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        }).toList();
      });
    } catch (e) {
      print('Error loading pet markers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(37.42796133580664, -122.085749655962),
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.pettrack',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }
}
