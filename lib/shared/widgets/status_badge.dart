import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/requests/domain/entities/request_entity.dart';

/// Animated pill-shaped status badge for request status.
class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final label = _label(isAr);
    final bg = _bgColor;
    final fg = _fgColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _label(bool isAr) => switch (status) {
    RequestStatus.pending    => isAr ? 'قيد الانتظار' : 'Pending',
    RequestStatus.inProgress => isAr ? 'جاري التنفيذ' : 'In Progress',
    RequestStatus.completed  => isAr ? 'مكتمل'        : 'Completed',
    RequestStatus.cancelled  => isAr ? 'ملغي'         : 'Cancelled',
  };

  Color get _bgColor => switch (status) {
    RequestStatus.pending    => AppColors.statusPendingSurface,
    RequestStatus.inProgress => AppColors.statusInProgressSurface,
    RequestStatus.completed  => AppColors.statusCompletedSurface,
    RequestStatus.cancelled  => AppColors.statusCancelledSurface,
  };

  Color get _fgColor => switch (status) {
    RequestStatus.pending    => AppColors.statusPending,
    RequestStatus.inProgress => AppColors.statusInProgress,
    RequestStatus.completed  => AppColors.statusCompleted,
    RequestStatus.cancelled  => AppColors.statusCancelled,
  };
}
