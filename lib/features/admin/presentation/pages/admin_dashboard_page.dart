import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../features/requests/domain/entities/request_entity.dart';
import '../../../../features/requests/domain/repositories/requests_repository.dart';
import '../../../../features/requests/presentation/bloc/requests_cubit.dart';
import '../../../../features/requests/presentation/bloc/requests_state.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/status_badge.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<RequestsCubit>().loadRequests(const GetRequestsParams(role: 'admin'));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(l.adminDashboard,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Cairo')),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.md),
                _StatsRow(l: l),
                const SizedBox(height: AppSizes.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Text(l.recentActivity,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: AppSizes.sm),
              ],
            ),
          ),
          BlocBuilder<RequestsCubit, RequestsState>(
            builder: (context, state) {
              if (state is RequestsLoaded) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeInUp(
                      delay: Duration(milliseconds: 60 * i), duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
                        child: _AdminRequestTile(request: state.requests[i]),
                      ),
                    ),
                    childCount: state.requests.length,
                  ),
                );
              }
              return SliverToBoxAdapter(child: Container());
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: AppSizes.xl)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppLocalizations l;
  const _StatsRow({required this.l});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: l.totalUsers,       value: MockData.totalUsersCount,        color: AppColors.info,    icon: Icons.people_rounded),
      (label: l.totalTechnicians, value: MockData.totalTechniciansCount,   color: AppColors.accent,  icon: Icons.engineering_rounded),
      (label: l.totalRequests,    value: MockData.totalRequestsCount,      color: AppColors.primary, icon: Icons.list_alt_rounded),
      (label: l.revenueThisMonth, value: MockData.totalRevenue.toInt(),    color: AppColors.success, icon: Icons.monetization_on_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final i = entry.key;
          final stat = entry.value;
          return FadeInRight(
            delay: Duration(milliseconds: 100 * i), duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: _AdminStatCard(label: stat.label, value: '${stat.value}', color: stat.color, icon: stat.icon),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AdminStatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _AdminStatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  State<_AdminStatCard> createState() => _AdminStatCardState();
}

class _AdminStatCardState extends State<_AdminStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _countAnim = Tween<double>(begin: 0, end: double.tryParse(widget.value) ?? 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, height: AppSizes.statsCardHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _countAnim,
            builder: (_, __) => Text(
              '${_countAnim.value.toInt()}',
              style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900, color: widget.color, fontFamily: 'Cairo',
              ),
            ),
          ),
          Text(widget.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

class _AdminRequestTile extends StatelessWidget {
  final RequestEntity request;
  const _AdminRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(request.customerName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: request.status, small: true),
              const SizedBox(height: 4),
              Text(isAr ? request.categoryNameAr : request.categoryNameEn,
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }
}

