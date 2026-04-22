import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/offer_entity.dart';

/// Params for fetching offers on a request.
class GetOffersParams {
  final String requestId;
  const GetOffersParams(this.requestId);
}

/// Params for submitting a new offer.
class SubmitOfferParams {
  final String requestId;
  final String technicianId;
  final String technicianName;
  final String? technicianAvatarUrl;
  final double technicianRating;
  final int technicianCompletedJobs;
  final String technicianSpecialty;
  final double price;
  final String estimatedDuration;
  final String? note;

  const SubmitOfferParams({
    required this.requestId, required this.technicianId,
    required this.technicianName, this.technicianAvatarUrl,
    required this.technicianRating, required this.technicianCompletedJobs,
    required this.technicianSpecialty, required this.price,
    required this.estimatedDuration, this.note,
  });
}

/// Offers repository contract.
abstract class OffersRepository {
  Future<Either<Failure, List<OfferEntity>>> getOffers(GetOffersParams params);
  Future<Either<Failure, OfferEntity>> submitOffer(SubmitOfferParams params);
  Future<Either<Failure, OfferEntity>> acceptOffer(String offerId);
}

/// Use case: get all offers for a request.
class GetOffersUseCase implements UseCase<List<OfferEntity>, GetOffersParams> {
  final OffersRepository repository;
  GetOffersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OfferEntity>>> call(GetOffersParams params) =>
      repository.getOffers(params);
}

/// Use case: submit an offer as a technician.
class SubmitOfferUseCase implements UseCase<OfferEntity, SubmitOfferParams> {
  final OffersRepository repository;
  SubmitOfferUseCase(this.repository);

  @override
  Future<Either<Failure, OfferEntity>> call(SubmitOfferParams params) =>
      repository.submitOffer(params);
}

/// Use case: accept an offer as a customer.
class AcceptOfferUseCase {
  final OffersRepository repository;
  AcceptOfferUseCase(this.repository);

  Future<Either<Failure, OfferEntity>> call(String offerId) =>
      repository.acceptOffer(offerId);
}
