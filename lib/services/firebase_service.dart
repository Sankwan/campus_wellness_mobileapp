import 'dart:typed_data';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/mood_model.dart';
import '../models/journal_model.dart';
import '../models/meditation_model.dart';
import '../models/auth_result.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String moodsCollection = 'moods';
  static const String journalsCollection = 'journals';
  static const String meditationsCollection = 'meditations';
  static const String sessionsCollection = 'meditation_sessions';
  
  // Timeout duration for network operations
  static const Duration _networkTimeout = Duration(seconds: 15);

  // Authentication Methods
  static Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  static Future<User?> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(displayName);
        
        // Create user document
        await createUserDocument(result.user!, displayName);
      }
      
      return result.user;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Enhanced sign in with better error handling
  static Future<AuthResult> signInWithEmailAndPasswordEnhanced(
      String email, String password) async {
    try {
      // Directly attempt sign in without pre-checking user existence
      // Let Firebase handle the user existence check naturally
      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(_networkTimeout);
          
      return AuthResult.success(result.user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return AuthResult.userNotFound(
            'No HTU student account found with this email. Would you like to create a new account?'
          );
        case 'wrong-password':
          return AuthResult.error('Incorrect password. Please try again or reset your password.');
        case 'invalid-email':
          return AuthResult.error('Please enter a valid HTU email address.');
        case 'invalid-credential':
          return AuthResult.error('Invalid credentials. Please check your email and password.');
        case 'user-disabled':
          return AuthResult.error('This HTU account has been disabled. Please contact support.');
        case 'too-many-requests':
          return AuthResult.error('Too many failed attempts. Please wait a moment before trying again.');
        case 'network-request-failed':
          return AuthResult.networkError('Network error. Please check your internet connection and try again.');
        default:
          print('FirebaseAuthException in signIn: ${e.code} - ${e.message}');
          return AuthResult.error('Sign in failed. Please try again.');
      }
    } on TimeoutException {
      return AuthResult.networkError('Connection timeout. Please check your internet connection and try again.');
    } catch (e) {
      print('Unexpected error in signIn: $e');
      return AuthResult.networkError('Unable to connect to HTU wellness services. Please check your internet connection.');
    }
  }

  /// Enhanced user creation with Firebase's natural error handling
  static Future<AuthResult> createUserWithEmailAndPasswordEnhanced(
      String email, String password, String displayName) async {
    try {
      // Directly attempt user creation - let Firebase handle the email-already-in-use check
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(_networkTimeout);
      
      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(displayName);
        
        // Create user document
        await createUserDocument(result.user!, displayName);
        
        return AuthResult.success(result.user);
      } else {
        return AuthResult.error('Account creation failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return AuthResult.userExists(
            'An HTU student account already exists with this email. Please sign in instead.'
          );
        case 'invalid-email':
          return AuthResult.error('Please enter a valid HTU email address.');
        case 'operation-not-allowed':
          return AuthResult.error('Email/password accounts are not enabled. Please contact support.');
        case 'weak-password':
          return AuthResult.error('Password is too weak. Please choose a stronger password.');
        case 'network-request-failed':
          return AuthResult.networkError('Network error. Please check your internet connection and try again.');
        default:
          print('FirebaseAuthException in createUser: ${e.code} - ${e.message}');
          return AuthResult.error('Account creation failed. Please try again.');
      }
    } on TimeoutException {
      return AuthResult.networkError('Connection timeout. Please check your internet connection and try again.');
    } catch (e) {
      print('Unexpected error in createUser: $e');
      return AuthResult.networkError('Unable to connect to HTU wellness services. Please check your internet connection.');
    }
  }

  // User Document Methods
  static Future<void> createUserDocument(User user, String displayName) async {
    try {
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        displayName: displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());
    } catch (e) {
      print('Create user document error: $e');
      rethrow;
    }
  }

  static Future<UserModel?> getUserDocument(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user document error: $e');
      rethrow;
    }
  }

  static Future<void> updateUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      print('Update user document error: $e');
      rethrow;
    }
  }

  // Mood Methods
  static Future<String> saveMood(MoodModel mood) async {
    try {
      // Save mood as subcollection under user document
      DocumentReference docRef = await _firestore
          .collection(usersCollection)
          .doc(mood.userId)
          .collection('moods')
          .add(mood.toMap());
      
      // Update user's mood count
      await _updateUserMoodCount(mood.userId);
      
      return docRef.id;
    } catch (e) {
      print('Save mood error: $e');
      rethrow;
    }
  }

  static Future<List<MoodModel>> getUserMoods(String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('moods')
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MoodModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Get user moods error: $e');
      rethrow;
    }
  }

  static Future<List<MoodModel>> getMoodsByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('moods')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('timestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MoodModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Get moods by date range error: $e');
      rethrow;
    }
  }

  // Journal Methods
// static final _firestore = FirebaseFirestore.instance;

/// Save a new journal
static Future<String> saveJournal(JournalModel journal) async {
  try {
    // Store journal under the user's subcollection
    DocumentReference docRef = await _firestore
        .collection("users")
        .doc(journal.userId)
        .collection("journals")
        .add(journal.toMap());

    // Increment user's journal count
    await _incrementUserJournalCount(journal.userId, delta: 1);

    return docRef.id;
  } catch (e) {
    print('Save journal error: $e');
    rethrow;
  }
}

/// Update existing journal
static Future<void> updateJournal(JournalModel journal) async {
  try {
    await _firestore
        .collection("users")
        .doc(journal.userId)
        .collection("journals")
        .doc(journal.id)
        .update(journal.copyWith(updatedAt: DateTime.now()).toMap());
  } catch (e) {
    print('Update journal error: $e');
    rethrow;
  }
}

/// Get all journals of a user
static Future<List<JournalModel>> getUserJournals(String userId, {int? limit}) async {
  try {
    Query query = _firestore
        .collection("users")
        .doc(userId)
        .collection("journals")
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return JournalModel.fromMap(data);
    }).toList();
  } catch (e) {
    print('Get user journals error: $e');
    rethrow;
  }
}

/// Delete a journal
static Future<void> deleteJournal(String userId, String journalId) async {
  try {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("journals")
        .doc(journalId)
        .delete();

    // Decrement user's journal count after delete
    await _incrementUserJournalCount(userId, delta: -1);
  } catch (e) {
    print('Delete journal error: $e');
    rethrow;
  }
}

/// Private helper to safely increment/decrement journal count
static Future<void> _incrementUserJournalCount(String userId, {int delta = 1}) async {
  try {
    final userDocRef = _firestore.collection("users").doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDocRef);

      if (!snapshot.exists) {
        // Initialize user doc if it doesn't exist yet
        transaction.set(userDocRef, {"journalCount": (delta > 0 ? delta : 0)});
      } else {
        final currentCount = snapshot.data()?["journalCount"] ?? 0;
        final newCount = currentCount + delta;

        // Prevent going below zero
        transaction.update(userDocRef, {
          "journalCount": newCount < 0 ? 0 : newCount,
        });
      }
    });
  } catch (e) {
    print('Increment user journal count error: $e');
    rethrow;
  }
}

  // Meditation Methods
  static Future<List<MeditationModel>> getMeditations({String? category}) async {
    try {
      Query query = _firestore
          .collection(meditationsCollection)
          .orderBy('popularity', descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MeditationModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Get meditations error: $e');
      rethrow;
    }
  }

  static Future<MeditationModel?> getMeditation(String meditationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(meditationsCollection)
          .doc(meditationId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MeditationModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Get meditation error: $e');
      rethrow;
    }
  }

  // Meditation Session Methods
  static Future<String> startMeditationSession(MeditationSession session) async {
    try {
      // Save meditation session as subcollection under user document
      DocumentReference docRef = await _firestore
          .collection(usersCollection)
          .doc(session.userId)
          .collection('meditation_sessions')
          .add(session.toMap());
      
      return docRef.id;
    } catch (e) {
      print('Start meditation session error: $e');
      rethrow;
    }
  }

  static Future<void> completeMeditationSession(
      String sessionId, MeditationSession session) async {
    try {
      // Update meditation session in user's subcollection
      await _firestore
          .collection(usersCollection)
          .doc(session.userId)
          .collection('meditation_sessions')
          .doc(sessionId)
          .update(session.toMap());
      
      // Update user's meditation count
      await _updateUserMeditationCount(session.userId);
      
      // Update meditation popularity
      await _updateMeditationPopularity(session.meditationId);
    } catch (e) {
      print('Complete meditation session error: $e');
      rethrow;
    }
  }

  static Future<List<MeditationSession>> getUserMeditationSessions(
      String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('meditation_sessions')
          .orderBy('startTime', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MeditationSession.fromMap(data);
      }).toList();
    } catch (e) {
      print('Get user meditation sessions error: $e');
      rethrow;
    }
  }

  // Storage Methods
  static Future<String> uploadImage(String path, List<int> bytes) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putData(bytes as Uint8List);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload image error: $e');
      rethrow;
    }
  }

  // Private helper methods
  static Future<void> _updateUserMoodCount(String userId) async {
    try {
      DocumentReference userRef = _firestore
          .collection(usersCollection)
          .doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          int currentCount = userData['totalMoods'] ?? 0;
          transaction.update(userRef, {'totalMoods': currentCount + 1});
        }
      });
    } catch (e) {
      print('Update user mood count error: $e');
    }
  }

  static Future<void> _updateUserJournalCount(String userId) async {
    try {
      DocumentReference userRef = _firestore
          .collection(usersCollection)
          .doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          int currentCount = userData['totalJournalEntries'] ?? 0;
          transaction.update(userRef, {'totalJournalEntries': currentCount + 1});
        }
      });
    } catch (e) {
      print('Update user journal count error: $e');
    }
  }

  static Future<void> _updateUserMeditationCount(String userId) async {
    try {
      DocumentReference userRef = _firestore
          .collection(usersCollection)
          .doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          int currentCount = userData['totalMeditations'] ?? 0;
          transaction.update(userRef, {'totalMeditations': currentCount + 1});
        }
      });
    } catch (e) {
      print('Update user meditation count error: $e');
    }
  }

  static Future<void> _updateMeditationPopularity(String meditationId) async {
    try {
      DocumentReference meditationRef = _firestore
          .collection(meditationsCollection)
          .doc(meditationId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot meditationDoc = await transaction.get(meditationRef);
        if (meditationDoc.exists) {
          Map<String, dynamic> meditationData = meditationDoc.data() as Map<String, dynamic>;
          int currentCount = meditationData['popularity'] ?? 0;
          transaction.update(meditationRef, {'popularity': currentCount + 1});
        }
      });
    } catch (e) {
      print('Update meditation popularity error: $e');
    }
  }
}
