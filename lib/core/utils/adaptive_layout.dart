import 'package:flutter/material.dart';

class AdaptiveLayout {
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1440;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 700;

  static double contentMaxWidth(BuildContext context) {
    if (isLargeDesktop(context)) return 1360;
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 900;
    return double.infinity;
  }

  static int gridColumns(BuildContext context,
      {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

class AdaptiveBody extends StatelessWidget {
  const AdaptiveBody({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: AdaptiveLayout.contentMaxWidth(context)),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
