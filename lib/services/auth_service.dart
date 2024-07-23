import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a user object based on FirebaseUser
  User? _userFromFirebaseUser(User? user) {
    return user != null ? user : null;
  }

  // Auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Reset all user votes
  Future<void> resetAllUserVotes() async {
    try {
      QuerySnapshot usersSnapshot = await _db.collection('user_votes').get();
      for (QueryDocumentSnapshot doc in usersSnapshot.docs) {
        await _db.collection('user_votes').doc(doc.id).update({
          'voted': false,
        });
      }
      print('Voting status reset for all users.');
    } catch (e) {
      print('Error resetting user votes: $e');
    }
  }
}
