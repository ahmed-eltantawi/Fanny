import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/requests/presentation/pages/requests_list_page.dart';
import '../../features/technician/presentation/pages/technician_dashboard_page.dart';
import '../widgets/animated_bottom_nav.dart';

/// Role-aware main scaffold with animated bottom nav and IndexedStack pages.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  List<Widget> _pages(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const [HomePage(), RequestsListPage(), ProfilePage()];
      case UserRole.technician:
        return const [TechnicianDashboardPage(), RequestsListPage(), ProfilePage()];
      case UserRole.admin:
        return const [AdminDashboardPage(), RequestsListPage(), ProfilePage()];
    }
  }

  List<BottomNavItem> _navItems(AppLocalizations l, UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          BottomNavItem(label: l.home,     icon: Icons.home_outlined,         activeIcon: Icons.home_rounded),
          BottomNavItem(label: l.requests, icon: Icons.list_alt_outlined,      activeIcon: Icons.list_alt_rounded),
          BottomNavItem(label: l.profile,  icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
        ];
      case UserRole.technician:
        return [
          BottomNavItem(label: l.dashboard,      icon: Icons.dashboard_outlined,      activeIcon: Icons.dashboard_rounded),
          BottomNavItem(label: l.availableJobs,  icon: Icons.work_outline_rounded,    activeIcon: Icons.work_rounded),
          BottomNavItem(label: l.profile,        icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded),
        ];
      case UserRole.admin:
        return [
          BottomNavItem(label: l.dashboard, icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings_rounded),
          BottomNavItem(label: l.users,     icon: Icons.list_alt_outlined,             activeIcon: Icons.list_alt_rounded),
          BottomNavItem(label: l.profile,   icon: Icons.person_outline_rounded,        activeIcon: Icons.person_rounded),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;

    // Default to customer if somehow state is unexpected
    final role = authState is AuthAuthenticated ? authState.user.role : UserRole.customer;
    final pages = _pages(role);
    final navItems = _navItems(l, role);

    // Clamp index in case role change caused item count mismatch
    final safeIndex = _index.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: AnimatedBottomNav(
        items: navItems,
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
