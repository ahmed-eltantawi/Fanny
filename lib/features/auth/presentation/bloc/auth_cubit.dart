import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  String? _verificationId;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthCubit(this._repository) : super(const AuthInitial());

  Future<void> init() async {
    final currentUser = await _repository.getCurrentUser();
    emit(
      currentUser != null
          ? AuthAuthenticated(currentUser)
          : const AuthUnauthenticated(),
    );

    await _authSubscription?.cancel();
    _authSubscription = _repository.authStateChanges().listen((user) {
      if (user == null) {
        if (state is! AuthUnauthenticated) {
          emit(const AuthUnauthenticated());
        }
        return;
      }

      if (state is AuthAuthenticated &&
          (state as AuthAuthenticated).user == user) {
        return;
      }

      emit(AuthAuthenticated(user));
    });
  }

  Future<void> loginWithEmail(String email, String password, UserRole role) async {
    emit(const AuthLoading());
    final result = await _repository.loginWithEmail(email, password, role);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> registerWithEmail(RegisterParams params) async {
    emit(const AuthLoading());
    final result = await _repository.registerWithEmail(params);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> loginWithGoogle(UserRole role) async {
    emit(const AuthLoading());
    final result = await _repository.loginWithGoogle(role);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<bool> sendPhoneOtp(String phoneNumber) async {
    emit(const AuthLoading());
    final result = await _repository.sendPhoneOtp(phoneNumber);
    return result.fold(
      (failure) {
        emit(AuthError(failure.message));
        return false;
      },
      (verificationId) {
        _verificationId = verificationId;
        emit(const AuthInitial());
        return true;
      },
    );
  }

  Future<void> verifyPhoneOtp(String otp, UserRole role) async {
    if (_verificationId == null) {
      emit(const AuthError('حدث خطأ أثناء التحقق، يرجى إعادة المحاولة'));
      return;
    }
    emit(const AuthLoading());
    final result = await _repository.verifyPhoneOtp(_verificationId!, otp, role);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
