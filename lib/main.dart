import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/offers/presentation/bloc/offers_cubit.dart';
import 'features/requests/presentation/bloc/requests_cubit.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await initDependencies();
  await sl<AuthCubit>().init();

  // Restore saved locale
  await sl<LocaleCubit>().init();

  runApp(const FannyApp());
}

class FannyApp extends StatelessWidget {
  const FannyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        BlocProvider<RequestsCubit>(create: (_) => sl<RequestsCubit>()),
        BlocProvider<OffersCubit>(create: (_) => sl<OffersCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'Fanny | فاني',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // ── Routing ──────────────────────────────────────────────────
            routerConfig: AppRouter.router(sl<AuthCubit>()),
            // ── Localisation ─────────────────────────────────────────────
            locale: locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              // Force RTL for Arabic, LTR for English
              return Directionality(
                textDirection: locale.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
