import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offers_repository.dart';

/// Abstract datasource contract.
abstract class OffersRemoteDataSource {
  Future<List<OfferEntity>> getOffers(GetOffersParams params);
  Future<OfferEntity> submitOffer(SubmitOfferParams params);
  Future<OfferEntity> acceptOffer(String offerId);
}

class OffersFirestoreDataSource implements OffersRemoteDataSource {
  OffersFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _offers =>
      _firestore.collection('offers');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('requests');

  @override
  Future<List<OfferEntity>> getOffers(GetOffersParams params) async {
    try {
      final snap = await _offers
          .where('requestId', isEqualTo: params.requestId)
          .orderBy('price')
          .get();
      return snap.docs.map(_mapOffer).toList();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      final snap = await _offers.where('requestId', isEqualTo: params.requestId).get();
      final offers = snap.docs.map(_mapOffer).toList()
        ..sort((a, b) => a.price.compareTo(b.price));
      return offers;
    }
  }

  @override
  Future<OfferEntity> submitOffer(SubmitOfferParams params) async {
    final offerDoc = _offers.doc();
    final offer = OfferEntity(
      id: offerDoc.id,
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

    await _firestore.runTransaction((tx) async {
      tx.set(offerDoc, {
        'id': offer.id,
        'requestId': offer.requestId,
        'technicianId': offer.technicianId,
        'technicianName': offer.technicianName,
        'technicianAvatarUrl': offer.technicianAvatarUrl,
        'technicianRating': offer.technicianRating,
        'technicianCompletedJobs': offer.technicianCompletedJobs,
        'technicianSpecialty': offer.technicianSpecialty,
        'price': offer.price,
        'estimatedDuration': offer.estimatedDuration,
        'note': offer.note,
        'isAccepted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(_requests.doc(params.requestId), {
        'offersCount': FieldValue.increment(1),
      });
    });

    return offer;
  }

  @override
  Future<OfferEntity> acceptOffer(String offerId) async {
    final offerRef = _offers.doc(offerId);
    final accepted = await _firestore.runTransaction<OfferEntity>((tx) async {
      final offerSnap = await tx.get(offerRef);
      if (!offerSnap.exists) throw Exception('Offer not found');
      final acceptedOffer = _mapOffer(offerSnap);

      final requestOffers = await _offers
          .where('requestId', isEqualTo: acceptedOffer.requestId)
          .get();
      for (final doc in requestOffers.docs) {
        tx.update(doc.reference, {'isAccepted': doc.id == offerId});
      }

      tx.update(_requests.doc(acceptedOffer.requestId), {
        'status': 'inProgress',
        'assignedTechnicianId': acceptedOffer.technicianId,
        'assignedTechnicianName': acceptedOffer.technicianName,
      });

      return acceptedOffer.copyWith(isAccepted: true);
    });
    return accepted;
  }

  OfferEntity _mapOffer(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    return OfferEntity(
      id: doc.id,
      requestId: (data['requestId'] ?? '') as String,
      technicianId: (data['technicianId'] ?? '') as String,
      technicianName: (data['technicianName'] ?? '') as String,
      technicianAvatarUrl: data['technicianAvatarUrl'] as String?,
      technicianRating: (data['technicianRating'] as num?)?.toDouble() ?? 0,
      technicianCompletedJobs:
          (data['technicianCompletedJobs'] as num?)?.toInt() ?? 0,
      technicianSpecialty: (data['technicianSpecialty'] ?? '') as String,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      estimatedDuration: (data['estimatedDuration'] ?? '') as String,
      note: data['note'] as String?,
      isAccepted: (data['isAccepted'] ?? false) as bool,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
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
