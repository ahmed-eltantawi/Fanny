import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/home/domain/entities/service_category_entity.dart';
import '../../../../features/requests/domain/repositories/requests_repository.dart';
import '../../../../features/requests/presentation/bloc/requests_cubit.dart';
import '../../../../features/requests/presentation/bloc/requests_state.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  int _step = 0;
  ServiceCategoryEntity? _selectedCategory;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final List<String> _photos = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onFormChanged);
    _descCtrl.addListener(_onFormChanged);
    _locationCtrl.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFormChanged);
    _descCtrl.removeListener(_onFormChanged);
    _locationCtrl.removeListener(_onFormChanged);
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  void _nextStep() => setState(() => _step++);
  void _prevStep() => setState(() => _step--);

  Future<void> _pickPhoto() async {
    final img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _photos.add(img.path));
  }

  void _submit() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated || _selectedCategory == null) return;
    final user = authState.user;

    context.read<RequestsCubit>().createRequest(CreateRequestParams(
          customerId: user.id,
          customerName: user.name,
          customerAvatar: user.avatarUrl ?? '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory!.id,
          categoryNameAr: _selectedCategory!.nameAr,
          categoryNameEn: _selectedCategory!.nameEn,
          location: _locationCtrl.text.trim(),
          photoUrls: [],
          budget: double.tryParse(_budgetCtrl.text),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocListener<RequestsCubit, RequestsState>(
      listener: (context, state) {
        if (state is RequestCreated) _showSuccess(context, l);
        if (state is RequestCreateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l.createRequest),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: AdaptiveBody(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 1024;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: desktop ? 980 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      _StepIndicator(
                          currentStep: _step,
                          totalSteps: 3,
                          labels: [
                            l.step1Category,
                            l.step2Details,
                            l.step3Location,
                          ]),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.2, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: anim, curve: Curves.easeOut)),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: [
                              _Step1Categories(
                                selected: _selectedCategory,
                                onSelect: (cat) {
                                  setState(() => _selectedCategory = cat);
                                  _nextStep();
                                },
                              ),
                              _Step2Details(
                                  titleCtrl: _titleCtrl,
                                  descCtrl: _descCtrl,
                                  photos: _photos,
                                  onPickPhoto: _pickPhoto),
                              _Step3Location(
                                  locationCtrl: _locationCtrl,
                                  budgetCtrl: _budgetCtrl),
                            ][_step],
                          ),
                        ),
                      ),
                      _BottomNav(
                        step: _step,
                        totalSteps: 3,
                        l: l,
                        onPrev: _prevStep,
                        onNext: _step == 2 ? null : _nextStep,
                        onSubmit: _submit,
                        canNext: _step == 0
                            ? _selectedCategory != null
                            : _step == 1
                                ? (_titleCtrl.text.isNotEmpty &&
                                    _descCtrl.text.isNotEmpty)
                                : _locationCtrl.text.isNotEmpty,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZoomIn(
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 72)),
            const SizedBox(height: AppSizes.md),
            Text(l.requestSent,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.xs),
            Text(l.requestSentDesc,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.lg),
            AppButton(
                label: l.confirm,
                onTap: () {
                  context.pop();
                  context.pop();
                }),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Category ──────────────────────────────────────────────────────────
class _Step1Categories extends StatelessWidget {
  final ServiceCategoryEntity? selected;
  final ValueChanged<ServiceCategoryEntity> onSelect;
  const _Step1Categories({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories;
    final isAr = Directionality.of(context) == TextDirection.rtl;

    final crossAxisCount =
        AdaptiveLayout.gridColumns(context, mobile: 2, tablet: 3, desktop: 4);
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSizes.sm,
        crossAxisSpacing: AppSizes.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        final isSelected = selected?.id == cat.id;
        final color = Color(cat.colorValue);
        return FadeInUp(
          delay: Duration(milliseconds: 50 * i),
          duration: const Duration(milliseconds: 400),
          child: GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(
                  color: isSelected ? color : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build,
                      color: isSelected ? Colors.white : color, size: 32),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    isAr ? cat.nameAr : cat.nameEn,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Step 2: Details ──────────────────────────────────────────────────────────
class _Step2Details extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final List<String> photos;
  final VoidCallback onPickPhoto;
  const _Step2Details(
      {required this.titleCtrl,
      required this.descCtrl,
      required this.photos,
      required this.onPickPhoto});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
              child: AppTextField(
            label: l.requestTitle,
            controller: titleCtrl,
            prefixIcon: Icons.title_rounded,
            onChanged: (_) {},
          )),
          const SizedBox(height: AppSizes.sm),
          FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: AppTextField(
                label: l.description,
                controller: descCtrl,
                maxLines: 5,
                prefixIcon: Icons.description_outlined,
                onChanged: (_) {},
              )),
          const SizedBox(height: AppSizes.md),
          FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(l.photos,
                  style: Theme.of(context).textTheme.titleSmall)),
          const SizedBox(height: AppSizes.sm),
          FadeInLeft(
            delay: const Duration(milliseconds: 250),
            child: GestureDetector(
              onTap: onPickPhoto,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                      color: AppColors.primary, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary, size: 28),
                    Text('إضافة',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Location & Budget ─────────────────────────────────────────────────
class _Step3Location extends StatelessWidget {
  final TextEditingController locationCtrl;
  final TextEditingController budgetCtrl;
  const _Step3Location({required this.locationCtrl, required this.budgetCtrl});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          FadeInDown(
              child: AppTextField(
            label: l.location,
            controller: locationCtrl,
            prefixIcon: Icons.location_on_outlined,
            onChanged: (_) {},
            hint: 'مثال: مدينة نصر، القاهرة',
          )),
          const SizedBox(height: AppSizes.sm),
          FadeInDown(
              delay: const Duration(milliseconds: 150),
              child: AppTextField(
                label: l.budget,
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money_rounded,
              )),
          const SizedBox(height: AppSizes.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      l.requestSentDesc,
                      style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 13,
                          fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;
  const _StepIndicator(
      {required this.currentStep,
      required this.totalSteps,
      required this.labels});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: Row(
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) {
              return const SizedBox(
                width: 40,
                child: Divider(height: 1, thickness: 1),
              );
            }
            final step = i ~/ 2;
            final isDone = step < currentStep;
            final isActive = step == currentStep;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success
                          : isActive
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: AppColors.primaryLight, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : Text('${step + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textHint,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              )),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(labels[step],
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Cairo',
                        color:
                            isActive ? AppColors.primary : AppColors.textHint,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                      )),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int step;
  final int totalSteps;
  final AppLocalizations l;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final VoidCallback onSubmit;
  final bool canNext;

  const _BottomNav({
    required this.step,
    required this.totalSteps,
    required this.l,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
    required this.canNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == totalSteps - 1;
    return BlocBuilder<RequestsCubit, RequestsState>(
      builder: (context, state) {
        final isLoading = state is RequestCreating;
        return Container(
          padding: EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md,
              AppSizes.md + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              if (step > 0)
                Expanded(
                  child: AppButton.outline(
                    label: l.prev,
                    onTap: onPrev,
                    icon: Icons.arrow_back_ios_rounded,
                  ),
                ),
              if (step > 0) const SizedBox(width: AppSizes.sm),
              Expanded(
                flex: 2,
                child: isLast
                    ? AppButton(
                        label: l.submitRequest,
                        onTap: canNext ? onSubmit : null,
                        isLoading: isLoading,
                        icon: Icons.send_rounded,
                      )
                    : AppButton(
                        label: l.next,
                        onTap: (canNext && onNext != null) ? onNext : null,
                        icon: Icons.arrow_forward_ios_rounded,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
