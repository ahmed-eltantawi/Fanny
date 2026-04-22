import 'package:equatable/equatable.dart';

/// Domain entity for a Service Category.
/// Uses plain Dart (no Flutter) — icon/color resolved in presentation layer.
class ServiceCategoryEntity extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final String iconName; // maps to an icon constant in presentation
  final int colorValue;  // ARGB int, converted with Color(colorValue) in UI

  const ServiceCategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.iconName,
    required this.colorValue,
  });

  @override
  List<Object> get props => [id, nameEn, nameAr, iconName, colorValue];
}
