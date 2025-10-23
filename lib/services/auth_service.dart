import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pettrack/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      // Create a new user document in Firestore
      await _createUserInFirestore(result.user!, name);
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
 
  // Create user in Firestore
  Future<void> _createUserInFirestore(User user, String name) async {
    try {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email!,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      print('User created in Firestore successfully: ${user.uid}');
    } catch (e) {
      print('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      if (currentUser == null) return null;
      
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!doc.exists) {
        print('No user document found for ID: ${currentUser!.uid}');
        return null;
      }
      
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}