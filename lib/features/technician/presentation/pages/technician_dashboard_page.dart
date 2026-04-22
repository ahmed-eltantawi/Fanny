import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/offers/domain/repositories/offers_repository.dart';
import '../../../../features/offers/presentation/bloc/offers_cubit.dart';
import '../../../../features/offers/presentation/bloc/offers_state.dart';
import '../../../../features/requests/domain/entities/request_entity.dart';
import '../../../../features/requests/domain/repositories/requests_repository.dart';
import '../../../../features/requests/presentation/bloc/requests_cubit.dart';
import '../../../../features/requests/presentation/bloc/requests_state.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/star_rating.dart';
import '../../../../shared/widgets/status_badge.dart';

class TechnicianDashboardPage extends StatefulWidget {
  const TechnicianDashboardPage({super.key});

  @override
  State<TechnicianDashboardPage> createState() => _TechnicianDashboardPageState();
}

class _TechnicianDashboardPageState extends State<TechnicianDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _load() {
    context.read<RequestsCubit>().loadRequests(const GetRequestsParams(role: 'technician'));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _TechnicianHeader(user: user),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.accent,
              labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [Tab(text: l.availableRequests), Tab(text: l.myActiveJobs)],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _AvailableRequestsTab(user: user),
            _MyJobsTab(user: user),
          ],
        ),
      ),
    );
  }
}

class _TechnicianHeader extends StatelessWidget {
  final UserEntity? user;
  const _TechnicianHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final jobs = user != null ? MockData.getOffersForTechnician(user!.id) : [];
    final completed = jobs.where((o) => o.isAccepted).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user?.avatarUrl != null ? CachedNetworkImageProvider(user!.avatarUrl!) : null,
                      backgroundColor: AppColors.primaryLight,
                      child: user?.avatarUrl == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l.hello}${user?.name ?? ''}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
                          Text(user?.specialty ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                    if (user?.rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: StarRating(rating: user!.rating!, size: 14),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              FadeInUp(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    _StatPill(label: l.totalJobs, value: '${jobs.length}'),
                    const SizedBox(width: AppSizes.sm),
                    _StatPill(label: l.completedJobs, value: '$completed'),
                    const SizedBox(width: AppSizes.sm),
                    _StatPill(label: l.earnings, value: '${(completed * 350).toStringAsFixed(0)} ج.م'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Cairo')),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}

class _AvailableRequestsTab extends StatelessWidget {
  final UserEntity? user;
  const _AvailableRequestsTab({this.user});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<RequestsCubit, RequestsState>(
      builder: (context, state) {
        if (state is RequestsLoading) return const ShimmerRequestList();
        if (state is RequestsError) return Center(child: Text(state.message));
        if (state is RequestsLoaded) {
          final requests = state.requests;
          if (requests.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.inbox_rounded, size: 64, color: AppColors.divider),
              const SizedBox(height: AppSizes.sm),
              Text(l.noData, style: Theme.of(context).textTheme.titleSmall),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: requests.length,
            itemBuilder: (context, i) => FadeInUp(
              delay: Duration(milliseconds: 60 * i), duration: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: _AvailableRequestCard(request: requests[i], l: l, technicianUser: user),
              ),
            ),
          );
        }
        return const ShimmerRequestList();
      },
    );
  }
}

class _AvailableRequestCard extends StatelessWidget {
  final RequestEntity request;
  final AppLocalizations l;
  final UserEntity? technicianUser;
  const _AvailableRequestCard({required this.request, required this.l, this.technicianUser});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;

    return Container(
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
              StatusBadge(status: request.status, small: true),
              const Spacer(),
              if (request.budget != null)
                Text('الميزانية: ${request.budget!.toInt()} ج.م',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Cairo')),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(request.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSizes.xs),
          Text(request.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(request.location, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(isAr ? request.categoryNameAr : request.categoryNameEn,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Cairo')),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            label: l.submitOffer,
            icon: Icons.local_offer_outlined,
            onTap: () => _showOfferSheet(context, request),
          ),
        ],
      ),
    );
  }

  void _showOfferSheet(BuildContext context, RequestEntity request) {
    final l = AppLocalizations.of(context);
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<OffersCubit>(),
        child: Container(
          padding: EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg,
              AppSizes.lg + MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
          ),
          child: BlocListener<OffersCubit, OffersState>(
            listener: (context, state) {
              if (state is OfferSubmitted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.offerSent), backgroundColor: AppColors.success),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.submitOffer, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSizes.md),
                AppTextField(label: l.yourPrice, controller: priceCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money_rounded),
                const SizedBox(height: AppSizes.sm),
                AppTextField(label: l.estimatedDuration, controller: durationCtrl, prefixIcon: Icons.access_time_rounded, hint: '3 ساعات'),
                const SizedBox(height: AppSizes.sm),
                AppTextField(label: l.additionalNotes, controller: noteCtrl, maxLines: 3, prefixIcon: Icons.notes_rounded),
                const SizedBox(height: AppSizes.md),
                BlocBuilder<OffersCubit, OffersState>(
                  builder: (_, state) => AppButton(
                    label: l.sendOffer, icon: Icons.send_rounded,
                    isLoading: state is OfferSubmitting,
                    onTap: technicianUser == null ? null : () {
                      context.read<OffersCubit>().submitOffer(SubmitOfferParams(
                        requestId: request.id,
                        technicianId: technicianUser!.id,
                        technicianName: technicianUser!.name,
                        technicianAvatarUrl: technicianUser!.avatarUrl,
                        technicianRating: technicianUser!.rating ?? 4.5,
                        technicianCompletedJobs: technicianUser!.completedJobs ?? 0,
                        technicianSpecialty: technicianUser!.specialty ?? '',
                        price: double.tryParse(priceCtrl.text) ?? 0,
                        estimatedDuration: durationCtrl.text.isNotEmpty ? durationCtrl.text : '2 ساعات',
                        note: noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyJobsTab extends StatelessWidget {
  final UserEntity? user;
  const _MyJobsTab({this.user});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (user == null) return const SizedBox.shrink();
    final myJobs = MockData.getRequestsForTechnician(user!.id);

    if (myJobs.isEmpty) {
      return Center(child: FadeIn(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.work_outline_rounded, size: 64, color: AppColors.divider),
        const SizedBox(height: AppSizes.sm),
        Text(l.noData, style: Theme.of(context).textTheme.titleSmall),
      ])));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: myJobs.length,
      itemBuilder: (context, i) => FadeInUp(
        delay: Duration(milliseconds: 60 * i), duration: const Duration(milliseconds: 400),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(myJobs[i].title, style: Theme.of(context).textTheme.titleSmall)),
                StatusBadge(status: myJobs[i].status, small: true),
              ]),
              const SizedBox(height: AppSizes.xs),
              Text(myJobs[i].location, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ),
      ),
    );
  }
}

