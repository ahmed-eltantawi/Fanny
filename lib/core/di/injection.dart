import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/locale_cubit.dart';
import '../network/dio_client.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/requests/data/datasources/requests_remote_datasource.dart';
import '../../features/requests/domain/repositories/requests_repository.dart';
import '../../features/requests/presentation/bloc/requests_cubit.dart';

import '../../features/offers/data/datasources/offers_remote_datasource.dart';
import '../../features/offers/domain/repositories/offers_repository.dart';
import '../../features/offers/presentation/bloc/offers_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => DioClient());

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LocaleCubit());

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => FirebaseAuthDataSource(sl(), sl(), sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  // AuthCubit is registered as a singleton so GoRouter can access it before
  // the widget tree is built.
  sl.registerSingleton<AuthCubit>(AuthCubit(sl()));

  // ── Requests ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<RequestsRemoteDataSource>(
      () => RequestsMockDataSource());
  sl.registerLazySingleton<RequestsRepository>(
      () => RequestsRepositoryImpl(sl()));
  // RequestsCubit is shared across technician & admin pages via BlocProvider
  sl.registerFactory(() => RequestsCubit(sl()));

  // ── Offers ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OffersRemoteDataSource>(
      () => OffersMockDataSource());
  sl.registerLazySingleton<OffersRepository>(() => OffersRepositoryImpl(sl()));
  sl.registerFactory(() => OffersCubit(sl()));
}
