import 'package:equatable/equatable.dart';

enum RequestStatus { pending, inProgress, completed, cancelled }

/// Pure Dart domain entity for a Service Request.
class RequestEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String customerAvatar;
  final String title;
  final String description;
  final String category;       // e.g. 'plumbing'
  final String categoryNameAr; // Display name in Arabic
  final String categoryNameEn; // Display name in English
  final String location;
  final RequestStatus status;
  final DateTime createdAt;
  final List<String> photoUrls;
  final double? budget;
  final int offersCount;
  final String? assignedTechnicianId;
  final String? assignedTechnicianName;

  const RequestEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAvatar,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.photoUrls,
    this.budget,
    required this.offersCount,
    this.assignedTechnicianId,
    this.assignedTechnicianName,
  });

  RequestEntity copyWith({
    String? id, String? customerId, String? customerName, String? customerAvatar,
    String? title, String? description, String? category, String? categoryNameAr,
    String? categoryNameEn, String? location, RequestStatus? status,
    DateTime? createdAt, List<String>? photoUrls, double? budget,
    int? offersCount, String? assignedTechnicianId, String? assignedTechnicianName,
  }) => RequestEntity(
    id: id ?? this.id, customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    customerAvatar: customerAvatar ?? this.customerAvatar,
    title: title ?? this.title, description: description ?? this.description,
    category: category ?? this.category, categoryNameAr: categoryNameAr ?? this.categoryNameAr,
    categoryNameEn: categoryNameEn ?? this.categoryNameEn,
    location: location ?? this.location, status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt, photoUrls: photoUrls ?? this.photoUrls,
    budget: budget ?? this.budget, offersCount: offersCount ?? this.offersCount,
    assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
    assignedTechnicianName: assignedTechnicianName ?? this.assignedTechnicianName,
  );

  @override
  List<Object?> get props => [id, customerId, title, category, status, createdAt, offersCount];
}
