import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/home/domain/entities/service_category_entity.dart';
import '../../../../features/requests/domain/entities/request_entity.dart';
import '../../../../shared/data/firestore_app_data_service.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/network_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, l, user),
          SliverToBoxAdapter(
            child: AdaptiveBody(
              child: _loading
                  ? const _HomeShimmer()
                  : _HomeContent(user: user, l: l),
            ),
          ),
        ],
      ),
      floatingActionButton: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/create-request'),
          icon: const Icon(Icons.add_rounded),
          label: Text(l.createRequest,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, AppLocalizations l, UserEntity? user) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg, vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l.hello}${user?.name ?? ''}  👋',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                l.whatDoYouNeed,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Hero(
                          tag: 'home_user_avatar',
                          child: NetworkAvatar(
                            radius: 24,
                            imageUrl: user?.avatarUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: AppSizes.sm),
                          Text(l.searchHint,
                              style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final UserEntity? user;
  final AppLocalizations l;
  const _HomeContent({this.user, required this.l});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<RequestEntity>, List<UserEntity>)>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _HomeShimmer();
        }
        final requests = snapshot.data?.$1 ?? const <RequestEntity>[];
        final technicians = snapshot.data?.$2 ?? const <UserEntity>[];
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            if (!isDesktop) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: _WalletSummaryCard(l: l),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionHeader(
                      title: l.categories, actionLabel: l.seeAll, onTap: () {}),
                  const SizedBox(height: AppSizes.sm),
                  _CategoryGrid(categories: MockData.categories),
                  const SizedBox(height: AppSizes.md),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child:
                          _TopTechniciansCard(technicians: technicians, l: l),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionHeader(
                      title: l.recentRequests,
                      actionLabel: l.seeAll,
                      onTap: () {}),
                  const SizedBox(height: AppSizes.sm),
                  if (requests.isEmpty)
                    _EmptyRequests(l: l)
                  else
                    ...List.generate(
                      requests.length,
                      (i) => FadeInUp(
                        delay: Duration(milliseconds: 100 * i),
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md, vertical: AppSizes.xs),
                          child: _HomeRequestCard(request: requests[i]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: _WalletSummaryCard(l: l),
                        ),
                        const SizedBox(height: AppSizes.md),
                        _SectionHeader(
                            title: l.categories,
                            actionLabel: l.seeAll,
                            onTap: () {}),
                        const SizedBox(height: AppSizes.sm),
                        _CategoryGrid(categories: MockData.categories),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 100),
                          child: _TopTechniciansCard(
                              technicians: technicians, l: l),
                        ),
                        const SizedBox(height: AppSizes.md),
                        _SectionHeader(
                            title: l.recentRequests,
                            actionLabel: l.seeAll,
                            onTap: () {}),
                        const SizedBox(height: AppSizes.sm),
                        if (requests.isEmpty)
                          _EmptyRequests(l: l)
                        else
                          ...List.generate(
                            requests.length,
                            (i) => FadeInUp(
                              delay: Duration(milliseconds: 100 * i),
                              duration: const Duration(milliseconds: 500),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.xs),
                                child: _HomeRequestCard(request: requests[i]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<(List<RequestEntity>, List<UserEntity>)> _loadData() async {
    final service = sl<FirestoreAppDataService>();
    final recent = user == null
        ? const <RequestEntity>[]
        : await service.getCustomerRecentRequests(user!.id);
    final topTechs = await service.getTopTechnicians();
    return (recent, topTechs);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onTap;
  const _SectionHeader(
      {required this.title, required this.actionLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<ServiceCategoryEntity> categories;
  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AdaptiveLayout.isDesktop(context);
    if (!isDesktop) {
      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories[i];
            final color = Color(cat.colorValue);
            return FadeInLeft(
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.only(right: AppSizes.sm),
                child: _CategoryChip(category: cat, color: color),
              ),
            );
          },
        ),
      );
    }

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        ...categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final color = Color(cat.colorValue);
          return FadeInLeft(
            delay: Duration(milliseconds: 60 * i),
            duration: const Duration(milliseconds: 400),
            child: _CategoryChip(category: cat, color: color),
          );
        }),
      ],
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final ServiceCategoryEntity category;
  final Color color;
  const _CategoryChip({required this.category, required this.color});

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _pressed = false;

  static const _iconMap = <String, IconData>{
    'plumbing': Icons.plumbing,
    'electrical_services': Icons.electrical_services,
    'carpenter': Icons.carpenter,
    'format_paint': Icons.format_paint,
    'ac_unit': Icons.ac_unit,
    'cleaning_services': Icons.cleaning_services,
    'build': Icons.build,
    'home_repair_service': Icons.home_repair_service,
  };

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final name = isAr ? widget.category.nameAr : widget.category.nameEn;
    final icon = _iconMap[widget.category.iconName] ?? Icons.build;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: widget.color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: widget.color, size: 30),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                name,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeRequestCard extends StatelessWidget {
  final RequestEntity request;
  const _HomeRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Color(MockData.categories
                          .firstWhere((c) => c.id == request.category,
                              orElse: () => MockData.categories.first)
                          .colorValue)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: const Icon(Icons.build_circle_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(isAr ? request.categoryNameAr : request.categoryNameEn,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(status: request.status, small: true),
            ],
          ),
          if (request.offersCount > 0) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              '${request.offersCount} ${l.offersCount}',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyRequests({required this.l});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg, vertical: AppSizes.xl),
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, size: 72, color: AppColors.divider),
            const SizedBox(height: AppSizes.md),
            Text(l.noRequestsYet,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSizes.xs),
            Text(l.createFirstRequest,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.md),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: ShimmerCategoryGrid(),
        ),
        const SizedBox(height: AppSizes.md),
        SizedBox(height: 300, child: ShimmerRequestList(count: 3)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Wallet Summary Card (dark gradient card – image 1)
// ══════════════════════════════════════════════════════════════════════════════
class _WalletSummaryCard extends StatelessWidget {
  final AppLocalizations l;
  const _WalletSummaryCard({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              const Text(
                'إجمالي المحفظة',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Amount ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '٤,٨٥٠',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'ج.م',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Action buttons ──
          Row(
            children: [
              // Withdraw button (green)
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'سحب الأرباح',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Details button (dark)
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Center(
                      child: Text(
                        'التفاصيل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Top Technicians Card (dark list card – image 2)
// ══════════════════════════════════════════════════════════════════════════════
class _TopTechniciansCard extends StatelessWidget {
  final List<UserEntity> technicians;
  final AppLocalizations l;
  const _TopTechniciansCard({required this.technicians, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1A2540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'أشطر الصنايعية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
              const Icon(Icons.emoji_events_outlined,
                  color: Color(0xFFFFA000), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          // ── Technician rows ──
          ...List.generate(technicians.length, (i) {
            final tech = technicians[i];
            final rank = i + 1;
            return FadeInRight(
              delay: Duration(milliseconds: 80 * i),
              duration: const Duration(milliseconds: 450),
              child: _TechnicianRow(
                tech: tech,
                rank: rank,
              ),
            );
          }),
          const SizedBox(height: 14),
          // ── View All button ──
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35)),
              ),
              child: const Center(
                child: Text(
                  'عرض كل الفنيين',
                  style: TextStyle(
                    color: Color(0xFFB2F5D8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianRow extends StatelessWidget {
  final UserEntity tech;
  final int rank;
  const _TechnicianRow({required this.tech, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final specialty = tech.specialty ?? '';
    final specLabel = _specialtyLabel(specialty, isAr);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Avatar
          NetworkAvatar(
            radius: 26,
            imageUrl: tech.avatarUrl,
            backgroundColor: AppColors.primaryDark.withValues(alpha: 0.3),
            iconColor: Colors.white54,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      specLabel,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFA000), size: 13),
                    const SizedBox(width: 2),
                    Text(
                      tech.rating?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _specialtyLabel(String specialty, bool isAr) {
    const map = {
      'plumbing': ('سباكة', 'Plumbing'),
      'electrical': ('كهرباء', 'Electrical'),
      'carpentry': ('نجارة', 'Carpentry'),
      'painting': ('دهانات', 'Painting'),
      'ac_repair': ('تكييف', 'AC Repair'),
      'cleaning': ('تنظيف', 'Cleaning'),
    };
    final entry = map[specialty];
    if (entry == null) return specialty;
    return isAr ? entry.$1 : entry.$2;
  }
}
