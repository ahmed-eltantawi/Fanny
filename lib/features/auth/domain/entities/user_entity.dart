import 'package:equatable/equatable.dart';

enum UserRole { customer, technician, admin }

/// Pure Dart domain entity for a User.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final String? specialty; // Technicians only
  final double? rating;     // Technicians only
  final int? completedJobs; // Technicians only
  final String? bio;        // Technicians only

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.specialty,
    this.rating,
    this.completedJobs,
    this.bio,
  });

  UserEntity copyWith({
    String? id, String? name, String? email, String? phone,
    UserRole? role, String? avatarUrl, String? specialty,
    double? rating, int? completedJobs, String? bio,
  }) => UserEntity(
    id: id ?? this.id, name: name ?? this.name, email: email ?? this.email,
    phone: phone ?? this.phone, role: role ?? this.role,
    avatarUrl: avatarUrl ?? this.avatarUrl, specialty: specialty ?? this.specialty,
    rating: rating ?? this.rating, completedJobs: completedJobs ?? this.completedJobs,
    bio: bio ?? this.bio,
  );

  @override
  List<Object?> get props => [id, name, email, phone, role, avatarUrl, specialty, rating, completedJobs, bio];
}
