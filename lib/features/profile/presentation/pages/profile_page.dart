import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(user: user),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSizes.md),
                _SettingsSection(l: l),
                const SizedBox(height: AppSizes.md),
                _LogoutSection(l: l),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserEntity? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.md),
            FadeInDown(duration: const Duration(milliseconds: 600),
              child: Hero(
                tag: 'user_avatar',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: user?.avatarUrl != null ? CachedNetworkImageProvider(user!.avatarUrl!) : null,
                    backgroundColor: AppColors.primaryLight,
                    child: user?.avatarUrl == null
                        ? const Icon(Icons.person_rounded, color: Colors.white, size: 44)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            FadeInUp(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500),
              child: Text(user?.name ?? '---',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Cairo'))),
            FadeInUp(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500),
              child: Text(user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo'))),
            const SizedBox(height: AppSizes.xs),
            FadeInUp(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  _roleLabel(user?.role, l),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(UserRole? role, AppLocalizations l) {
    switch (role) {
      case UserRole.customer:   return l.customer;
      case UserRole.technician: return l.technician;
      case UserRole.admin:      return l.admin;
      default:                  return '---';
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final AppLocalizations l;
  const _SettingsSection({required this.l});

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.watch<LocaleCubit>();
    final isAr = localeCubit.isArabic;

    final items = [
      _SettingItem(
        icon: Icons.language_rounded,
        label: l.language,
        trailing: Switch.adaptive(
          value: isAr,
          activeThumbColor: AppColors.primary,
          onChanged: (_) => context.read<LocaleCubit>().toggleLocale(),
        ),
        onTap: () => context.read<LocaleCubit>().toggleLocale(),
      ),
      _SettingItem(
        icon: Icons.notifications_outlined,
        label: l.notifications,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        onTap: () {},
      ),
      _SettingItem(
        icon: Icons.help_outline_rounded,
        label: l.help,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        onTap: () {},
      ),
      _SettingItem(
        icon: Icons.info_outline_rounded,
        label: l.about,
        trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textHint, fontFamily: 'Cairo')),
        onTap: () {},
      ),
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast) const Divider(indent: AppSizes.md + 40, height: 0),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon, required this.label,
    required this.trailing, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  final AppLocalizations l;
  const _LogoutSection({required this.l});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: AppButton.outline(
          label: l.logout,
          icon: Icons.logout_rounded,
          onTap: () async {
            await context.read<AuthCubit>().logout();
            if (context.mounted) context.go('/login');
          },
        ),
      ),
    );
  }
}

