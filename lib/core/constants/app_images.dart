/// Centralized asset path constants.
/// Usage: Image.asset(AppImages.logo)
abstract class AppImages {
  AppImages._();

  static const String _base = 'assets/images';

  static const String logo = '$_base/logo-removebg-preview.png';
  static const String googleIcon = '$_base/icons/google_icon.png';
  static const String facebookIcon = '$_base/icons/facebook_icon.png';
}
