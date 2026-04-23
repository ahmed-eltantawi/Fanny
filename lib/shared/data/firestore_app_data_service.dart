import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/requests/domain/entities/request_entity.dart';

class FirestoreAppDataService {
  FirestoreAppDataService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _customers =>
      _firestore.collection('customers');
  CollectionReference<Map<String, dynamic>> get _technicians =>
      _firestore.collection('technicians');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('requests');
  CollectionReference<Map<String, dynamic>> get _offers =>
      _firestore.collection('offers');

  Future<void> seedInitialData() async {
    final batch = _firestore.batch();

    final customerRef = _customers.doc('customer_ahmed');
    final technician1Ref = _technicians.doc('tech_mohamed');
    final technician2Ref = _technicians.doc('tech_karim');

    batch.set(
        customerRef,
        {
          'id': 'customer_ahmed',
          'name': 'أحمد حسن',
          'email': 'ahmed@example.com',
          'profileImage':
              'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
          'rating': 4.7,
          'requests': <Map<String, dynamic>>[],
        },
        SetOptions(merge: true));

    batch.set(
        technician1Ref,
        {
          'id': 'tech_mohamed',
          'name': 'محمد علي',
          'email': 'mohamed@example.com',
          'profileImage':
              'https://ui-avatars.com/api/?name=Mohamed+Ali&background=E65100&color=fff&size=200',
          'rating': 4.8,
          'hourlyRate': 180.0,
        },
        SetOptions(merge: true));

    batch.set(
        technician2Ref,
        {
          'id': 'tech_karim',
          'name': 'كريم سعد',
          'email': 'karim@example.com',
          'profileImage':
              'https://ui-avatars.com/api/?name=Karim+Saad&background=1565C0&color=fff&size=200',
          'rating': 4.5,
          'hourlyRate': 160.0,
        },
        SetOptions(merge: true));

    final pendingRequestRef = _requests.doc('req_seed_pending');
    final inProgressRequestRef = _requests.doc('req_seed_inprogress');
    final paintingRequestRef = _requests.doc('req_seed_painting');
    final cleaningRequestRef = _requests.doc('req_seed_cleaning');
    final seedNow = Timestamp.now();

    final pendingRequest = {
      'id': 'req_seed_pending',
      'customerId': 'customer_ahmed',
      'customerName': 'أحمد حسن',
      'customerAvatar':
          'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      'title': 'تسرب مياه في المطبخ',
      'description': 'يوجد تسرب واضح أسفل الحوض ويحتاج إصلاح عاجل.',
      'category': 'plumbing',
      'categoryNameAr': 'سباكة',
      'categoryNameEn': 'Plumbing',
      'location': 'مدينة نصر، القاهرة',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrls': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      'price': 500.0,
      'budget': 500.0,
      'offersCount': 1,
    };
    final pendingRequestForCustomer = {
      ...pendingRequest,
      'createdAt': seedNow,
    };

    final inProgressRequest = {
      'id': 'req_seed_inprogress',
      'customerId': 'customer_ahmed',
      'customerName': 'أحمد حسن',
      'customerAvatar':
          'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      'title': 'عطل في لوحة الكهرباء',
      'description': 'القاطع الرئيسي يفصل باستمرار عند تشغيل الأجهزة.',
      'category': 'electrical',
      'categoryNameAr': 'كهرباء',
      'categoryNameEn': 'Electrical',
      'location': 'المعادي، القاهرة',
      'status': 'inProgress',
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrls': const <String>[],
      'imageUrl': '',
      'price': 300.0,
      'budget': 300.0,
      'offersCount': 1,
      'assignedTechnicianId': 'tech_karim',
      'assignedTechnicianName': 'كريم سعد',
    };
    final inProgressRequestForCustomer = {
      ...inProgressRequest,
      'createdAt': seedNow,
    };

    final paintingRequest = {
      'id': 'req_seed_painting',
      'customerId': 'customer_ahmed',
      'customerName': 'أحمد حسن',
      'customerAvatar':
          'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      'title': 'دهان حائط غرفة المعيشة',
      'description': 'مطلوب دهان حائطين مع معالجة شروخ بسيطة قبل الدهان.',
      'category': 'painting',
      'categoryNameAr': 'دهانات',
      'categoryNameEn': 'Painting',
      'location': 'التجمع الخامس، القاهرة',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrls': const <String>[],
      'imageUrl': '',
      'price': 950.0,
      'budget': 950.0,
      'offersCount': 0,
    };
    final paintingRequestForCustomer = {
      ...paintingRequest,
      'createdAt': seedNow,
    };

    final cleaningRequest = {
      'id': 'req_seed_cleaning',
      'customerId': 'customer_ahmed',
      'customerName': 'أحمد حسن',
      'customerAvatar':
          'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      'title': 'تنظيف شامل بعد التشطيب',
      'description': 'تنظيف شقة 3 غرف بعد أعمال تشطيب، يشمل الأرضيات والزجاج.',
      'category': 'cleaning',
      'categoryNameAr': 'تنظيف',
      'categoryNameEn': 'Cleaning',
      'location': '6 أكتوبر، الجيزة',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrls': const <String>[],
      'imageUrl': '',
      'price': 650.0,
      'budget': 650.0,
      'offersCount': 0,
    };
    final cleaningRequestForCustomer = {
      ...cleaningRequest,
      'createdAt': seedNow,
    };

    batch.set(pendingRequestRef, pendingRequest, SetOptions(merge: true));
    batch.set(inProgressRequestRef, inProgressRequest, SetOptions(merge: true));
    batch.set(paintingRequestRef, paintingRequest, SetOptions(merge: true));
    batch.set(cleaningRequestRef, cleaningRequest, SetOptions(merge: true));

    batch.set(
      customerRef,
      {
        'requests': [
          pendingRequestForCustomer,
          inProgressRequestForCustomer,
          paintingRequestForCustomer,
          cleaningRequestForCustomer,
        ]
      },
      SetOptions(merge: true),
    );

    final offerRef = _offers.doc('offer_seed_1');
    batch.set(
        offerRef,
        {
          'id': 'offer_seed_1',
          'requestId': 'req_seed_pending',
          'technicianId': 'tech_mohamed',
          'technicianName': 'محمد علي',
          'technicianAvatarUrl':
              'https://ui-avatars.com/api/?name=Mohamed+Ali&background=E65100&color=fff&size=200',
          'technicianRating': 4.8,
          'technicianCompletedJobs': 142,
          'technicianSpecialty': 'سباكة',
          'price': 350.0,
          'estimatedDuration': '3 ساعات',
          'note': 'متاح اليوم مع ضمان على الإصلاح.',
          'isAccepted': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> seedFakeRequestsForEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return;

    final customerSnap = await _customers
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    final customerRef = customerSnap.docs.isNotEmpty
        ? customerSnap.docs.first.reference
        : _customers.doc('customer_${_safeIdPart(normalizedEmail)}');

    final customerId = customerRef.id;
    final customerName = _displayNameFromEmail(normalizedEmail);
    final customerAvatar =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(customerName)}&background=1A237E&color=fff&size=200';

    final createdAtOne = Timestamp.fromDate(DateTime(2026, 4, 22, 10, 0));
    final createdAtTwo = Timestamp.fromDate(DateTime(2026, 4, 22, 10, 30));
    final createdAtThree = Timestamp.fromDate(DateTime(2026, 4, 22, 11, 0));

    final req1Id = 'req_fake_${_safeIdPart(customerId)}_1';
    final req2Id = 'req_fake_${_safeIdPart(customerId)}_2';
    final req3Id = 'req_fake_${_safeIdPart(customerId)}_3';

    final req1 = {
      'id': req1Id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'title': 'تصليح تسرب تحت الحوض',
      'description': 'مياه تتسرب باستمرار أسفل حوض المطبخ وتحتاج إصلاح سريع.',
      'category': 'plumbing',
      'categoryNameAr': 'سباكة',
      'categoryNameEn': 'Plumbing',
      'location': 'القاهرة',
      'status': 'pending',
      'createdAt': createdAtOne,
      'photoUrls': const <String>[],
      'imageUrl': '',
      'price': 450.0,
      'budget': 450.0,
      'offersCount': 0,
    };

    final req2 = {
      'id': req2Id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'title': 'صيانة تكييف لا يبرد',
      'description': 'التكييف يعمل لكن التبريد ضعيف جدا ويحتاج فحص شامل.',
      'category': 'ac_maintenance',
      'categoryNameAr': 'تكييف',
      'categoryNameEn': 'AC Maintenance',
      'location': 'الجيزة',
      'status': 'pending',
      'createdAt': createdAtTwo,
      'photoUrls': const <String>[],
      'imageUrl': '',
      'price': 700.0,
      'budget': 700.0,
      'offersCount': 0,
    };

    final req3 = {
      'id': req3Id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'title': 'تجديد دهان غرفة نوم',
      'description': 'مطلوب دهان جديد لغرفة النوم مع معالجة بسيطة للحائط.',
      'category': 'painting',
      'categoryNameAr': 'دهانات',
      'categoryNameEn': 'Painting',
      'location': 'القليوبية',
      'status': 'pending',
      'createdAt': createdAtThree,
      'photoUrls': const <String>[],
      'imageUrl': '',
      'price': 900.0,
      'budget': 900.0,
      'offersCount': 0,
    };

    final batch = _firestore.batch();
    batch.set(
        customerRef,
        {
          'id': customerId,
          'name': customerName,
          'email': normalizedEmail,
          'profileImage': customerAvatar,
          'rating': 5.0,
          'requests': FieldValue.arrayUnion([req1, req2, req3]),
        },
        SetOptions(merge: true));
    batch.set(_requests.doc(req1Id), req1, SetOptions(merge: true));
    batch.set(_requests.doc(req2Id), req2, SetOptions(merge: true));
    batch.set(_requests.doc(req3Id), req3, SetOptions(merge: true));
    await batch.commit();
  }

  Future<List<UserEntity>> getTopTechnicians() async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap =
          await _technicians.orderBy('rating', descending: true).limit(5).get();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      snap = await _technicians.limit(20).get();
    }
    final users = snap.docs.map((doc) {
      final data = doc.data();
      return UserEntity(
        id: doc.id,
        name: (data['name'] ?? '') as String,
        email: (data['email'] ?? '') as String,
        phone: (data['phone'] ?? '') as String,
        role: UserRole.technician,
        avatarUrl: data['profileImage'] as String?,
        specialty: data['specialty'] as String? ?? 'general_repair',
        rating: (data['rating'] as num?)?.toDouble(),
      );
    }).toList();
    users.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return users.take(5).toList();
  }

  Future<List<RequestEntity>> getCustomerRecentRequests(
      String customerId) async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _requests
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();
      return snap.docs.map(_mapRequest).toList();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      snap = await _requests.where('customerId', isEqualTo: customerId).get();
      final requests = snap.docs.map(_mapRequest).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests.take(3).toList();
    }
  }

  Future<List<RequestEntity>> getTechnicianAssignedRequests(
      String technicianId) async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _requests
          .where('assignedTechnicianId', isEqualTo: technicianId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(_mapRequest).toList();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      snap = await _requests
          .where('assignedTechnicianId', isEqualTo: technicianId)
          .get();
      final requests = snap.docs.map(_mapRequest).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    }
  }

  Future<({int users, int technicians, int requests, int revenue})>
      getAdminStats() async {
    final customersSnap = await _customers.get();
    final techniciansSnap = await _technicians.get();
    final requestsSnap = await _requests.get();
    final acceptedOffersSnap =
        await _offers.where('isAccepted', isEqualTo: true).get();
    var revenue = 0.0;
    for (final doc in acceptedOffersSnap.docs) {
      revenue += (doc.data()['price'] as num?)?.toDouble() ?? 0;
    }

    return (
      users: customersSnap.size + techniciansSnap.size,
      technicians: techniciansSnap.size,
      requests: requestsSnap.size,
      revenue: revenue.toInt(),
    );
  }

  RequestEntity _mapRequest(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
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
      status: _requestStatusFromString(data['status'] as String?),
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

  RequestStatus _requestStatusFromString(String? value) {
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

  String _safeIdPart(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  String _displayNameFromEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return 'عميل';
    final local =
        email.substring(0, at).replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ');
    final compact = local.trim().replaceAll(RegExp(r'\s+'), ' ');
    return compact.isEmpty ? 'عميل' : compact;
  }
}
