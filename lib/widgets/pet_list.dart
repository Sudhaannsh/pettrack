// // import 'package:flutter/material.dart';
// // import 'package:pettrack/models/pet_model.dart';
// // import 'package:pettrack/services/pet_service.dart';
// // import 'package:pettrack/screens/pet_detail_screen.dart';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:intl/intl.dart';
// // import 'package:pettrack/screens/lost_found_pet_detail_screen.dart';

// // class PetList extends StatelessWidget {
// //   final String status;
// //   final PetService _petService = PetService();

// //   PetList({super.key, required this.status});

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<List<PetModel>>(
// //       stream: _petService.getPetsByStatus(status),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(
// //             child: Text('Error: ${snapshot.error}'),
// //           );
// //         }

// //         final pets = snapshot.data;
// //         if (pets == null || pets.isEmpty) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(
// //                   Icons.pets,
// //                   size: 60,
// //                   color: Colors.grey,
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'No ${status.toLowerCase()} pets reported yet',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         return ListView.builder(
// //           itemCount: pets.length,
// //           itemBuilder: (context, index) {
// //             final pet = pets[index];
// //             return PetCard(pet: pet);
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// // class PetCard extends StatelessWidget {
// //   final PetModel pet;

// //   const PetCard({super.key, required this.pet});

// //   @override
// //   Widget build(BuildContext context) {
// //     final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);
    
// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: InkWell(
// //         onTap: () {
// //           Navigator.of(context).push(
// //             MaterialPageRoute(
// //               builder: (context) => PetDetailScreen(petId: pet.id!),
// //             ),
// //           );
// //         },
// //         borderRadius: BorderRadius.circular(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Pet image
// //             ClipRRect(
// //               borderRadius: const BorderRadius.only(
// //                 topLeft: Radius.circular(12),
// //                 topRight: Radius.circular(12),
// //               ),
// //               child: CachedNetworkImage(
// //                 imageUrl: pet.imageUrl,
// //                 height: 180,
// //                 width: double.infinity,
// //                 fit: BoxFit.cover,
// //                 placeholder: (context, url) => Container(
// //                   height: 180,
// //                   color: Colors.grey.shade300,
// //                   child: const Center(
// //                     child: CircularProgressIndicator(),
// //                   ),
// //                 ),
// //                 errorWidget: (context, url, error) => Container(
// //                   height: 180,
// //                   color: Colors.grey.shade300,
// //                   child: const Icon(
// //                     Icons.error,
// //                     color: Colors.red,
// //                   ),
// //                 ),
// //               ),
// //             ),
            
// //             // Status badge
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: pet.status == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Text(
// //                       pet.status.toUpperCase(),
// //                       style: TextStyle(
// //                         color: pet.status == 'lost' ? Colors.red.shade800 : Colors.green.shade800,
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ),
// //                   Text(
// //                     formattedDate,
// //                     style: TextStyle(
// //                       color: Colors.grey.shade600,
// //                       fontSize: 12,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
            
// //             // Pet name and breed
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
// //               child: Text(
// //                 pet.name,
// //                 style: const TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
            
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
// //               child: Text(
// //                 '${pet.breed} • ${pet.color}',
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   color: Colors.grey.shade700,
// //                 ),
// //               ),
// //             ),
            
// //             // Location
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.location_on,
// //                     size: 16,
// //                     color: Colors.grey.shade600,
// //                   ),
// //                   const SizedBox(width: 4),
// //                   Expanded(
// //                     child: Text(
// //                       pet.location,
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: Colors.grey.shade600,
// //                       ),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.dart';

// class PetDetailScreen extends StatefulWidget {
//   final String petId;

//   const PetDetailScreen({super.key, required this.petId});

//   @override
//   State<PetDetailScreen> createState() => _PetDetailScreenState();
// }

// class _PetDetailScreenState extends State<PetDetailScreen> {
//   final PetService _petService = PetService();
//   PetModel? _pet;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPetDetails();
//   }

//   Future<void> _loadPetDetails() async {
//     try {
//       final pet = await _petService.getPetById(widget.petId);
//       setState(() {
//         _pet = pet;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading pet details: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _contactOwner() async {
//     if (_pet?.ownerContact != null) {
//       final Uri phoneUri = Uri(scheme: 'tel', path: _pet!.ownerContact!);
//       if (await canLaunchUrl(phoneUri)) {
//         await launchUrl(phoneUri);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Pet Details')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_pet == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Pet Details')),
//         body: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.red),
//               SizedBox(height: 16),
//               Text('Pet not found', style: TextStyle(fontSize: 18)),
//             ],
//           ),
//         ),
//       );
//     }

//     final pet = _pet!;
//     final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(pet.name),
//         actions: [
//           if (pet.ownerContact != null)
//             IconButton(
//               icon: const Icon(Icons.phone),
//               onPressed: _contactOwner,
//               tooltip: 'Contact Owner',
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Pet Image
//             Hero(
//               tag: 'pet_${pet.id}',
//               child: CachedNetworkImage(
//                 imageUrl: pet.imageUrl,
//                 height: 300,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   color: Colors.grey.shade200,
//                   child: const Center(child: CircularProgressIndicator()),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   color: Colors.grey.shade200,
//                   child: const Icon(Icons.pets, size: 100),
//                 ),
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Status Badge for owned pets
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: pet.isLost
//                           ? Colors.red.shade100
//                           : Colors.blue.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       pet.isLost ? 'LOST' : 'OWNED',
//                       style: TextStyle(
//                         color: pet.isLost
//                             ? Colors.red.shade900
//                             : Colors.blue.shade900,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Pet Name
//                   Text(
//                     pet.name,
//                     style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Breed and Date
//                   Row(
//                     children: [
//                       Icon(Icons.pets, size: 20, color: Colors.grey.shade600),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           pet.breed,
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Added on $formattedDate',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),

//                   const SizedBox(height: 24),
//                   const Divider(),
//                   const SizedBox(height: 16),

//                   // Details Section
//                   _buildDetailSection('Details', [
//                     if (pet.color.isNotEmpty)
//                       _buildDetailRow('Color', pet.color, Icons.palette),
//                     if (pet.age.isNotEmpty)
//                       _buildDetailRow('Age', pet.age, Icons.cake),
//                     if (pet.weight.isNotEmpty)
//                       _buildDetailRow(
//                           'Weight', pet.weight, Icons.fitness_center),
//                     if (pet.microchipId != null && pet.microchipId!.isNotEmpty)
//                       _buildDetailRow(
//                           'Microchip ID', pet.microchipId!, Icons.qr_code),
//                   ]),

//                   // Description
//                   if (pet.description != null &&
//                       pet.description!.isNotEmpty) ...[
//                     const SizedBox(height: 24),
//                     _buildDetailSection('Description', [
//                       Text(
//                         pet.description!,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade700,
//                           height: 1.5,
//                         ),
//                       ),
//                     ]),
//                   ],

//                   // Medical Notes
//                   if (pet.medicalNotes != null &&
//                       pet.medicalNotes!.isNotEmpty) ...[
//                     const SizedBox(height: 24),
//                     _buildDetailSection('Medical Information', [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.red.shade200),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Icon(
//                               Icons.medical_services,
//                               color: Colors.red.shade700,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 pet.medicalNotes!,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.red.shade900,
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ]),
//                   ],

//                   // Vaccinations
//                   if (pet.vaccinations != null &&
//                       pet.vaccinations!.isNotEmpty) ...[
//                     const SizedBox(height: 24),
//                     _buildDetailSection('Vaccinations', [
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: pet.vaccinations!.map((vaccination) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade100,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(color: Colors.green.shade300),
//                             ),
//                             child: Text(
//                               vaccination,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.green.shade800,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ]),
//                   ],

//                   const SizedBox(height: 32),

//                   // Contact Owner Button
//                   if (pet.ownerContact != null)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _contactOwner,
//                         icon: const Icon(Icons.phone),
//                         label: const Text('Contact Owner'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey.shade600),
//           const SizedBox(width: 12),
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:pettrack/screens/lost_found_pet_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PetList extends StatelessWidget {
  final String status;
  final LostFoundPetService _lostFoundPetService = LostFoundPetService();

  PetList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LostFoundPetModel>>(
      stream: _lostFoundPetService.getPetsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Trigger rebuild
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final pets = snapshot.data;
        if (pets == null || pets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'lost' ? Icons.search : Icons.pets,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.toLowerCase()} pets reported yet',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == 'lost' 
                      ? 'Be the first to report a lost pet'
                      : 'Be the first to report a found pet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return LostFoundPetCard(pet: pet);
          },
        );
      },
    );
  }
}

class LostFoundPetCard extends StatelessWidget {
  final LostFoundPetModel pet;

  const LostFoundPetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LostFoundPetDetailScreen(petId: pet.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: pet.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              ),
            ),
            
            // Status badge and date
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pet.status == 'lost' 
                          ? Colors.red.shade100 
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pet.status == 'lost' ? Icons.search : Icons.pets,
                          size: 14,
                          color: pet.status == 'lost' 
                              ? Colors.red.shade800 
                              : Colors.green.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.status.toUpperCase(),
                          style: TextStyle(
                            color: pet.status == 'lost' 
                                ? Colors.red.shade800 
                                : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Pet name and breed
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                pet.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
                        Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Text(
                    pet.breed,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (pet.color.isNotEmpty) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      pet.color,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  if (pet.petType != null && pet.petType!.isNotEmpty) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      pet.petType!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Location and last seen date
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pet.location.isNotEmpty
                          ? pet.location
                          : 'Location not specified',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Last seen/found date
            if (pet.lastSeenDate != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pet.status == 'lost' ? 'Last seen' : 'Found on'}: ${DateFormat('MMM d, yyyy').format(pet.lastSeenDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Contact info indicator
            if (pet.contactPhone != null && pet.contactPhone!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: pet.status == 'lost'
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Contact available',
                      style: TextStyle(
                        fontSize: 12,
                        color: pet.status == 'lost'
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Description preview
            if (pet.description != null && pet.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  pet.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Alternative simple card for list view
class SimpleLostFoundPetCard extends StatelessWidget {
  final LostFoundPetModel pet;

  const SimpleLostFoundPetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LostFoundPetDetailScreen(petId: pet.id!),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: pet.status == 'lost'
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
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
                    if (pet.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pet.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
