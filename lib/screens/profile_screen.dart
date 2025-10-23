// import 'package:flutter/material.dart';
// import 'package:pettrack/services/auth_service.dart';
// import 'package:pettrack/models/user_model.dart';
// import 'package:pettrack/screens/my_pets_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final AuthService _authService = AuthService();
//   // Removed unused Firestore instance
//   UserModel? _user;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     if (!mounted) return;
    
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final userData = await _authService.getUserData();
      
//       if (!mounted) return;
      
//       setState(() {
//         _user = userData;
//         if (userData == null) {
//           print('No user data found in Firestore');
//         }
//       });
//     } catch (e) {
//       print('Error loading user data: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_user == null) {
//       return const Center(child: Text('User not found'));
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(height: 20),
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.blue.shade100,
//             backgroundImage: _user?.photoUrl != null
//                 ? NetworkImage(_user!.photoUrl!)
//                 : null,
//             child: _user?.photoUrl == null
//                 ? Text(
//                     _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
//                     style: const TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             _user!.name,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             _user!.email,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 30),
//           _buildInfoCard('My Pets', 'View and manage your pets', Icons.pets,
//               () {
//             Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => const MyPetsScreen()),
//             );
//           }),
//           _buildInfoCard('Settings', 'App preferences and account settings',
//               Icons.settings, () {
//             // Navigate to Settings screen
//           }),
//           _buildInfoCard('Help & Support', 'Get help with the app',
//               Icons.help_outline, () {
//             // Navigate to Help screen
//           }),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: () async {
//                 await _authService.signOut();
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: const BorderSide(color: Colors.red),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: const Text('Sign Out'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       String title, String subtitle, IconData icon, VoidCallback onTap) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(title),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pettrack/services/auth_service.dart';
import 'package:pettrack/models/user_model.dart';
import 'package:pettrack/screens/my_pets_screen.dart';
import 'package:pettrack/screens/login_screen.dart'; // ADD this import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();

      if (!mounted) return;

      setState(() {
        _user = userData;
        if (userData == null) {
          print('No user data found in Firestore');
        }
      });
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ADD this method for proper sign out handling
  Future<void> _handleSignOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign out
      await _authService.signOut();

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to login screen and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // This removes all previous routes
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog if it's open
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ADD this method for sign out confirmation
  Future<void> _showSignOutDialog() async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      _handleSignOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text('User not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            backgroundImage:
                _user?.photoUrl != null ? NetworkImage(_user!.photoUrl!) : null,
            child: _user?.photoUrl == null
                ? Text(
                    _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            _user!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          _buildInfoCard('My Pets', 'View and manage your pets', Icons.pets,
              () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MyPetsScreen()),
            );
          }),
          _buildInfoCard('Settings', 'App preferences and account settings',
              Icons.settings, () {
            // Navigate to Settings screen
          }),
          _buildInfoCard(
              'Help & Support', 'Get help with the app', Icons.help_outline,
              () {
            // Navigate to Help screen
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showSignOutDialog, // CHANGED: Use the new method
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
