/// Centralized asset path constants.
/// Usage: Image.asset(AppImages.logo)
abstract class AppImages {
  AppImages._();

  static const String _base = 'assets/images';

  // ── Logo ──────────────────────────────────────────────────────────────────
  static const String logo = '$_base/logo-removebg-preview.png';

  // ── Illustrations ─────────────────────────────────────────────────────────
  static const String splashBg   = '$_base/illustrations/splash_bg.png';
  static const String heroTech   = '$_base/illustrations/hero_tech.png';

  // ── SVG Onboarding illustrations ──────────────────────────────────────────
  static const String onboarding1 = '$_base/fanny_1.svg';
  static const String onboarding2 = '$_base/fanny_2.svg';
  static const String onboarding3 = '$_base/fanny_3.svg';

  // ── User avatars (SVG) ────────────────────────────────────────────────────
  static const String user1 = '$_base/user_1.svg';
  static const String user2 = '$_base/user_2.svg';

  // ── Category icon sprite ──────────────────────────────────────────────────
  static const String categoryIcons = '$_base/icons/category_icons.png';

  // ── Social login icons ────────────────────────────────────────────────────
  static const String googleIcon   = '$_base/icons/google_icon.png';
  static const String facebookIcon = '$_base/icons/facebook_icon.png';

  // ── Request illustration ──────────────────────────────────────────────────
  static const String requestImage = '$_base/requst_1.png';
}
