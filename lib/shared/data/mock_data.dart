import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/home/domain/entities/service_category_entity.dart';
import '../../features/requests/domain/entities/request_entity.dart';
import '../../features/offers/domain/entities/offer_entity.dart';

/// In-memory mock data. Replace data sources with real API calls to swap this out.
/// All lists are mutable so mock actions (create, accept) work at runtime.
class MockData {
  MockData._();

  // ─────────────────────── CATEGORIES ──────────────────────────────────────
  static final List<ServiceCategoryEntity> categories = [
    const ServiceCategoryEntity(id: 'plumbing',        nameEn: 'Plumbing',        nameAr: 'سباكة',      iconName: 'plumbing',             colorValue: 0xFF1565C0),
    const ServiceCategoryEntity(id: 'electrical',      nameEn: 'Electrical',      nameAr: 'كهرباء',     iconName: 'electrical_services',  colorValue: 0xFFE65100),
    const ServiceCategoryEntity(id: 'carpentry',       nameEn: 'Carpentry',       nameAr: 'نجارة',      iconName: 'carpenter',            colorValue: 0xFF4E342E),
    const ServiceCategoryEntity(id: 'painting',        nameEn: 'Painting',        nameAr: 'دهانات',     iconName: 'format_paint',         colorValue: 0xFF6A1B9A),
    const ServiceCategoryEntity(id: 'ac_repair',       nameEn: 'AC Repair',       nameAr: 'تكييف',      iconName: 'ac_unit',              colorValue: 0xFF006064),
    const ServiceCategoryEntity(id: 'cleaning',        nameEn: 'Cleaning',        nameAr: 'تنظيف',      iconName: 'cleaning_services',    colorValue: 0xFF1B5E20),
    const ServiceCategoryEntity(id: 'general_repair',  nameEn: 'General Repair',  nameAr: 'إصلاح عام',  iconName: 'build',                colorValue: 0xFF880E4F),
    const ServiceCategoryEntity(id: 'masonry',         nameEn: 'Masonry',         nameAr: 'بناء',       iconName: 'home_repair_service',  colorValue: 0xFF37474F),
  ];

  // ─────────────────────── USERS ────────────────────────────────────────────
  static final List<UserEntity> users = [
    const UserEntity(
      id: 'user_customer_1',
      name: 'أحمد حسن',
      email: 'ahmed@example.com',
      phone: '0111234567',
      role: UserRole.customer,
      avatarUrl: 'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
    ),
    const UserEntity(
      id: 'user_tech_1',
      name: 'محمد علي',
      email: 'mohamed@example.com',
      phone: '0109876543',
      role: UserRole.technician,
      avatarUrl: 'https://ui-avatars.com/api/?name=Mohamed+Ali&background=E65100&color=fff&size=200',
      specialty: 'plumbing',
      rating: 4.8,
      completedJobs: 142,
      bio: 'سباك محترف بخبرة 10 سنوات في القاهرة الكبرى',
    ),
    const UserEntity(
      id: 'user_tech_2',
      name: 'كريم سعد',
      email: 'karim@example.com',
      phone: '0123456789',
      role: UserRole.technician,
      avatarUrl: 'https://ui-avatars.com/api/?name=Karim+Saad&background=1565C0&color=fff&size=200',
      specialty: 'electrical',
      rating: 4.5,
      completedJobs: 98,
      bio: 'كهربائي شهادة عليا، متخصص في الشبكات المنزلية والصناعية',
    ),
    const UserEntity(
      id: 'user_tech_3',
      name: 'سامي محمود',
      email: 'sami@example.com',
      phone: '0155556789',
      role: UserRole.technician,
      avatarUrl: 'https://ui-avatars.com/api/?name=Sami+Mahmoud&background=4E342E&color=fff&size=200',
      specialty: 'carpentry',
      rating: 4.9,
      completedJobs: 203,
      bio: 'نجار فنان، متخصص في الديكور وأعمال الخشب الفاخرة',
    ),
    const UserEntity(
      id: 'user_admin_1',
      name: 'فريق فاني',
      email: 'admin@fanny.app',
      phone: '0100000000',
      role: UserRole.admin,
      avatarUrl: 'https://ui-avatars.com/api/?name=Fanny+Admin&background=1A237E&color=fff&size=200',
    ),
  ];

  // ─────────────────────── REQUESTS ─────────────────────────────────────────
  static final List<RequestEntity> requests = [
    RequestEntity(
      id: 'req_001',
      customerId: 'user_customer_1',
      customerName: 'أحمد حسن',
      customerAvatar: 'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      title: 'تسرب مياه في المطبخ',
      description: 'يوجد تسرب في أنبوب المياه تحت الحوض منذ يومين، وسقط السقف جزئياً',
      category: 'plumbing',
      categoryNameAr: 'سباكة',
      categoryNameEn: 'Plumbing',
      location: 'مدينة نصر، القاهرة',
      status: RequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      photoUrls: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      ],
      budget: 500,
      offersCount: 3,
    ),
    RequestEntity(
      id: 'req_002',
      customerId: 'user_customer_1',
      customerName: 'أحمد حسن',
      customerAvatar: 'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      title: 'عطل في لوحة الكهرباء',
      description: 'القاطع الرئيسي يفصل باستمرار عند تشغيل الغسالة والتكييف معاً',
      category: 'electrical',
      categoryNameAr: 'كهرباء',
      categoryNameEn: 'Electrical',
      location: 'المعادي، القاهرة',
      status: RequestStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      photoUrls: [],
      budget: 300,
      offersCount: 2,
      assignedTechnicianId: 'user_tech_2',
      assignedTechnicianName: 'كريم سعد',
    ),
    RequestEntity(
      id: 'req_003',
      customerId: 'user_customer_1',
      customerName: 'أحمد حسن',
      customerAvatar: 'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      title: 'تركيب باب خشبي جديد',
      description: 'أحتاج لتركيب باب خشبي مصمت للغرفة الرئيسية مع أعمال التشطيب',
      category: 'carpentry',
      categoryNameAr: 'نجارة',
      categoryNameEn: 'Carpentry',
      location: 'الرحاب، القاهرة',
      status: RequestStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      photoUrls: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'https://images.unsplash.com/photo-1606210954827-c9f0a00d2b25?w=400',
      ],
      budget: 1200,
      offersCount: 4,
      assignedTechnicianId: 'user_tech_3',
      assignedTechnicianName: 'سامي محمود',
    ),
    RequestEntity(
      id: 'req_004',
      customerId: 'user_customer_1',
      customerName: 'أحمد حسن',
      customerAvatar: 'https://ui-avatars.com/api/?name=Ahmed+Hassan&background=1A237E&color=fff&size=200',
      title: 'صيانة تكييف غرفة النوم',
      description: 'التكييف لا يبرد بشكل كافٍ، ومحتاج فريون وتنظيف شامل',
      category: 'ac_repair',
      categoryNameAr: 'تكييف',
      categoryNameEn: 'AC Repair',
      location: 'هليوبوليس، القاهرة',
      status: RequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      photoUrls: [],
      offersCount: 0,
    ),
  ];

  // ─────────────────────── OFFERS ───────────────────────────────────────────
  static final List<OfferEntity> offers = [
    OfferEntity(
      id: 'offer_001',
      requestId: 'req_001',
      technicianId: 'user_tech_1',
      technicianName: 'محمد علي',
      technicianAvatarUrl: 'https://ui-avatars.com/api/?name=Mohamed+Ali&background=E65100&color=fff&size=200',
      technicianRating: 4.8,
      technicianCompletedJobs: 142,
      technicianSpecialty: 'سباكة',
      price: 350,
      estimatedDuration: '3 ساعات',
      note: 'سأحل المشكلة بشكل كامل مع ضمان شهر على الإصلاح',
      isAccepted: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OfferEntity(
      id: 'offer_002',
      requestId: 'req_001',
      technicianId: 'user_tech_2',
      technicianName: 'كريم سعد',
      technicianAvatarUrl: 'https://ui-avatars.com/api/?name=Karim+Saad&background=1565C0&color=fff&size=200',
      technicianRating: 4.5,
      technicianCompletedJobs: 98,
      technicianSpecialty: 'سباكة وكهرباء',
      price: 450,
      estimatedDuration: '2 ساعات',
      note: 'أعمل بقطع غيار أصلية فقط',
      isAccepted: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    OfferEntity(
      id: 'offer_003',
      requestId: 'req_001',
      technicianId: 'user_tech_3',
      technicianName: 'سامي محمود',
      technicianAvatarUrl: 'https://ui-avatars.com/api/?name=Sami+Mahmoud&background=4E342E&color=fff&size=200',
      technicianRating: 4.9,
      technicianCompletedJobs: 203,
      technicianSpecialty: 'سباكة ونجارة',
      price: 280,
      estimatedDuration: '4 ساعات',
      note: 'متاح فوراً ويمكن البدء اليوم',
      isAccepted: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    OfferEntity(
      id: 'offer_004',
      requestId: 'req_002',
      technicianId: 'user_tech_2',
      technicianName: 'كريم سعد',
      technicianAvatarUrl: 'https://ui-avatars.com/api/?name=Karim+Saad&background=1565C0&color=fff&size=200',
      technicianRating: 4.5,
      technicianCompletedJobs: 98,
      technicianSpecialty: 'كهرباء',
      price: 250,
      estimatedDuration: '2 ساعات',
      isAccepted: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
    ),
  ];

  // ─────────────────────── HELPERS ──────────────────────────────────────────

  static UserEntity? findUserByEmail(String email, UserRole role) {
    try {
      return users.firstWhere((u) => u.email == email && u.role == role);
    } catch (_) {
      return null;
    }
  }

  static List<RequestEntity> getRequestsForCustomer(String customerId) =>
      requests.where((r) => r.customerId == customerId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static List<RequestEntity> getAllPendingRequests() =>
      requests.where((r) => r.status == RequestStatus.pending).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static List<RequestEntity> getRequestsForTechnician(String technicianId) =>
      requests.where((r) => r.assignedTechnicianId == technicianId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static List<OfferEntity> getOffersForRequest(String requestId) =>
      offers.where((o) => o.requestId == requestId).toList()
        ..sort((a, b) => a.price.compareTo(b.price));

  static List<OfferEntity> getOffersForTechnician(String technicianId) =>
      offers.where((o) => o.technicianId == technicianId).toList();

  // Admin stats
  static int get totalUsersCount => users.where((u) => u.role != UserRole.admin).length;
  static int get totalTechniciansCount => users.where((u) => u.role == UserRole.technician).length;
  static int get totalRequestsCount => requests.length;
  static double get totalRevenue => offers.where((o) => o.isAccepted).fold(0, (acc, o) => acc + o.price * 0.1);
}
