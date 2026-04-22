import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/requests_repository.dart';

/// Abstract datasource contract.
abstract class RequestsRemoteDataSource {
  Future<List<RequestEntity>> getRequests(GetRequestsParams params);
  Future<RequestEntity> createRequest(CreateRequestParams params);
  Future<RequestEntity> updateRequestStatus(String id, RequestStatus status);
}

/// Mock implementation that reads/writes to [MockData.requests].
class RequestsMockDataSource implements RequestsRemoteDataSource {
  @override
  Future<List<RequestEntity>> getRequests(GetRequestsParams params) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (params.role == 'customer' && params.userId != null) {
      return MockData.getRequestsForCustomer(params.userId!);
    }
    if (params.role == 'technician') {
      return MockData.getAllPendingRequests();
    }
    // Admin sees all
    return List.from(MockData.requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<RequestEntity> createRequest(CreateRequestParams params) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final request = RequestEntity(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      customerId: params.customerId,
      customerName: params.customerName,
      customerAvatar: params.customerAvatar,
      title: params.title,
      description: params.description,
      category: params.category,
      categoryNameAr: params.categoryNameAr,
      categoryNameEn: params.categoryNameEn,
      location: params.location,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      photoUrls: params.photoUrls,
      budget: params.budget,
      offersCount: 0,
    );
    MockData.requests.add(request);
    return request;
  }

  @override
  Future<RequestEntity> updateRequestStatus(String id, RequestStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = MockData.requests.indexWhere((r) => r.id == id);
    if (index == -1) throw Exception('Request not found');
    final updated = MockData.requests[index].copyWith(status: status);
    MockData.requests[index] = updated;
    return updated;
  }
}

/// Repository impl with Either error wrapping.
class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource dataSource;
  RequestsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<RequestEntity>>> getRequests(GetRequestsParams params) async {
    try {
      return Right(await dataSource.getRequests(params));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RequestEntity>> createRequest(CreateRequestParams params) async {
    try {
      return Right(await dataSource.createRequest(params));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RequestEntity>> updateRequestStatus(String id, RequestStatus status) async {
    try {
      return Right(await dataSource.updateRequestStatus(id, status));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
