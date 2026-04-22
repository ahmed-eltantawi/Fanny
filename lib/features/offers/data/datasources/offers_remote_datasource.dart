import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offers_repository.dart';
import '../../../requests/domain/entities/request_entity.dart';

/// Abstract datasource contract.
abstract class OffersRemoteDataSource {
  Future<List<OfferEntity>> getOffers(GetOffersParams params);
  Future<OfferEntity> submitOffer(SubmitOfferParams params);
  Future<OfferEntity> acceptOffer(String offerId);
}

/// Mock implementation backed by [MockData.offers].
class OffersMockDataSource implements OffersRemoteDataSource {
  @override
  Future<List<OfferEntity>> getOffers(GetOffersParams params) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.getOffersForRequest(params.requestId);
  }

  @override
  Future<OfferEntity> submitOffer(SubmitOfferParams params) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final offer = OfferEntity(
      id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
      requestId: params.requestId,
      technicianId: params.technicianId,
      technicianName: params.technicianName,
      technicianAvatarUrl: params.technicianAvatarUrl,
      technicianRating: params.technicianRating,
      technicianCompletedJobs: params.technicianCompletedJobs,
      technicianSpecialty: params.technicianSpecialty,
      price: params.price,
      estimatedDuration: params.estimatedDuration,
      note: params.note,
      isAccepted: false,
      createdAt: DateTime.now(),
    );
    MockData.offers.add(offer);
    // Increment offers count on the request
    final reqIdx = MockData.requests.indexWhere((r) => r.id == params.requestId);
    if (reqIdx != -1) {
      MockData.requests[reqIdx] = MockData.requests[reqIdx]
          .copyWith(offersCount: MockData.requests[reqIdx].offersCount + 1);
    }
    return offer;
  }

  @override
  Future<OfferEntity> acceptOffer(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final idx = MockData.offers.indexWhere((o) => o.id == offerId);
    if (idx == -1) throw Exception('Offer not found');
    final accepted = MockData.offers[idx].copyWith(isAccepted: true);
    MockData.offers[idx] = accepted;
    // Update request status to inProgress
    final reqIdx = MockData.requests.indexWhere((r) => r.id == accepted.requestId);
    if (reqIdx != -1) {
      MockData.requests[reqIdx] = MockData.requests[reqIdx].copyWith(
        status: RequestStatus.inProgress,
        assignedTechnicianId: accepted.technicianId,
        assignedTechnicianName: accepted.technicianName,
      );
    }
    return accepted;
  }
}

/// Repository impl with Either error wrapping.
class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource dataSource;
  OffersRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<OfferEntity>>> getOffers(GetOffersParams params) async {
    try {
      return Right(await dataSource.getOffers(params));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> submitOffer(SubmitOfferParams params) async {
    try {
      return Right(await dataSource.submitOffer(params));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> acceptOffer(String offerId) async {
    try {
      return Right(await dataSource.acceptOffer(offerId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
