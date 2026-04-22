import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/request_entity.dart';

/// Params for getting requests (filtered by role/user).
class GetRequestsParams {
  final String? userId;
  final String? role; // 'customer', 'technician', 'admin'
  const GetRequestsParams({this.userId, this.role});
}

/// Params for creating a new request.
class CreateRequestParams {
  final String customerId;
  final String customerName;
  final String customerAvatar;
  final String title;
  final String description;
  final String category;
  final String categoryNameAr;
  final String categoryNameEn;
  final String location;
  final List<String> photoUrls;
  final double? budget;

  const CreateRequestParams({
    required this.customerId, required this.customerName,
    required this.customerAvatar, required this.title,
    required this.description, required this.category,
    required this.categoryNameAr, required this.categoryNameEn,
    required this.location, required this.photoUrls, this.budget,
  });
}

/// Requests repository contract.
abstract class RequestsRepository {
  Future<Either<Failure, List<RequestEntity>>> getRequests(GetRequestsParams params);
  Future<Either<Failure, RequestEntity>> createRequest(CreateRequestParams params);
  Future<Either<Failure, RequestEntity>> updateRequestStatus(String id, RequestStatus status);
}

/// Use case: fetch a list of requests.
class GetRequestsUseCase implements UseCase<List<RequestEntity>, GetRequestsParams> {
  final RequestsRepository repository;
  GetRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RequestEntity>>> call(GetRequestsParams params) =>
      repository.getRequests(params);
}

/// Use case: create a new service request.
class CreateRequestUseCase implements UseCase<RequestEntity, CreateRequestParams> {
  final RequestsRepository repository;
  CreateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, RequestEntity>> call(CreateRequestParams params) =>
      repository.createRequest(params);
}

/// Use case: update a request's status.
class UpdateRequestStatusUseCase {
  final RequestsRepository repository;
  UpdateRequestStatusUseCase(this.repository);

  Future<Either<Failure, RequestEntity>> call(String id, RequestStatus status) =>
      repository.updateRequestStatus(id, status);
}
