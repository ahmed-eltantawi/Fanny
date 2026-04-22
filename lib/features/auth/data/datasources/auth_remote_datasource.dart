import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Abstract datasource contract for auth.
abstract class AuthRemoteDataSource {
  Future<UserEntity> loginWithEmail(String email, String password, UserRole role);
  Future<UserEntity> registerWithEmail(RegisterParams params);
  Future<UserEntity> loginWithGoogle(UserRole role);
  
  // Phone Auth
  Future<String> sendPhoneOtp(String phoneNumber);
  Future<UserEntity> verifyPhoneOtp(String verificationId, String otp, UserRole role);
  
  Stream<UserEntity?> authStateChanges();
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}

/// Mock implementation — instantly simulates a backend response.
class AuthMockDataSource implements AuthRemoteDataSource {
  UserEntity? _currentUser;
  @override
  Future<UserEntity> loginWithEmail(String email, String password, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final user = MockData.findUserByEmail(email, role);
    _currentUser = user ?? _demoUser(email, role);
    return _currentUser!;
  }

  @override
  Future<UserEntity> registerWithEmail(RegisterParams params) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final model = UserModel.fromRegisterParams(params);
    MockData.users.add(model);
    _currentUser = model;
    return model;
  }
  
  @override
  Future<UserEntity> loginWithGoogle(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 900));
    _currentUser = _demoUser('google@example.com', role);
    return _currentUser!;
  }
  
  @override
  Future<String> sendPhoneOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return 'mock_verification_id';
  }
  
  @override
  Future<UserEntity> verifyPhoneOtp(String verificationId, String otp, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 900));
    _currentUser = _demoUser('phone@example.com', role);
    return _currentUser!;
  }

  @override
  Stream<UserEntity?> authStateChanges() async* {
    yield _currentUser;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }
  
  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  UserModel _demoUser(String email, UserRole role) {
    return UserModel(
      id: 'user_demo_${role.name}',
      name: _demoName(role),
      email: email,
      phone: '0100000000',
      role: role,
      avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_demoName(role))}&background=1A237E&color=fff&size=200',
      specialty: role == UserRole.technician ? 'plumbing' : null,
      rating: role == UserRole.technician ? 4.7 : null,
      completedJobs: role == UserRole.technician ? 55 : null,
    );
  }

  String _demoName(UserRole role) {
    switch (role) {
      case UserRole.customer:   return 'عميل تجريبي';
      case UserRole.technician: return 'فني تجريبي';
      case UserRole.admin:      return 'مشرف تجريبي';
    }
  }
}

/// Repository implementation that maps datasource results to Either<Failure,T>.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  UserEntity? _cachedUser;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password, UserRole role) async {
    try {
      final user = await dataSource.loginWithEmail(email, password, role);
      _cachedUser = user;
      return Right(user);
    } catch (e) {
      print('Email Login Error: $e');
      return const Left(ServerFailure('فشل تسجيل الدخول بالبريد الإلكتروني'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail(RegisterParams params) async {
    try {
      final user = await dataSource.registerWithEmail(params);
      _cachedUser = user;
      return Right(user);
    } catch (e) {
      print('Email Register Error: $e');
      return const Left(ServerFailure('فشل إنشاء الحساب'));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle(UserRole role) async {
    try {
      final user = await dataSource.loginWithGoogle(role);
      _cachedUser = user;
      return Right(user);
    } catch (e) {
      print('Google Login Error: $e');
      return const Left(ServerFailure('فشل تسجيل الدخول بواسطة جوجل'));
    }
  }
  
  @override
  Future<Either<Failure, String>> sendPhoneOtp(String phoneNumber) async {
    try {
      final verId = await dataSource.sendPhoneOtp(phoneNumber);
      return Right(verId);
    } catch (e) {
      print('Phone OTP Error: $e');
      return const Left(ServerFailure('فشل إرسال كود التحقق'));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> verifyPhoneOtp(String verificationId, String otp, UserRole role) async {
    try {
      final user = await dataSource.verifyPhoneOtp(verificationId, otp, role);
      _cachedUser = user;
      return Right(user);
    } catch (e) {
      print('Verify OTP Error: $e');
      return const Left(ServerFailure('فشل التحقق من الكود'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await dataSource.logout();
    _cachedUser = null;
    return const Right(null);
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return dataSource.authStateChanges().map((user) {
      _cachedUser = user;
      return user;
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    _cachedUser ??= await dataSource.getCurrentUser();
    return _cachedUser;
  }

  @override
  Future<UserEntity?> getCachedUser() async => getCurrentUser();
}
