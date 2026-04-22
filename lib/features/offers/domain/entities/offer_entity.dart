import 'package:equatable/equatable.dart';

/// Pure Dart domain entity for a Technician's Offer on a Request.
class OfferEntity extends Equatable {
  final String id;
  final String requestId;
  final String technicianId;
  final String technicianName;
  final String? technicianAvatarUrl;
  final double technicianRating;
  final int technicianCompletedJobs;
  final String technicianSpecialty;
  final double price;
  final String estimatedDuration; // e.g. '2 hrs'
  final String? note;
  final bool isAccepted;
  final DateTime createdAt;

  const OfferEntity({
    required this.id,
    required this.requestId,
    required this.technicianId,
    required this.technicianName,
    this.technicianAvatarUrl,
    required this.technicianRating,
    required this.technicianCompletedJobs,
    required this.technicianSpecialty,
    required this.price,
    required this.estimatedDuration,
    this.note,
    required this.isAccepted,
    required this.createdAt,
  });

  OfferEntity copyWith({bool? isAccepted}) => OfferEntity(
    id: id, requestId: requestId, technicianId: technicianId,
    technicianName: technicianName, technicianAvatarUrl: technicianAvatarUrl,
    technicianRating: technicianRating, technicianCompletedJobs: technicianCompletedJobs,
    technicianSpecialty: technicianSpecialty, price: price,
    estimatedDuration: estimatedDuration, note: note,
    isAccepted: isAccepted ?? this.isAccepted, createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, requestId, technicianId, price, isAccepted];
}
