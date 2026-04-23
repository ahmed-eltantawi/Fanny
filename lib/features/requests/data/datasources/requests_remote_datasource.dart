import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/requests_repository.dart';

/// Abstract datasource contract.
abstract class RequestsRemoteDataSource {
  Future<List<RequestEntity>> getRequests(GetRequestsParams params);
  Future<RequestEntity> createRequest(CreateRequestParams params);
  Future<RequestEntity> updateRequestStatus(String id, RequestStatus status);
}

class RequestsFirestoreDataSource implements RequestsRemoteDataSource {
  RequestsFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('requests');

  @override
  Future<List<RequestEntity>> getRequests(GetRequestsParams params) async {
    Query<Map<String, dynamic>> query = _requests;

    if (params.role == 'customer' && params.userId != null) {
      query = query.where('customerId', isEqualTo: params.userId);
    }
    if (params.role == 'technician') {
      query = query.where('status', isEqualTo: 'pending');
    }
    query = query.orderBy('createdAt', descending: true);
    final snap = await query.get();
    return snap.docs.map(_mapRequest).toList();
  }

  @override
  Future<RequestEntity> createRequest(CreateRequestParams params) async {
    final doc = _requests.doc();
    final payload = <String, dynamic>{
      'id': doc.id,
      'customerId': params.customerId,
      'customerName': params.customerName,
      'customerAvatar': params.customerAvatar,
      'title': params.title,
      'description': params.description,
      'category': params.category,
      'categoryNameAr': params.categoryNameAr,
      'categoryNameEn': params.categoryNameEn,
      'location': params.location,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrls': params.photoUrls,
      'imageUrl': params.photoUrls.isNotEmpty ? params.photoUrls.first : '',
      'price': params.budget ?? 0,
      'budget': params.budget,
      'offersCount': 0,
    };
    await doc.set(payload);

    final customerEmbeddedRequest = <String, dynamic>{
      ...payload,
      'createdAt': Timestamp.now(),
    };

    await _firestore.collection('customers').doc(params.customerId).set({
      'id': params.customerId,
      'name': params.customerName,
      'email': '',
      'profileImage': params.customerAvatar,
      'rating': 5.0,
      'requests': FieldValue.arrayUnion([customerEmbeddedRequest]),
    }, SetOptions(merge: true));

    final request = RequestEntity(
      id: doc.id,
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
    return request;
  }

  @override
  Future<RequestEntity> updateRequestStatus(String id, RequestStatus status) async {
    await _requests.doc(id).update({'status': _statusToString(status)});
    final updated = await _requests.doc(id).get();
    if (!updated.exists) throw Exception('Request not found');
    return _mapRequest(updated);
  }

  RequestEntity _mapRequest(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    return RequestEntity(
      id: doc.id,
      customerId: (data['customerId'] ?? '') as String,
      customerName: (data['customerName'] ?? '') as String,
      customerAvatar: (data['customerAvatar'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      category: (data['category'] ?? 'general_repair') as String,
      categoryNameAr: (data['categoryNameAr'] ?? '') as String,
      categoryNameEn: (data['categoryNameEn'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      status: _statusFromString(data['status'] as String?),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      photoUrls: ((data['photoUrls'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      budget: (data['budget'] as num?)?.toDouble(),
      offersCount: (data['offersCount'] as num?)?.toInt() ?? 0,
      assignedTechnicianId: data['assignedTechnicianId'] as String?,
      assignedTechnicianName: data['assignedTechnicianName'] as String?,
    );
  }

  RequestStatus _statusFromString(String? value) {
    switch (value) {
      case 'inProgress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'pending':
      default:
        return RequestStatus.pending;
    }
  }

  String _statusToString(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.inProgress:
        return 'inProgress';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
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
