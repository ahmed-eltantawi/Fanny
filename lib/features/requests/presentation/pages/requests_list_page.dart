import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/requests/domain/entities/request_entity.dart';
import '../../../../features/requests/domain/repositories/requests_repository.dart';
import '../../../../features/requests/presentation/bloc/requests_cubit.dart';
import '../../../../features/requests/presentation/bloc/requests_state.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/status_badge.dart';

class RequestsListPage extends StatefulWidget {
  const RequestsListPage({super.key});

  @override
  State<RequestsListPage> createState() => _RequestsListPageState();
}

class _RequestsListPageState extends State<RequestsListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['all', 'pending', 'inProgress', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<RequestsCubit>().loadRequests(
            GetRequestsParams(userId: authState.user.id, role: authState.user.role.name),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.requests),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Cairo'),
          tabs: [
            Tab(text: l.all),
            Tab(text: l.pending),
            Tab(text: l.inProgress),
            Tab(text: l.completed),
          ],
        ),
      ),
      body: AdaptiveBody(
        child: BlocBuilder<RequestsCubit, RequestsState>(
          builder: (context, state) {
            if (state is RequestsLoading) return const ShimmerRequestList();
            if (state is RequestsError) return _ErrorView(message: state.message, onRetry: _load);
            if (state is RequestsLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _RequestList(requests: state.requests, l: l),
                  _RequestList(requests: state.requests.where((r) => r.status == RequestStatus.pending).toList(), l: l),
                  _RequestList(requests: state.requests.where((r) => r.status == RequestStatus.inProgress).toList(), l: l),
                  _RequestList(requests: state.requests.where((r) => r.status == RequestStatus.completed).toList(), l: l),
                ],
              );
            }
            return const ShimmerRequestList();
          },
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<RequestEntity> requests;
  final AppLocalizations l;
  const _RequestList({required this.requests, required this.l});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.list_alt_rounded, size: 64, color: AppColors.divider),
              const SizedBox(height: AppSizes.sm),
              Text(l.noData, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          context.read<RequestsCubit>().loadRequests(
                GetRequestsParams(userId: authState.user.id, role: authState.user.role.name),
              );
        }
      },
      color: AppColors.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1000;
          if (!desktop) {
            return ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: requests.length,
              itemBuilder: (context, i) => FadeInUp(
                delay: Duration(milliseconds: 60 * i),
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: _RequestCard(request: requests[i], l: l),
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizes.sm,
              crossAxisSpacing: AppSizes.sm,
              childAspectRatio: 1.8,
            ),
            itemCount: requests.length,
            itemBuilder: (context, i) => FadeInUp(
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 400),
              child: _RequestCard(request: requests[i], l: l),
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestEntity request;
  final AppLocalizations l;
  const _RequestCard({required this.request, required this.l});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () {
        if (request.offersCount > 0) {
          context.push('/offers', extra: request);
        }
      },
      child: Container(
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
            Row(
              children: [
                Expanded(
                  child: Text(request.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                StatusBadge(status: request.status, small: true),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(request.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(child: Text(request.location,
                    style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: AppSizes.xs),
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(_formatDate(request.createdAt, isAr), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            if (request.offersCount > 0) ...[
              const Divider(height: AppSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('${request.offersCount} ${l.offersCount}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Cairo')),
                    ],
                  ),
                  Text(l.viewOffers,
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt, bool isAr) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return isAr ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return isAr ? 'منذ ${diff.inHours} س'  : '${diff.inHours}h ago';
    return isAr ? 'منذ ${diff.inDays} أيام' : '${diff.inDays}d ago';
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: AppSizes.sm),
          Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.md),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).retry)),
        ],
      ),
    );
  }
}
