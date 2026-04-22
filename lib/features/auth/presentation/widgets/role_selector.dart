import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Reusable role selector used on both Login and Register pages.
class RoleSelector extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const RoleSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final List<(UserRole, String, IconData)> roles = [
      (UserRole.customer,   l.customer,   Icons.person_rounded),
      (UserRole.technician, l.technician, Icons.engineering_rounded),
      (UserRole.admin,      l.admin,      Icons.admin_panel_settings_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.selectRole,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: roles.map((item) {
            final (role, label, icon) = item;
            final isSelected = selected == role;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () => onChanged(role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: isSelected ? null : Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 22,
                            color: isSelected ? Colors.white : AppColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
