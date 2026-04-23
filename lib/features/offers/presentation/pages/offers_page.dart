import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../../../features/offers/domain/entities/offer_entity.dart';
import '../../../../features/offers/presentation/bloc/offers_cubit.dart';
import '../../../../features/offers/presentation/bloc/offers_state.dart';
import '../../../../features/requests/domain/entities/request_entity.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/network_avatar.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/star_rating.dart';

class OffersPage extends StatefulWidget {
  final RequestEntity request;
  const OffersPage({super.key, required this.request});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  @override
  void initState() {
    super.initState();
    context.read<OffersCubit>().loadOffers(widget.request.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text('${l.offersFor} ${widget.request.title}',
              maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: AdaptiveBody(
        child: Column(
          children: [
            _RequestSummary(request: widget.request),
            Expanded(
              child: BlocConsumer<OffersCubit, OffersState>(
                listener: (context, state) {
                  if (state is OfferAccepted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l.accepted),
                          backgroundColor: AppColors.success),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is OffersLoading || state is OfferAccepting) {
                    return const ShimmerRequestList(count: 3);
                  }
                  if (state is OffersError) {
                    return Center(child: Text(state.message));
                  }
                  List<OfferEntity> offers = [];
                  if (state is OffersLoaded) offers = state.offers;
                  if (state is OfferAccepted || state is OfferSubmitted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<OffersCubit>().loadOffers(widget.request.id);
                    });
                  }
                  if (offers.isEmpty) return _EmptyOffers(l: l);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final desktop = constraints.maxWidth >= 1100;
                      if (!desktop) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.md),
                          itemCount: offers.length,
                          itemBuilder: (context, i) => FadeInUp(
                            delay: Duration(milliseconds: 80 * i),
                            duration: const Duration(milliseconds: 400),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSizes.sm),
                              child: _OfferCard(
                                offer: offers[i],
                                l: l,
                                onAccept: () => context
                                    .read<OffersCubit>()
                                    .acceptOffer(offers[i].id),
                                requestStatus: widget.request.status,
                              ),
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(AppSizes.md),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.sm,
                          mainAxisSpacing: AppSizes.sm,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: offers.length,
                        itemBuilder: (context, i) => FadeInUp(
                          delay: Duration(milliseconds: 80 * i),
                          duration: const Duration(milliseconds: 400),
                          child: _OfferCard(
                            offer: offers[i],
                            l: l,
                            onAccept: () => context
                                .read<OffersCubit>()
                                .acceptOffer(offers[i].id),
                            requestStatus: widget.request.status,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestSummary extends StatelessWidget {
  final RequestEntity request;
  const _RequestSummary({required this.request});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: const Icon(Icons.build_circle_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Cairo'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(isAr ? request.categoryNameAr : request.categoryNameEn,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Cairo')),
              ],
            ),
          ),
          if (request.budget != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
              child: Text('${request.budget!.toInt()} ج.م',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Cairo')),
            ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferEntity offer;
  final AppLocalizations l;
  final VoidCallback onAccept;
  final RequestStatus requestStatus;

  const _OfferCard({
    required this.offer,
    required this.l,
    required this.onAccept,
    required this.requestStatus,
  });

  @override
  Widget build(BuildContext context) {
    final canAccept =
        requestStatus == RequestStatus.pending && !offer.isAccepted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: offer.isAccepted ? AppColors.successSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: offer.isAccepted ? AppColors.success : AppColors.cardBorder,
          width: offer.isAccepted ? 2 : 1,
        ),
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
              NetworkAvatar(
                radius: 24,
                imageUrl: offer.technicianAvatarUrl,
                backgroundColor: AppColors.primarySurface,
                iconColor: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.technicianName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(offer.technicianSpecialty,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (offer.isAccepted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(l.accepted,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo')),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          StarRating(rating: offer.technicianRating, size: 15),
          Text('${offer.technicianCompletedJobs} ${l.completedJobs}',
              style: Theme.of(context).textTheme.bodySmall),
          const Divider(height: AppSizes.md),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.attach_money_rounded,
                  label: '${offer.price.toInt()} ${l.egp}',
                  color: AppColors.success),
              const SizedBox(width: AppSizes.sm),
              _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: offer.estimatedDuration,
                  color: AppColors.info),
            ],
          ),
          if (offer.note != null && offer.note!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_rounded,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(offer.note!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
          if (canAccept) ...[
            const SizedBox(height: AppSizes.sm),
            AppButton(
              label: l.accept,
              onTap: onAccept,
              icon: Icons.check_circle_outline_rounded,
              style: AppButtonStyle.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyOffers({required this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty_rounded,
                size: 72, color: AppColors.divider),
            const SizedBox(height: AppSizes.md),
            Text(l.noOffers, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSizes.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
              child: Text(l.noOffersDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
