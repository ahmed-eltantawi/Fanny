import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Params for register use case (Email/Password).
class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final String? specialty;
  const RegisterParams({
    required this.name, required this.email, required this.phone,
    required this.password, required this.role, this.specialty,
  });
}

/// Auth repository contract.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password, UserRole role);
  Future<Either<Failure, UserEntity>> registerWithEmail(RegisterParams params);
  Future<Either<Failure, UserEntity>> loginWithGoogle(UserRole role);
  
  // Phone Auth
  Future<Either<Failure, String>> sendPhoneOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyPhoneOtp(String verificationId, String otp, UserRole role);

  Future<Either<Failure, void>> logout();
  Stream<UserEntity?> authStateChanges();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> getCachedUser();
}
