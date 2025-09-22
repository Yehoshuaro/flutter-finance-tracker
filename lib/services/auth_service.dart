// import 'package:firebase_auth/firebase_auth.dart';
import 'user_prefs_service.dart';

class AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Placeholder user model for no-firebase build
  // Represents absence of authenticated user
  dynamic get currentUser => null;

  // Stubbed auth state stream: always emits null once
  Stream<dynamic> get authStateChanges async* {
    yield null;
  }

  Future<dynamic> signIn(String email, String password) async {
    // No-op when Firebase is disabled
    throw Exception('Authentication is disabled in no-Firebase mode');
  }

  Future<dynamic> register(String email, String password) async {
    // No-op when Firebase is disabled
    throw Exception('Registration is disabled in no-Firebase mode');
  }

  Future<void> signOut() async {
    // Clear guest data only
    final userPrefsService = UserPrefsService();
    await userPrefsService.clearGuestData();
    // await _auth.signOut();
  }
} 