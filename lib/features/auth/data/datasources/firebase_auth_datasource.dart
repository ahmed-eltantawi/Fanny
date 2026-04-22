import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthDataSource implements AuthRemoteDataSource {
  static const String _userCacheKeyPrefix = 'auth_user_';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;

  FirebaseAuthDataSource(this._firebaseAuth, this._googleSignIn, this._prefs);

  @override
  Future<UserEntity> loginWithEmail(
      String email, String password, UserRole role) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Login failed');
    final user = await _buildSessionUser(userCredential.user!, role);
    await _persistUser(user);
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail(RegisterParams params) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
    if (userCredential.user == null) throw Exception('Register failed');
    await userCredential.user!.updateDisplayName(params.name);
    final user = UserModel(
      id: userCredential.user!.uid,
      name: userCredential.user!.displayName ?? params.name,
      email: userCredential.user!.email ?? params.email,
      phone: userCredential.user!.phoneNumber ?? params.phone,
      role: params.role,
      avatarUrl: userCredential.user!.photoURL ??
          UserModel.fromRegisterParams(params).avatarUrl,
      specialty: params.specialty,
    );
    await _persistUser(user);
    return user;
  }

  @override
  Future<UserEntity> loginWithGoogle(UserRole role) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user == null) throw Exception('Google login failed');
    final user = await _buildSessionUser(userCredential.user!, role);
    await _persistUser(user);
    return user;
  }

  @override
  Future<String> sendPhoneOtp(String phoneNumber) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (mostly Android).
        // Since we split sending and verifying, this might auto-verify without user input.
        // For simplicity, we just complete with 'auto_verified' if it happens.
        if (!completer.isCompleted) {
          completer.complete(
              'auto_verified_${credential.smsCode ?? credential.verificationId}');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout
      },
    );

    return completer.future;
  }

  @override
  Future<UserEntity> verifyPhoneOtp(
      String verificationId, String otp, UserRole role) async {
    // If it was auto-verified, the verificationId might be 'auto_verified_...'
    // For normal flow:
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user == null)
      throw Exception('Phone verification failed');
    final user = await _buildSessionUser(userCredential.user!, role);
    await _persistUser(user);
    return user;
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap(_restoreSessionUser);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _restoreSessionUser(_firebaseAuth.currentUser);
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserModel> _buildSessionUser(User user, UserRole role) async {
    final savedUser = await _loadSavedUser(user.uid);
    final preserveSavedMetadata = savedUser?.role == role;

    return UserModel(
      id: user.uid,
      name: user.displayName ?? savedUser?.name ?? 'User',
      email: user.email ?? savedUser?.email ?? '',
      phone: user.phoneNumber ?? savedUser?.phone ?? '',
      role: role,
      avatarUrl: user.photoURL ??
          savedUser?.avatarUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.displayName ?? savedUser?.name ?? 'User')}&background=1A237E&color=fff&size=200',
      specialty: preserveSavedMetadata ? savedUser?.specialty : null,
      rating: preserveSavedMetadata ? savedUser?.rating : null,
      completedJobs: preserveSavedMetadata ? savedUser?.completedJobs : null,
      bio: preserveSavedMetadata ? savedUser?.bio : null,
    );
  }

  Future<UserEntity?> _restoreSessionUser(User? firebaseUser) async {
    if (firebaseUser == null) return null;

    final savedUser = await _loadSavedUser(firebaseUser.uid);
    if (savedUser == null) {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return null;
    }

    return _buildSessionUser(firebaseUser, savedUser.role);
  }

  Future<UserModel?> _loadSavedUser(String uid) async {
    final json = _prefs.getString('$_userCacheKeyPrefix$uid');
    if (json == null || json.isEmpty) return null;

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistUser(UserEntity user) async {
    final encoded = jsonEncode(UserModel.fromEntity(user).toJson());
    await _prefs.setString('$_userCacheKeyPrefix${user.id}', encoded);
  }
}
