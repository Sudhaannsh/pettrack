// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/screens/pet_detail_screen.dart';

// class MapScreen extends StatefulWidget {
//   final String? filterStatus; // Optional filter for 'lost' or 'found' pets

//   const MapScreen({super.key, this.filterStatus});

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final MapController _mapController = MapController();
//   final PetService _petService = PetService();

//   List<Marker> _markers = [];
//   LatLng _currentPosition =
//       LatLng(37.42796133580664, -122.085749655962); // Default to Google HQ
//   bool _isLoading = true;
//   bool _locationLoaded = false;
//   String _errorMessage = '';
//   double _searchRadius = 10.0; // km

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _errorMessage = 'Location permissions are denied';
//             _isLoading = false;
//           });
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _errorMessage = 'Location permissions are permanently denied';
//           _isLoading = false;
//         });
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );

//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//         _locationLoaded = true;
//       });

//       // Move map to current location once it's loaded
//       if (mounted) {
//         _mapController.move(_currentPosition, 13.0);
//       }

//       _loadPets(position.latitude, position.longitude);
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error getting location: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadPets(double latitude, double longitude) async {
//     try {
//       Stream<List<PetModel>> petsStream;

//       if (widget.filterStatus != null) {
//         petsStream = _petService.getPetsByStatus(widget.filterStatus!);
//       } else {
//         petsStream = _petService.getAllPets();
//       }

//       petsStream.listen((pets) {
//         final filteredPets = _filterPetsByDistance(
//           pets,
//           latitude,
//           longitude,
//           _searchRadius,
//         );

//         _updateMarkers(filteredPets);

//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading pets: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   List<PetModel> _filterPetsByDistance(
//     List<PetModel> pets,
//     double latitude,
//     double longitude,
//     double radiusKm,
//   ) {
//     return pets.where((pet) {
//       if (pet.longitude == null || pet.latitude == 0.0 || pet.longitude == 0.0)
//         return false;
//       final distance = Geolocator.distanceBetween(
//         latitude,
//         longitude,
//         pet.latitude,
//         pet.longitude,
//       );
//       return distance / 1000 <= radiusKm;
//     }).toList();
//   }

//   void _updateMarkers(List<PetModel> pets) {
//     final markers = pets.map((pet) {
//       return Marker(
//         width: 80.0,
//         height: 80.0,
//         point: LatLng(pet.latitude, pet.longitude),
//         child: GestureDetector(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => PetDetailScreen(petId: pet.id!),
//               ),
//             );
//           },
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: pet.status == 'lost' ? Colors.red : Colors.green,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.pets,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               Text(
//                 pet.name,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }).toList();

//     setState(() {
//       _markers = markers;
//     });
//   }

//   void _updateSearchRadius(double radius) {
//     setState(() {
//       _searchRadius = radius;
//     });

//     // Reload pets with new radius
//     _loadPets(_currentPosition.latitude, _currentPosition.longitude);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 60,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _getCurrentLocation,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Stack(
//       children: [
//         FlutterMap(
//           mapController: _mapController,
//           options: MapOptions(
//             initialCenter: _currentPosition,
//             initialZoom: _locationLoaded ? 13.0 : 4.0,
//             minZoom: 5.0,
//             maxZoom: 18.0,
//           ),
//           children: [
//             TileLayer(
//               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//               userAgentPackageName: 'com.example.pettrack',
//             ),
//               MarkerLayer(
//               markers: [
//                 // Current location marker
//                 if (_locationLoaded)
//                   Marker(
//                     width: 60, // Increased from 20
//                     height: 60, // Increased from 20
//                     point: _currentPosition,
//                     child: GestureDetector(
//                       // Add GestureDetector
//                       onTap: () {
//                         // Center map on current location
//                         _mapController.move(_currentPosition, 15.0);
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.8),
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 3),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.3),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.my_location,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ..._markers,
//               ],
//             ),
//             if (_locationLoaded)
//               CircleLayer(
//                 circles: [
//                   CircleMarker(
//                     point: _currentPosition,
//                     color: Colors.blue.withOpacity(0.2),
//                     borderColor: Colors.blue.withOpacity(0.7),
//                     borderStrokeWidth: 2,
//                     radius: _searchRadius * 1000, // Convert km to meters
//                   ),
//                 ],
//               ),
//           ],
//         ),

//         // Radius control
//         Positioned(
//           top: 16,
//           left: 16,
//           right: 16,
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       'Search Radius: ${_searchRadius.toStringAsFixed(1)} km',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Slider(
//                     value: _searchRadius,
//                     min: 1.0,
//                     max: 50.0,
//                     divisions: 49,
//                     label: '${_searchRadius.toStringAsFixed(1)} km',
//                     onChanged: (value) {
//                       _updateSearchRadius(value);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // Pet count
//         Positioned(
//           bottom: 16,
//           left: 16,
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Showing ${_markers.length} pets',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Center button
//         Positioned(
//           bottom: 16,
//           right: 16,
//           child: FloatingActionButton(
//             onPressed: () {
//               if (_locationLoaded) {
//                 _mapController.move(_currentPosition, 13.0);
//               }
//             },
//             child: const Icon(Icons.my_location),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:pettrack/screens/lost_found_pet_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final String? filterStatus; // Optional filter for 'lost' or 'found' pets

  const MapScreen({super.key, this.filterStatus});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LostFoundPetService _lostFoundPetService = LostFoundPetService();

  List<Marker> _markers = [];
  LatLng _currentPosition =
      LatLng(37.42796133580664, -122.085749655962); // Default to Google HQ
  bool _isLoading = true;
  bool _locationLoaded = false;
  String _errorMessage = '';
  double _searchRadius = 10.0; // km

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationLoaded = true;
      });

      // Move map to current location once it's loaded
      if (mounted) {
        _mapController.move(_currentPosition, 13.0);
      }

      _loadPets(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPets(double latitude, double longitude) async {
    try {
      List<LostFoundPetModel> pets;

      if (widget.filterStatus != null) {
        pets = await _lostFoundPetService.getPetsByStatus(widget.filterStatus!).first;
      } else {
        pets = await _lostFoundPetService.getAllLostFoundPetsOnce();
      }

      final filteredPets = _filterPetsByDistance(
        pets,
        latitude,
        longitude,
        _searchRadius,
      );

      _updateMarkers(filteredPets);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading pets: $e';
        _isLoading = false;
      });
    }
  }

  List<LostFoundPetModel> _filterPetsByDistance(
    List<LostFoundPetModel> pets,
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    return pets.where((pet) {
      if (pet.latitude == 0.0 || pet.longitude == 0.0) return false;
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        pet.latitude,
        pet.longitude,
      );
      return distance / 1000 <= radiusKm;
    }).toList();
  }

  void _updateMarkers(List<LostFoundPetModel> pets) {
    final markers = pets.map((pet) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(pet.latitude, pet.longitude),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LostFoundPetDetailScreen(petId: pet.id!),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: pet.status == 'lost' ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  pet.status == 'lost' ? Icons.search : Icons.pets,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    setState(() {
      _markers = markers;
    });
  }

  void _updateSearchRadius(double radius) {
    setState(() {
      _searchRadius = radius;
    });

    // Reload pets with new radius
    _loadPets(_currentPosition.latitude, _currentPosition.longitude);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: _locationLoaded ? 13.0 : 4.0,
            minZoom: 5.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pettrack',
            ),
            MarkerLayer(
              markers: [
                // Current location marker
                if (_locationLoaded)
                  Marker(
                    width: 60,
                    height: 60,
                    point: _currentPosition,
                    child: GestureDetector(
                      onTap: () {
                        _mapController.move(_currentPosition, 15.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ..._markers,
              ],
            ),
            if (_locationLoaded)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentPosition,
                    color: Colors.blue.withOpacity(0.2),
                    borderColor: Colors.blue.withOpacity(0.7),
                    borderStrokeWidth: 2,
                    radius: _searchRadius * 1000, // Convert km to meters
                  ),
                ],
              ),
          ],
        ),

        // Radius control
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Search Radius: ${_searchRadius.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Slider(
                    value: _searchRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_searchRadius.toStringAsFixed(1)} km',
                    onChanged: (value) {
                      _updateSearchRadius(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Pet count and legend
        Positioned(
          bottom: 80,
          left: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Showing ${_markers.length} pets',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Lost', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Found', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
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

        // Refresh button
        Positioned(
          bottom: 16,
          right: 80,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadPets(_currentPosition.latitude, _currentPosition.longitude);
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
