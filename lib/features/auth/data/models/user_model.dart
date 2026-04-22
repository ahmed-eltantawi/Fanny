import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Data model for UserEntity — handles JSON serialisation.
class UserModel extends UserEntity {
  const UserModel({
    required super.id, required super.name, required super.email,
    required super.phone, required super.role, super.avatarUrl,
    super.specialty, super.rating, super.completedJobs, super.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    role: UserRole.values.firstWhere((r) => r.name == json['role']),
    avatarUrl: json['avatarUrl'] as String?,
    specialty: json['specialty'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    completedJobs: json['completedJobs'] as int?,
    bio: json['bio'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'role': role.name, 'avatarUrl': avatarUrl, 'specialty': specialty,
    'rating': rating, 'completedJobs': completedJobs, 'bio': bio,
  };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id, name: entity.name, email: entity.email,
    phone: entity.phone, role: entity.role, avatarUrl: entity.avatarUrl,
    specialty: entity.specialty, rating: entity.rating,
    completedJobs: entity.completedJobs, bio: entity.bio,
  );

  /// Build a new user from [RegisterParams].
  factory UserModel.fromRegisterParams(RegisterParams params) => UserModel(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    name: params.name, email: params.email, phone: params.phone,
    role: params.role, specialty: params.specialty,
    avatarUrl:
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(params.name)}&background=1A237E&color=fff&size=200',
  );
}
