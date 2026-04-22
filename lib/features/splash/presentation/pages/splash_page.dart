import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

/// Animated splash screen shown at app start.
/// Navigates to /main or /login after the animation completes.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // Logo fade + scale
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Tagline slide-up
  late final AnimationController _tagCtrl;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _tagOpacity;

  // Background blob
  late final AnimationController _blobCtrl;
  late final Animation<double> _blobScale;

  // Dots (loading indicator)
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    // Blob: expands from 0 → 1 while logo fades in
    _blobCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _blobScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blobCtrl, curve: Curves.elasticOut),
    );
    _blobCtrl.forward();

    // Logo: zoom in + fade
    _logoCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.6)),
    );
    Future.delayed(const Duration(milliseconds: 300), _logoCtrl.forward);

    // Tagline: slide up + fade
    _tagCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _tagSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));
    _tagOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 800), _tagCtrl.forward);

    // Dots pulse
    _dotsCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    // Navigate after 2.6 s
    Future.delayed(const Duration(milliseconds: 2600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.go('/main');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _tagCtrl.dispose();
    _blobCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Decorative background blob ────────────────────────────
          Positioned(
            bottom: -size.height * 0.15,
            left: -size.width * 0.2,
            child: ScaleTransition(
              scale: _blobScale,
              child: Container(
                width: size.width * 1.4,
                height: size.width * 1.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySurface,
                ),
              ),
            ),
          ),

          // ── Top-right accent circle ───────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: ScaleTransition(
              scale: _blobScale,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

          // ── Dot grid decoration ───────────────────────────────────
          Positioned(
            top: size.height * 0.08,
            right: 24,
            child: AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.4 + 0.4 * _dotsCtrl.value,
                child: _DotGrid(color: AppColors.primary),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            left: 24,
            child: AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.3 + 0.3 * (1 - _dotsCtrl.value),
                child: _DotGrid(color: AppColors.primary, rows: 3, cols: 3),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo image
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Image.asset(
                      AppImages.logo,
                      width: size.width * 0.58,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Tagline
                SlideTransition(
                  position: _tagSlide,
                  child: FadeTransition(
                    opacity: _tagOpacity,
                    child: Column(
                      children: [
                        Text(
                          'خدمات المنزل في متناول يدك',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Home services at your fingertips',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Animated loading dots ─────────────────────────────────
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: FadeTransition(
              opacity: _tagOpacity,
              child: Center(child: _LoadingDots(controller: _dotsCtrl)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dot grid decoration ────────────────────────────────────────────────────────
class _DotGrid extends StatelessWidget {
  final Color color;
  final int rows;
  final int cols;
  const _DotGrid({required this.color, this.rows = 4, this.cols = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(cols, (_) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 5, height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          )),
        ),
      )),
    );
  }
}

// ── Animated 3-dot loading indicator ──────────────────────────────────────────
class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = (controller.value + i * 0.33) % 1.0;
            final scale = offset < 0.5 ? 0.6 + offset * 0.8 : 1.0 - (offset - 0.5) * 0.8;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale.clamp(0.6, 1.0),
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 1
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
