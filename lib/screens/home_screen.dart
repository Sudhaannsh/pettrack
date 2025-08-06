// import 'package:flutter/material.dart';
// import 'package:pettrack/screens/login_screen.dart';
// import 'package:pettrack/screens/post_pet_screen.dart';
// import 'package:pettrack/screens/profile_screen.dart';
// import 'package:pettrack/services/auth_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   final AuthService _authService = AuthService();
  
//   final List<Widget> _screens = [
//     const HomeTab(),
//     const MapTab(),
//     const Center(child: Text('Add Pet')), // Placeholder
//     const Center(child: Text('Scan QR')), // Placeholder
//     const ProfileScreen(),
//   ];

//   void _onItemTapped(int index) {
//     if (index == 2) {
//       // Navigate to Add Pet screen
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) => const PostPetScreen()),
//       );
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PetTrack'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Implement search functionality
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await _authService.signOut();
//               if (!mounted) return;
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.map),
//             label: 'Map',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add_circle, size: 40),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.qr_code_scanner),
//             label: 'Scan',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// // Home Tab - Shows list of lost and found pets
// class HomeTab extends StatelessWidget {
//   const HomeTab({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         children: [
//           const TabBar(
//             tabs: [
//               Tab(text: 'Lost Pets'),
//               Tab(text: 'Found Pets'),
//             ],
//             labelColor: Colors.blue,
//             unselectedLabelColor: Colors.grey,
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 // Lost Pets Tab
//                 Center(
//                   child: Text('Lost Pets will be shown here'),
//                 ),
//                 // Found Pets Tab
//                 Center(
//                   child: Text('Found Pets will be shown here'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Map Tab - Shows pets on map
// class MapTab extends StatelessWidget {
//   const MapTab({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Map will be shown here'),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:pettrack/screens/login_screen.dart';
// import 'package:pettrack/screens/post_pet_screen.dart';
// import 'package:pettrack/screens/profile_screen.dart';
// import 'package:pettrack/screens/pet_detail_screen.dart';
// import 'package:pettrack/services/auth_service.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   final AuthService _authService = AuthService();

//   final List<Widget> _screens = [
//     const HomeTab(),
//     const MapTab(),
//     const Center(child: Text('Add Pet')), // Placeholder
//     const Center(child: Text('Scan QR')), // Placeholder
//     const ProfileScreen(),
//   ];

//   void _onItemTapped(int index) {
//     if (index == 2) {
//       // Navigate to Add Pet screen
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) => const PostPetScreen()),
//       );
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PetTrack'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Implement search functionality
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await _authService.signOut();
//               if (!mounted) return;
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.map),
//             label: 'Map',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add_circle, size: 40),
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.qr_code_scanner),
//             label: 'Scan',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// // Home Tab - Shows list of lost and found pets
// class HomeTab extends StatelessWidget {
//   const HomeTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         children: [
//           const TabBar(
//             tabs: [
//               Tab(text: 'Lost Pets'),
//               Tab(text: 'Found Pets'),
//             ],
//             labelColor: Colors.blue,
//             unselectedLabelColor: Colors.grey,
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 // Lost Pets Tab
//                 PetListView(status: 'lost'),
//                 // Found Pets Tab
//                 PetListView(status: 'found'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Pet List View Widget
// class PetListView extends StatelessWidget {
//   final String status;
//   final PetService _petService = PetService();

//   PetListView({super.key, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<PetModel>>(
//       stream: _petService.getPetsByStatus(status),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final pets = snapshot.data ?? [];

//         if (pets.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.pets,
//                   size: 64,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No $status pets reported yet',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(8),
//           itemCount: pets.length,
//           itemBuilder: (context, index) {
//             final pet = pets[index];
//             return PetCard(pet: pet);
//           },
//         );
//       },
//     );
//   }
// }

// // Pet Card Widget
// class PetCard extends StatelessWidget {
//   final PetModel pet;

//   const PetCard({super.key, required this.pet});

//   @override
//   Widget build(BuildContext context) {
//     final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => PetDetailScreen(petId: pet.id!),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Pet image
//               Hero(
//                 tag: 'pet-image-${pet.id}',
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: CachedNetworkImage(
//                     imageUrl: pet.imageUrl,
//                     width: 80,
//                     height: 80,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.grey.shade300,
//                       child: const Icon(Icons.pets),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.grey.shade300,
//                       child: const Icon(Icons.error),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
              
//               // Pet details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           pet.name,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: pet.status == 'lost' 
//                                 ? Colors.red.shade100 
//                                 : Colors.green.shade100,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             pet.status.toUpperCase(),
//                             style: TextStyle(
//                               color: pet.status == 'lost' 
//                                   ? Colors.red.shade800 
//                                   : Colors.green.shade800,
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
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on,
//                           size: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             pet.location,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade500,
//                       ),
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

// // Map Tab - Shows pets on map
// class MapTab extends StatefulWidget {
//   const MapTab({super.key});

//   @override
//   State<MapTab> createState() => _MapTabState();
// }

// class _MapTabState extends State<MapTab> {
//   final PetService _petService = PetService();
//   List<Marker> _markers = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadPetMarkers();
//   }

//   Future<void> _loadPetMarkers() async {
//     final pets = await _petService.getAllPetsOnce();
//     setState(() {
//       _markers = pets
//           .where((pet) => pet.longitude != null)
//           .map((pet) => Marker(
//                 width: 40,
//                 height: 40,
//                 point: LatLng(pet.latitude, pet.longitude),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (_) => PetDetailScreen(petId: pet.id!),
//                     ));
//                   },
//                   child: Icon(
//                     Icons.pets,
//                     color: pet.status == 'lost' ? Colors.red : Colors.green,
//                     size: 36,
//                   ),
//                 ),
//               ))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       options: MapOptions(
//         initialCenter: LatLng(20.5937, 78.9629), // Center of India, change as needed
//         initialZoom: 4,
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//           userAgentPackageName: 'com.example.pettrack',
//         ),
//         MarkerLayer(markers: _markers),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pettrack/screens/login_screen.dart';
import 'package:pettrack/screens/post_pet_screen.dart';
import 'package:pettrack/screens/profile_screen.dart';
import 'package:pettrack/screens/pet_detail_screen.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/screens/qr_scanner_screen.dart';
// import 'package:pettrack/screens/image_search_screen.dart';
import 'package:pettrack/models/pet_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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
        const Center(child: Text('Add Pet')), // Placeholder
        const Center(child: Text('Scan QR')), // Placeholder
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
          // IconButton(
          //   icon: const Icon(Icons.image_search),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //           builder: (context) => const ImageSearchScreen()),
          //     );
          //   },
          //   tooltip: 'AI Image Search',
          // ),
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
                // Lost Pets Tab
                FilterablePetListView(status: 'lost', searchQuery: searchQuery),
                // Found Pets Tab
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

  FilterablePetListView(
      {super.key, required this.status, required this.searchQuery});

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
                      ? 'No $status pets reported yet'
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
          padding: const EdgeInsets.all(8),
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

// Keep the rest of your code (PetCard, MapTab, etc.) the same
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
              builder: (context) => PetDetailScreen(petId: pet.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet image
              Hero(
                tag: 'pet-image-${pet.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: pet.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.pets),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Pet details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pet.status == 'lost'
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pet.status.toUpperCase(),
                            style: TextStyle(
                              color: pet.status == 'lost'
                                  ? Colors.red.shade800
                                  : Colors.green.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.breed} • ${pet.color}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pet.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng _currentPosition = LatLng(20.5937, 78.9629); // Default center of India
  bool _locationLoaded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndLoadMarkers();
  }

  Future<void> _getCurrentLocationAndLoadMarkers() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.deniedForever &&
          permission != LocationPermission.denied) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });

        // Move map to current location
        if (mounted) {
          _mapController.move(_currentPosition, 13.0);
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }

    _loadPetMarkers();
  }

  Future<void> _loadPetMarkers() async {
    try {
      final pets = await _petService.getAllPetsOnce();
      setState(() {
        _markers = [
          // Current location marker
          if (_locationLoaded)
            Marker(
              width: 40,
              height: 40,
              point: _currentPosition,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                ),
              ),
            ),
          // Pet markers
          ...pets
              .where((pet) =>
                  // pet.longitude != null &&
                  pet.latitude != 0.0 &&
                  pet.longitude != 0.0)
              .map((pet) => Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(pet.latitude, pet.longitude),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PetDetailScreen(petId: pet.id!),
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              pet.status == 'lost' ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading pet markers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: _locationLoaded ? 13.0 : 4.0,
            minZoom: 3.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.pettrack',
            ),
            MarkerLayer(markers: _markers),
          ],
        ),
        // Center button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              if (_locationLoaded) {
                _mapController.move(_currentPosition, 13.0);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        // Pet count
        Positioned(
          top: 16,
          left: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Showing ${_markers.length - (_locationLoaded ? 1 : 0)} pets',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
