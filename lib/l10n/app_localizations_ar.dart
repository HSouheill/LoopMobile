// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String underConstructionPage(String pageName) {
    return '🚧 صفحة $pageName قيد الإنشاء';
  }

  @override
  String get agents => 'وكلاء';

  @override
  String get listings => 'قوائم';

  @override
  String get home => 'الرئيسية';

  @override
  String get services => 'الخدمات';

  @override
  String get chat => 'محادثة';

  @override
  String get appTitle => 'تطبيق شريط التنقل';

  @override
  String get loggedOutSuccessfully => 'تم تسجيل الخروج بنجاح';

  @override
  String get guest => 'ضيف';

  @override
  String get goToDashboard => 'الذهاب إلى لوحة التحكم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get featuredListings => 'القوائم المميزة';

  @override
  String get recommendedAgents => 'الوكلاء الموصى بهم';

  @override
  String get latestMarketUpdates => 'آخر تحديثات السوق';

  @override
  String get supportCardDescription =>
      'تواجه مشاكل قانونية أو مخاوف أخرى متعلقة بممتلكاتك؟ فريق الدعم المختص لدينا على بعد رسالة واحدة فقط جاهز لمساعدتك';

  @override
  String get contactSupport => 'اتصل بالدعم';

  @override
  String get featuredServices => 'الخدمات المميزة';

  @override
  String get topRatedServices => 'الخدمات الأعلى تقييماً';

  @override
  String get companyServices => 'خدمات الشركات';

  @override
  String get individualServices => 'الخدمات الفردية';

  @override
  String get featuredCompanies => 'الشركات المميزة';

  @override
  String get failedToLoadFeaturedServiceProviders =>
      'فشل تحميل مقدمي الخدمات المميزين';

  @override
  String get errorFetchingFeaturedServiceProviders =>
      'خطأ في جلب مقدمي الخدمات المميزين';

  @override
  String get failedToLoadTopRatedServiceProviders =>
      'فشل تحميل مقدمي الخدمات الأعلى تقييماً';

  @override
  String get errorFetchingTopRatedServiceProviders =>
      'خطأ في جلب مقدمي الخدمات الأعلى تقييماً';

  @override
  String get failedToLoadServiceProviders => 'فشل تحميل مقدمي الخدمات';

  @override
  String get errorFetchingServiceProviders => 'خطأ في جلب مقدمي الخدمات';

  @override
  String get noServiceProvidersFound => 'لم يتم العثور على مقدمي خدمات';

  @override
  String get failedToLoadServiceProvider => 'فشل تحميل مقدم الخدمة';

  @override
  String get errorFetchingServiceProvider => 'خطأ في جلب مقدم الخدمة';

  @override
  String get noServiceProviderDataFound =>
      'لم يتم العثور على بيانات مقدم الخدمة';

  @override
  String get failedToLoadMyServices => 'فشل تحميل خدماتي';

  @override
  String get errorFetchingMyServices => 'خطأ في جلب خدماتي';

  @override
  String get failedToLoadAgentServices => 'فشل تحميل خدمات الوكيل';

  @override
  String get errorFetchingAgentServices => 'خطأ في جلب خدمات الوكيل';

  @override
  String get failedToCreateService => 'فشل إنشاء الخدمة';

  @override
  String get pleaseEnterServiceTitle => 'يرجى إدخال عنوان الخدمة';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال عنوان بريد إلكتروني صحيح';

  @override
  String get pleaseEnterValidPortfolioUrl => 'يرجى إدخال رابط محفظة صحيح';

  @override
  String get pleaseCheckInputAndTryAgain =>
      'يرجى التحقق من المدخلات والمحاولة مرة أخرى';

  @override
  String get failedToCreateServiceTryAgain =>
      'فشل إنشاء الخدمة. يرجى المحاولة مرة أخرى.';

  @override
  String get unableToConnectToServer =>
      'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';

  @override
  String get failedToUpdateService => 'فشل تحديث الخدمة';

  @override
  String get failedToUpdateServiceTryAgain =>
      'فشل تحديث الخدمة. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToDeleteService => 'فشل حذف الخدمة';

  @override
  String get failedToDeleteServiceTryAgain =>
      'فشل حذف الخدمة. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToSearchServiceProviders => 'فشل البحث عن مقدمي الخدمات';

  @override
  String get errorSearchingServiceProviders => 'خطأ في البحث عن مقدمي الخدمات';

  @override
  String failedToLoadCategory(String categoryName) {
    return 'فشل تحميل $categoryName';
  }

  @override
  String noCategoryFound(String categoryName) {
    return 'لم يتم العثور على $categoryName';
  }

  @override
  String get noServicesFound => 'لم يتم العثور على خدمات';

  @override
  String get featuredJobs => 'الوظائف المميزة';

  @override
  String get forYouJobs => 'من أجلك';

  @override
  String get recentJobs => 'الوظائف الأخيرة';

  @override
  String get recommendedJobs => 'الوظائف الموصى بها';

  @override
  String get failedToLoadJobs => 'فشل تحميل الوظائف';

  @override
  String get errorFetchingJobs => 'خطأ في جلب الوظائف';

  @override
  String get noJobsFound => 'لم يتم العثور على وظائف';

  @override
  String get failedToLoadJobDetails => 'فشل تحميل تفاصيل الوظيفة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get page => 'الصفحة';

  @override
  String get ofText => 'من';

  @override
  String get exploreJobs => 'استكشف الوظائف';

  @override
  String showingCountOfTotal(int count, int total) {
    return 'عرض $count من $total خدمة مميزة';
  }

  @override
  String get failedToLoadFeaturedServices => 'فشل تحميل الخدمات المميزة';

  @override
  String get noFeaturedServicesFound => 'لم يتم العثور على خدمات مميزة';

  @override
  String get about => 'حول';

  @override
  String get readMore => 'اقرأ المزيد';

  @override
  String get readLess => 'اقرأ أقل';

  @override
  String get noServicesAvailable => 'لا توجد خدمات متاحة';

  @override
  String get contactDetails => 'تفاصيل الاتصال';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف:';

  @override
  String get location => 'الموقع:';

  @override
  String get company => 'الشركة:';

  @override
  String get startChat => 'بدء المحادثة';

  @override
  String get reportServiceProvider => 'الإبلاغ عن مقدم الخدمة';

  @override
  String get reportServiceProviderTooltip => 'الإبلاغ عن مقدم الخدمة';

  @override
  String get pleaseLoginToStartChat => 'الرجاء تسجيل الدخول لبدء المحادثة';

  @override
  String get failedToStartChat => 'فشل بدء المحادثة. يرجى المحاولة مرة أخرى.';

  @override
  String get couldNotMakePhoneCall => 'تعذر الاتصال';

  @override
  String get couldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get errorOpeningPortfolio => 'خطأ في فتح المحفظة';

  @override
  String get noPortfolioAvailable => 'لا توجد محفظة متاحة';

  @override
  String get noServiceProviderDataAvailable =>
      'لا توجد بيانات لمقدم الخدمة متاحة';

  @override
  String professionalServiceProviderDescription(
      String displayName, String city, String country) {
    return '$displayName محترف يقدم خدمات عالية الجودة في $city، $country.';
  }

  @override
  String individualServiceProviderDescription(
      String firstName, String lastName, String city, String country) {
    return '$firstName $lastName هو مقدم خدمات محترف مقيم في $city، $country.';
  }

  @override
  String searchFor(String query) {
    return 'البحث: \"$query\"';
  }

  @override
  String get searchingServiceProviders => 'البحث عن مقدمي الخدمات...';

  @override
  String get tryDifferentKeywords => 'جرب البحث بكلمات مفتاحية مختلفة';

  @override
  String get goBack => 'العودة';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String agentServicesTitle(String agentName) {
    return 'خدمات $agentName';
  }

  @override
  String agentListingsTitle(String firstName) {
    return 'قوائم $firstName';
  }

  @override
  String get failedToLoadServices => 'فشل تحميل الخدمات';

  @override
  String get pleaseLoginToStartChatAgent => 'الرجاء تسجيل الدخول لبدء المحادثة';

  @override
  String get failedToStartChatAgent =>
      'فشل بدء المحادثة. يرجى المحاولة مرة أخرى.';

  @override
  String get couldNotMakePhoneCallAgent => 'تعذر الاتصال';

  @override
  String errorOpeningLinkAgent(String error) {
    return 'خطأ في فتح الرابط: $error';
  }

  @override
  String get reportAgent => 'الإبلاغ عن هذا الوكيل';

  @override
  String get reportAgentTooltip => 'الإبلاغ عن هذا الوكيل';

  @override
  String get aboutAgent => 'حول';

  @override
  String get readMoreAgent => 'اقرأ المزيد';

  @override
  String get readLessAgent => 'اقرأ أقل';

  @override
  String get detailsAgent => 'التفاصيل';

  @override
  String get emailAgent => 'البريد الإلكتروني:';

  @override
  String get serviceAreas => 'مناطق الخدمة:';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح.';

  @override
  String get noProfileImage => 'لا توجد صورة للملف الشخصي';

  @override
  String get failedToLoadAgentData => 'فشل تحميل بيانات الوكيل';

  @override
  String get noAgentDataAvailable => 'لا توجد بيانات للوكيل متاحة';

  @override
  String searchResultsFor(String query) {
    return 'نتائج البحث عن \"$query\"';
  }

  @override
  String foundAgentsFor(int count, String query) {
    return 'تم العثور على $count وكيلاً لـ \"$query\"';
  }

  @override
  String get searchingAgents => 'البحث عن الوكلاء...';

  @override
  String get errorSearchingAgents => 'خطأ في البحث عن الوكلاء';

  @override
  String get noAgentsFound => 'لم يتم العثور على وكلاء';

  @override
  String get tryDifferentKeywordsAgent => 'جرب البحث بكلمات مفتاحية مختلفة';

  @override
  String get featuredAgents => 'الوكلاء المميزون';

  @override
  String get topRatedAgents => 'الوكلاء الأعلى تقييماً';

  @override
  String get recommendedAgentsTitle => 'الوكلاء الموصى بهم';

  @override
  String failedToLoadAgents(String categoryName) {
    return 'فشل تحميل $categoryName';
  }

  @override
  String get noAgentsFoundCategory => 'لم يتم العثور على وكلاء';

  @override
  String get agentDashboard => 'لوحة تحكم الوكيل';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get totalListings => 'إجمالي القوائم:';

  @override
  String get profileViews => 'مشاهدات الملف الشخصي:';

  @override
  String get activeListings => 'القوائم النشطة:';

  @override
  String get totalChats => 'إجمالي المحادثات:';

  @override
  String get addNewListing => 'إضافة إعلان جديد';

  @override
  String get inactiveListings => 'القوائم غير النشطة';

  @override
  String get noInactiveListings => 'لا توجد قوائم غير نشطة';

  @override
  String get listingsLeft => 'القوائم المتبقية';

  @override
  String get upgradePlan => 'ترقية الخطة';

  @override
  String get myListings => 'قوائمي';

  @override
  String get noActiveListings => 'لا توجد قوائم نشطة';

  @override
  String get ratingAndReviews => 'التقييم والمراجعات';

  @override
  String get noReviewsYet => 'لا توجد مراجعات بعد';

  @override
  String get plansAndSubscription => 'الخطط والاشتراك';

  @override
  String get currentSubscription => 'الاشتراك الحالي';

  @override
  String get daysLeft => 'أيام متبقية';

  @override
  String get links => 'الروابط';

  @override
  String get deleteListing => 'حذف القائمة';

  @override
  String deleteListingConfirm(String title) {
    return 'هل أنت متأكد أنك تريد حذف \"$title\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get delete => 'حذف';

  @override
  String get listingDeletedSuccessfully => 'تم حذف القائمة بنجاح';

  @override
  String get failedToDeleteListing => 'فشل حذف القائمة';

  @override
  String errorDeletingListing(String error) {
    return 'خطأ في حذف القائمة: $error';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get soldFunctionalityNotImplemented => 'وظيفة البيع غير مطبقة بعد';

  @override
  String get boostFunctionalityNotImplemented => 'وظيفة التعزيز غير مطبقة بعد';

  @override
  String hiUser(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get activePlan => 'الخطة النشطة:';

  @override
  String validUntil(String date) {
    return 'صالحة حتى: $date';
  }

  @override
  String get noPlan => 'لا توجد خطة';

  @override
  String get myAgents => 'وكلائي';

  @override
  String totalAgents(int count) {
    return 'إجمالي الوكلاء: $count';
  }

  @override
  String pageOf(int current, int total) {
    return 'الصفحة $current من $total';
  }

  @override
  String get noAgentsFoundMy => 'لم يتم العثور على وكلاء';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get noEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get noPhone => 'لا يوجد هاتف';

  @override
  String joined(String date) {
    return 'انضم: $date';
  }

  @override
  String errorLoadingAgents(String error) {
    return 'خطأ في تحميل الوكلاء: $error';
  }

  @override
  String get billingHistory => 'سجل الفواتير';

  @override
  String get date => 'التاريخ';

  @override
  String get totalPaid => 'المبلغ الإجمالي المدفوع';

  @override
  String get searchAgents => 'بحث عن الوكلاء...';

  @override
  String get topAgents => 'أفضل الوكلاء';

  @override
  String get forYouAgents => 'من أجلك';

  @override
  String failedToLoadAgentsWidget(String error) {
    return 'فشل تحميل الوكلاء: $error';
  }

  @override
  String properties(int count) {
    return '$count عقار';
  }

  @override
  String failedToLoadListingsCategory(String categoryName, String error) {
    return 'فشل تحميل $categoryName: $error';
  }

  @override
  String get noListingsFound => 'لم يتم العثور على قوائم';

  @override
  String get featuredLabel => 'مميز';

  @override
  String showingFeaturedListings(int count, int total) {
    return 'عرض $count من $total قائمة مميزة';
  }

  @override
  String get failedToLoadFeaturedListings => 'فشل تحميل القوائم المميزة';

  @override
  String get noFeaturedListingsFound => 'لم يتم العثور على قوائم مميزة';

  @override
  String errorLoadingListings(String error) {
    return 'خطأ في تحميل القوائم: $error';
  }

  @override
  String get activateFunctionalityNotImplemented =>
      'وظيفة التفعيل غير مطبقة بعد';

  @override
  String get editButton => 'تعديل';

  @override
  String get soldButton => 'تم البيع';

  @override
  String get boostButton => 'تعزيز';

  @override
  String get promoteButton => 'ترقية';

  @override
  String get reportListing => 'الإبلاغ عن هذه القائمة';

  @override
  String get phoneNumberNotAvailable => 'رقم الهاتف غير متاح';

  @override
  String get couldNotOpenWhatsApp => 'تعذر فتح واتساب';

  @override
  String errorOpeningWhatsApp(String error) {
    return 'خطأ في فتح واتساب: $error';
  }

  @override
  String get dateNotAvailable => 'التاريخ غير متاح';

  @override
  String get propertyDetails => 'تفاصيل العقار';

  @override
  String get amenitiesLabel => 'وسائل الراحة';

  @override
  String get propertyCodeLabel => 'رمز العقار:';

  @override
  String get listedDateLabel => 'تاريخ الإدراج:';

  @override
  String get propertyCodeCopied => 'تم نسخ رمز العقار إلى الحافظة';

  @override
  String get callButton => 'اتصال';

  @override
  String get whatsAppButton => 'واتساب';

  @override
  String sizeLabel(String size) {
    return 'المساحة: $size متر مربع';
  }

  @override
  String bedroomsBathrooms(String bedrooms, String bathrooms) {
    return '$bedrooms غرف نوم، $bathrooms حمامات';
  }

  @override
  String bedroomsOnly(String bedrooms) {
    return '$bedrooms غرف نوم';
  }

  @override
  String bathroomsOnly(String bathrooms) {
    return '$bathrooms حمامات';
  }

  @override
  String get typeLabel => 'النوع:';

  @override
  String get floorLabel => 'الطابق:';

  @override
  String get conditionLabel => 'الحالة:';

  @override
  String buildingAgeLabel(String age) {
    return 'عمر المبنى: $age سنوات';
  }

  @override
  String get papersLabel => 'الأوراق:';

  @override
  String get availableForLabel => 'متاح لـ:';

  @override
  String availableFromLabel(String date) {
    return 'متاح من: $date';
  }

  @override
  String get newListings => 'القوائم الجديدة';

  @override
  String get apartments => 'شقق';

  @override
  String get chalets => 'شاليهات';

  @override
  String get villas => 'فلل';

  @override
  String get land => 'أراضي';

  @override
  String get commercial => 'تجاري';

  @override
  String get bedText => 'غرفة';

  @override
  String get bathText => 'حمام';

  @override
  String noCategoryListingsFound(String categoryName) {
    return 'لم يتم العثور على $categoryName';
  }

  @override
  String pageCurrentOfTotal(int current, int total) {
    return '$current / $total';
  }

  @override
  String get signUp => 'التسجيل';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get usingEmail => 'باستخدام البريد الإلكتروني';

  @override
  String get usingPhoneNumber => 'باستخدام رقم الهاتف';

  @override
  String get emailOrUsername => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟ ';

  @override
  String get dontHaveAnAccountFull => 'ليس لديك حساب؟ ';

  @override
  String get alreadyHaveAnAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get signUpButton => 'التسجيل';

  @override
  String get logInWithEmailAddress => 'تسجيل الدخول بالبريد الإلكتروني';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get verifyByEmail => 'التحقق بالبريد الإلكتروني';

  @override
  String get verifyByPhone => 'التحقق بالهاتف';

  @override
  String get verifyOtp => 'تحقق من الرمز';

  @override
  String get verifyOtpTitle => 'تحقق من الرمز';

  @override
  String get enterOtp => 'أدخل الرمز';

  @override
  String enterOtpSentToPhone(String phone) {
    return 'أدخل الرمز المرسل إلى رقم هاتفك $phone';
  }

  @override
  String get didntReceiveOtp => 'لم تستلم الرمز؟ ';

  @override
  String get resend => 'إعادة الإرسال';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get createPassword => 'إنشاء كلمة المرور';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'أخرى';

  @override
  String get selectCountry => 'اختر البلد';

  @override
  String get selectDistrict => 'اختر المنطقة';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get completeSignup => 'إكمال التسجيل';

  @override
  String get liveLocation => 'الموقع المباشر';

  @override
  String get thisFieldIsRequired => 'هذا الحقل مطلوب';

  @override
  String get required => 'مطلوب';

  @override
  String get enterValidPhoneNumber => 'أدخل رقم هاتف صالح';

  @override
  String get minimum6Characters => 'الحد الأدنى 6 أحرف';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get invalidPhone => 'رقم هاتف غير صالح';

  @override
  String get pleaseEnterYourPhoneNumber => 'يرجى إدخال رقم هاتفك';

  @override
  String get pleaseEnterYourEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get enterValidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get invalidOtp => 'رمز غير صالح';

  @override
  String get enterPhoneNumberBelow =>
      'أدخل رقم هاتفك أدناه. سنرسل رمز تحقق للمتابعة في إعادة تعيين كلمة المرور';

  @override
  String get enterEmailBelow =>
      'أدخل عنوان بريدك الإلكتروني أدناه. سنرسل رابط إعادة تعيين كلمة المرور للمتابعة في إعادة تعيين كلمة المرور';

  @override
  String get passwordResetSent => 'تم إرسال رابط/رمز إعادة التعيين بنجاح!';

  @override
  String get failedToSendReset =>
      'فشل إرسال رابط/رمز إعادة التعيين. يرجى التحقق من المدخلات.';

  @override
  String welcomeBack(String name) {
    return 'مرحباً بعودتك، $name!';
  }

  @override
  String get invalidCredentials =>
      'بيانات اعتماد غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get verificationSuccessful => 'تم التحقق بنجاح! أنت الآن مسجل الدخول.';

  @override
  String get verificationSuccessfulManual =>
      'تم التحقق بنجاح! يرجى تسجيل الدخول يدوياً.';

  @override
  String get verificationSuccessfulContinue =>
      'تم التحقق بنجاح! يرجى تسجيل الدخول للمتابعة.';

  @override
  String get otpVerificationFailed => 'فشل التحقق من الرمز';

  @override
  String networkError(String error) {
    return 'خطأ في الشبكة: $error';
  }

  @override
  String get otpSentToPhone =>
      'تم إرسال الرمز إلى هاتفك. يرجى التحقق لإكمال التسجيل.';

  @override
  String get signupFailed => 'فشل التسجيل';

  @override
  String get pleaseAgreeToTerms =>
      'يرجى الموافقة على شروط الخدمة وسياسة الخصوصية للمتابعة';

  @override
  String get otpResendFunctionalityComingSoon =>
      'وظيفة إعادة إرسال الرمز قريباً';

  @override
  String get signUpAs => 'التسجيل كـ';

  @override
  String get user => 'مستخدم';

  @override
  String get realEstate => 'عقارات';

  @override
  String get serviceProvider => 'مقدم خدمة';

  @override
  String get signUpAsRealEstate => 'التسجيل كعقارات';

  @override
  String get signUpAsServiceProvider => 'التسجيل كمقدم خدمة';

  @override
  String get realEstateAgent => 'وكيل عقاري';

  @override
  String get realEstateCompany => 'شركة عقارات';

  @override
  String get individualServiceProvider => 'مقدم خدمة فردي';

  @override
  String get serviceProviderCompany => 'شركة مقدم خدمة';

  @override
  String get forFreelancersOrSelfEmployed =>
      'للمستقلين أو مقدمي الخدمات العاملين لحسابهم الخاص';

  @override
  String get forBusinessesWithTeam => 'للشركات التي لديها فريق أو مكتب مسجل';

  @override
  String get companyName => 'اسم الشركة';

  @override
  String get signInToChat => 'تسجيل الدخول للمحادثة';

  @override
  String get signInToChatDescription =>
      'يجب تسجيل الدخول للوصول إلى محادثاتك وبدء المحادثات.';

  @override
  String get unread => 'غير مقروء';

  @override
  String unreadCount(int count) {
    return '$count غير مقروء';
  }

  @override
  String get search => 'بحث...';

  @override
  String get searchJobs => 'بحث عن الوظائف...';

  @override
  String get searchServiceProviders => 'البحث عن مقدمي الخدمات...';

  @override
  String get seeBlockedContacts => 'عرض جهات الاتصال المحظورة';

  @override
  String get pleaseSignInToAccessChats =>
      'الرجاء تسجيل الدخول للوصول إلى محادثاتك';

  @override
  String errorLoadingChats(String error) {
    return 'خطأ في تحميل المحادثات: $error';
  }

  @override
  String get unknown => 'غير معروف';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get noChatsYet => 'لا توجد محادثات بعد';

  @override
  String get pleaseSignInToChat => 'الرجاء تسجيل الدخول للمحادثة';

  @override
  String get startConversation => 'ابدأ محادثة مع شخص ما';

  @override
  String get signInToAccessChatsDescription =>
      'سجل الدخول للوصول إلى محادثاتك وبدء المحادثات';

  @override
  String get justNow => 'الآن';

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String get blockUser => 'حظر المستخدم';

  @override
  String get blockUserConfirm =>
      'هل أنت متأكد أنك تريد حظر هذا المستخدم؟ لن تتمكن من إرسال أو استقبال الرسائل منه.';

  @override
  String get userBlockedSuccessfully => 'تم حظر المستخدم بنجاح';

  @override
  String errorBlockingUser(String error) {
    return 'خطأ في حظر المستخدم: $error';
  }

  @override
  String errorInitializingChat(String error) {
    return 'خطأ في تهيئة المحادثة: $error';
  }

  @override
  String errorSendingMessage(String error) {
    return 'خطأ في إرسال الرسالة: $error';
  }

  @override
  String errorDeletingMessage(String error) {
    return 'خطأ في حذف الرسالة: $error';
  }

  @override
  String get report => 'الإبلاغ';

  @override
  String get startConversationPrompt => 'ابدأ المحادثة!';

  @override
  String get typeAMessage => 'اكتب رسالة...';

  @override
  String get you => 'أنت';

  @override
  String errorLoadingBlockedUsers(String error) {
    return 'خطأ في تحميل المستخدمين المحظورين: $error';
  }

  @override
  String userUnblockedSuccessfully(String name) {
    return 'تم إلغاء حظر $name بنجاح';
  }

  @override
  String errorUnblockingUser(String error) {
    return 'خطأ في إلغاء حظر المستخدم: $error';
  }

  @override
  String get unblockUser => 'إلغاء حظر المستخدم';

  @override
  String unblockUserConfirm(String name) {
    return 'هل أنت متأكد أنك تريد إلغاء حظر $name؟ ستتمكن من إرسال واستقبال الرسائل منه مرة أخرى.';
  }

  @override
  String get blockedUsers => 'المستخدمون المحظورون';

  @override
  String get noBlockedUsers => 'لا يوجد مستخدمون محظورون';

  @override
  String get blockedUsersDescription => 'المستخدمون الذين تحظرهم سيظهرون هنا';

  @override
  String get reason => 'السبب:';

  @override
  String get blocked => 'محظور';

  @override
  String blockedAgo(String timeAgo) {
    return 'محظور $timeAgo';
  }

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String dayAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String daysAgoFull(int count) {
    return 'منذ $count أيام';
  }

  @override
  String hourAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String hoursAgoFull(int count) {
    return 'منذ $count ساعات';
  }

  @override
  String minuteAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String minutesAgoFull(int count) {
    return 'منذ $count دقائق';
  }

  @override
  String get pleaseSelectReasonForReporting => 'الرجاء اختيار سبب للإبلاغ';

  @override
  String errorSubmittingReport(String error) {
    return 'خطأ في إرسال البلاغ: $error';
  }

  @override
  String get reportMessage => 'الإبلاغ عن الرسالة';

  @override
  String reportMessagePrompt(String message) {
    return 'الإبلاغ عن الرسالة: \"$message\"';
  }

  @override
  String get selectReasonForReporting =>
      'الرجاء اختيار سبب للإبلاغ عن هذه الرسالة:';

  @override
  String get additionalDetailsOptional => 'تفاصيل إضافية (اختياري):';

  @override
  String get provideAdditionalInformation =>
      'قدم معلومات إضافية حول سبب إبلاغك عن هذه الرسالة...';

  @override
  String get submitReport => 'إرسال البلاغ';

  @override
  String get submit => 'إرسال';

  @override
  String get portfolio => 'المحفظة';

  @override
  String get portfolioPdf => 'ملف PDF للمحفظة';

  @override
  String get viewPortfolio => 'عرض المحفظة';

  @override
  String get updatePortfolio => 'تحديث المحفظة';

  @override
  String get addPortfolio => 'إضافة محفظة';

  @override
  String get addNewPdf => '+ إضافة ملف PDF جديد';

  @override
  String get deletePortfolio => 'حذف المحفظة';

  @override
  String get deletePortfolioConfirm =>
      'هل أنت متأكد أنك تريد حذف ملف PDF للمحفظة؟';

  @override
  String get portfolioUrlNotAvailable => 'رابط المحفظة غير متاح';

  @override
  String errorUploadingFile(String error) {
    return 'خطأ في رفع الملف: $error';
  }

  @override
  String errorSelectingFile(String error) {
    return 'خطأ في اختيار الملف: $error';
  }

  @override
  String couldNotOpenPdfBrowser(String url) {
    return 'تعذر فتح ملف PDF في المتصفح. الرابط: $url';
  }

  @override
  String get urlCopiedToClipboard => 'تم نسخ الرابط إلى الحافظة';

  @override
  String failedToCopyUrl(String error) {
    return 'فشل نسخ الرابط: $error';
  }

  @override
  String errorOpeningPdf(String error) {
    return 'خطأ في فتح ملف PDF: $error';
  }

  @override
  String get myJobs => 'وظائفي';

  @override
  String get noJobsPostedYet => 'لم يتم نشر أي وظائف بعد';

  @override
  String get contractType => 'نوع العقد:';

  @override
  String get experience => 'الخبرة:';

  @override
  String experienceYears(int min, int max) {
    return 'الخبرة: $min-$max سنوات';
  }

  @override
  String get postNewJob => 'نشر وظيفة جديدة';

  @override
  String get applications => 'الطلبات';

  @override
  String get noApplicationsYet => 'لا توجد طلبات بعد';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get newBadge => 'جديد';

  @override
  String get deleteJob => 'حذف الوظيفة';

  @override
  String deleteJobConfirm(String title) {
    return 'هل أنت متأكد أنك تريد حذف \"$title\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get jobDeletedSuccessfully => 'تم حذف الوظيفة بنجاح!';

  @override
  String errorDeletingJob(String error) {
    return 'خطأ في حذف الوظيفة: $error';
  }

  @override
  String get myServices => 'خدماتي';

  @override
  String get addService => 'إضافة خدمة';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get addYourFirstService => 'أضف خدمتك الأولى للبدء';

  @override
  String get deleteService => 'حذف الخدمة';

  @override
  String deleteServiceConfirm(String title) {
    return 'هل أنت متأكد أنك تريد حذف \"$title\"؟';
  }

  @override
  String get serviceDeletedSuccessfully => 'تم حذف الخدمة بنجاح';

  @override
  String get boostService => 'تعزيز الخدمة';

  @override
  String boostServiceConfirm(String title) {
    return 'تعزيز \"$title\" للحصول على المزيد من الرؤية؟';
  }

  @override
  String get activateListing => 'تفعيل القائمة';

  @override
  String get perMonth => '/ الشهر';

  @override
  String get addSocialAccountUrl => 'إضافة رابط حساب اجتماعي';

  @override
  String get exampleFacebook => 'مثال: Facebook';

  @override
  String get addSocialAccountUrlHint => 'إضافة رابط حساب اجتماعي';

  @override
  String get adding => 'جاري الإضافة...';

  @override
  String get pleaseFillAllFields => 'الرجاء ملء جميع الحقول';

  @override
  String get urlMustStartWithHttp =>
      'يجب أن يبدأ الرابط بـ http:// أو https://';

  @override
  String get socialLinkAddedSuccessfully => 'تم إضافة الرابط الاجتماعي بنجاح';

  @override
  String errorAddingSocialLink(String error) {
    return 'خطأ في إضافة الرابط الاجتماعي: $error';
  }

  @override
  String get deleteSocialLink => 'حذف الرابط الاجتماعي';

  @override
  String deleteSocialLinkConfirm(String linkName) {
    return 'هل أنت متأكد أنك تريد حذف \"$linkName\"؟';
  }

  @override
  String get socialLinkDeletedSuccessfully => 'تم حذف الرابط الاجتماعي بنجاح';

  @override
  String errorDeletingSocialLink(String error) {
    return 'خطأ في حذف الرابط الاجتماعي: $error';
  }

  @override
  String get openLink => 'فتح الرابط';

  @override
  String get deleteLink => 'حذف الرابط';

  @override
  String get listingsLabel => 'قوائم';

  @override
  String get daysLabel => 'أيام';

  @override
  String get idealForSmallAgencies =>
      'مثالي للوكالات الصغيرة ذات الاحتياجات المعتدلة';

  @override
  String get forHighVolumeProfessionals => 'للمهنيين والفرق عالية الحجم';

  @override
  String get basicPlan => 'أساسي';

  @override
  String get standardPlan => 'قياسي';

  @override
  String get unlimitedPlan => 'غير محدود';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get deleteButton => 'حذف';

  @override
  String get profileImageUpdatedSuccessfully =>
      'تم تحديث صورة الملف الشخصي بنجاح!';

  @override
  String errorUpdatingProfileImage(String error) {
    return 'خطأ في تحديث صورة الملف الشخصي: $error';
  }

  @override
  String get selectImageSource => 'اختر مصدر الصورة';

  @override
  String get chooseImageSource =>
      'اختر من أين تريد الحصول على صورة الملف الشخصي:';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get areYouSureLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountWarning => '⚠️ تحذير: هذا الإجراء غير قابل للعكس!';

  @override
  String get deletingAccountWillRemove => 'حذف حسابك سيحذف نهائياً:';

  @override
  String get allPersonalData => '• جميع بياناتك الشخصية';

  @override
  String get allListingsAndServices => '• جميع قوائمك وخدماتك';

  @override
  String get allMessagesAndChatHistory => '• جميع رسائلك وسجل المحادثات';

  @override
  String get allReviewsAndFavorites => '• جميع مراجعاتك والمفضلة';

  @override
  String get allSubscriptions => '• جميع اشتراكاتك';

  @override
  String get deleteAccountConfirmation =>
      'لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد تماماً أنك تريد حذف حسابك؟';

  @override
  String get deletingAccount => 'جاري حذف الحساب...';

  @override
  String errorDeletingAccount(String error) {
    return 'خطأ في حذف الحساب: $error';
  }

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get favorites => 'المفضلة';

  @override
  String get referrals => 'الإحالات';

  @override
  String get noUserDataAvailable => 'لا توجد بيانات المستخدم متاحة';

  @override
  String get enterYourPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get phoneNumberPlaceholder => '00 123 456';

  @override
  String get editEmailAndNumber => 'تعديل البريد الإلكتروني والرقم';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get reEnterPassword => 'أعد إدخال كلمة المرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changing => 'جاري التغيير...';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get newMessages => 'رسائل جديدة';

  @override
  String get listingApproval => 'موافقة القائمة';

  @override
  String get serviceRequests => 'طلبات الخدمة';

  @override
  String get promotions => 'العروض الترويجية';

  @override
  String get privacySettings => 'إعدادات الخصوصية';

  @override
  String get hideSocialLinks => 'إخفاء الروابط الاجتماعية';

  @override
  String get hideContactInfo => 'إخفاء معلومات الاتصال';

  @override
  String get profileDashboard => 'لوحة تحكم الملف الشخصي';

  @override
  String get helloProfileDashboard =>
      'مرحباً، هذه هي شاشة لوحة تحكم الملف الشخصي';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String itemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String get noFavoritesYet => 'لا توجد مفضلات بعد';

  @override
  String get favoritesDescription =>
      'العناصر التي تضيفها إلى المفضلة ستظهر هنا';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get failedToRemoveFavorite => 'فشل إزالة المفضلة';

  @override
  String get networkErrorOccurred => 'حدث خطأ في الشبكة';

  @override
  String get failedToLoadFavorites => 'فشل تحميل المفضلة';

  @override
  String showingXOfYItems(int current, int total) {
    return 'عرض $current من $total عنصر';
  }

  @override
  String get loadingMore => 'جاري تحميل المزيد...';

  @override
  String get referralsTitle => 'الإحالات';

  @override
  String get helloReferrals => 'مرحباً، هذه هي شاشة الإحالات';

  @override
  String get updateContactInformation =>
      'كيف أقوم بتحديث معلومات الاتصال الخاصة بي؟';

  @override
  String get resetPasswordAnswer =>
      'لإعادة تعيين كلمة المرور، انتقل إلى الملف الشخصي وانقر على \'إعادة تعيين كلمة المرور\'.';

  @override
  String get howToListNewService => 'كيف أقوم بإدراج خدمة جديدة؟';

  @override
  String get listNewServiceAnswer =>
      'أنشئ حساب مقدم خدمة، ثم ادخل إلى لوحة التحكم لإضافة خدمات جديدة.';

  @override
  String get canEditOrDeleteService => 'هل يمكنني تعديل أو حذف خدمة نشرتها؟';

  @override
  String get editOrDeleteServiceAnswer =>
      'يمكن تعديل الخدمات وحذفها من لوحة التحكم.';

  @override
  String get whatHappensAfterServiceRequest =>
      'ماذا يحدث بعد أن أتلقى طلب خدمة؟';

  @override
  String get viewRequestsAnswer => 'يمكنك عرض الطلبات في لوحة التحكم.';

  @override
  String get howDoIDeleteMyAccount => 'كيف أقوم بحذف حسابي؟';

  @override
  String get deleteAccountAnswer =>
      'خيار حذف الحساب موجود أسفل صفحة الملف الشخصي.';

  @override
  String get submitATicket => 'إرسال تذكرة';

  @override
  String get whatsYourIssueAbout => 'بخصوص ماذا مشكلتك؟';

  @override
  String get selectIssue => 'اختر المشكلة';

  @override
  String get paymentProblem => 'مشكلة دفع';

  @override
  String get technicalError => 'خطأ تقني';

  @override
  String get accountIssue => 'مشكلة في الحساب';

  @override
  String get describeYourIssueHere => 'اوصف مشكلتك هنا...';

  @override
  String get submitTicket => 'إرسال التذكرة';

  @override
  String get verifyPhoneNumber => 'التحقق من رقم الهاتف';

  @override
  String enter6DigitCode(String phoneNumber) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى\n$phoneNumber';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get verify => 'التحقق';

  @override
  String get noChangesDetected => 'لم يتم اكتشاف أي تغييرات';

  @override
  String get otpResentSuccessfully => 'تم إعادة إرسال رمز التحقق بنجاح';

  @override
  String errorRequestingOtp(String error) {
    return 'خطأ في طلب رمز التحقق: $error';
  }

  @override
  String errorVerifyingOtp(String error) {
    return 'خطأ في التحقق من رمز التحقق: $error';
  }

  @override
  String failedToUpdateSetting(String error) {
    return 'فشل تحديث الإعداد: $error';
  }

  @override
  String get myReviews => 'مراجعاتي';

  @override
  String totalReviews(int count) {
    return 'إجمالي المراجعات: $count';
  }

  @override
  String get errorLoadingReviews => 'خطأ في تحميل المراجعات';

  @override
  String get reviewsWillAppearHere => 'ستظهر المراجعات هنا عند استلامها.';

  @override
  String reviewsFor(String objectName) {
    return 'مراجعات $objectName';
  }

  @override
  String get failedToLoadReviews => 'فشل تحميل المراجعات';

  @override
  String beFirstToReview(String table) {
    return 'كن أول من يراجع هذا $table!';
  }

  @override
  String reviewCount(int count) {
    return '$count مراجعة';
  }

  @override
  String reviewCountPlural(int count) {
    return '$count مراجعة';
  }

  @override
  String get loadMoreReviews => 'تحميل المزيد من المراجعات';

  @override
  String get writeAReview => 'اكتب مراجعة';

  @override
  String get tapToRate => 'اضغط للتقييم';

  @override
  String star(int count) {
    return 'نجمة $count';
  }

  @override
  String stars(int count) {
    return '$count نجوم';
  }

  @override
  String get shareExperienceWithAgent => 'شارك تجربتك مع هذا الوكيل...';

  @override
  String get pleaseSelectRating => 'يرجى اختيار تقييم';

  @override
  String get pleaseLoginToSubmitReview => 'يرجى تسجيل الدخول لإرسال مراجعة';

  @override
  String get reviewSubmittedSuccessfully => 'تم إرسال المراجعة بنجاح!';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get pleaseLoginToAddListing => 'يرجى تسجيل الدخول لإضافة الإعلانات';

  @override
  String get alreadyReviewedAgent => 'لقد راجعت هذا الوكيل بالفعل';

  @override
  String get failedToSubmitReview => 'فشل إرسال المراجعة';

  @override
  String networkErrorReview(String error) {
    return 'خطأ في الشبكة: $error';
  }

  @override
  String get submitting => 'جاري الإرسال...';

  @override
  String get submitReview => 'إرسال المراجعة';

  @override
  String get reportReview => 'الإبلاغ عن المراجعة';

  @override
  String reportReviewBy(String reviewerName) {
    return 'الإبلاغ عن مراجعة من: $reviewerName';
  }

  @override
  String get selectReasonForReportingReview =>
      'يرجى اختيار سبب للإبلاغ عن هذه المراجعة:';

  @override
  String get additionalDetailsOptionalReview => 'تفاصيل إضافية (اختياري):';

  @override
  String get provideAdditionalInformationReview =>
      'قدم معلومات إضافية عن سبب الإبلاغ عن هذه المراجعة...';

  @override
  String get pleaseSelectReasonForReportingReview => 'يرجى اختيار سبب للإبلاغ';

  @override
  String errorSubmittingReviewReport(String error) {
    return 'خطأ في إرسال التقرير: $error';
  }

  @override
  String get reportThisReview => 'الإبلاغ عن هذه المراجعة';

  @override
  String get reviews => 'المراجعات';

  @override
  String seeAllReviews(int count) {
    return 'عرض جميع المراجعات $count';
  }

  @override
  String get noReviewsAvailable => 'لا توجد مراجعات متاحة';

  @override
  String get serviceProviderNoReviewsYet =>
      'لم يتلق مقدم الخدمة أي مراجعات حتى الآن';

  @override
  String get agentNoReviewsYet => 'لم يتلق الوكيل أي مراجعات حتى الآن';

  @override
  String get noListingsAvailable => 'لا توجد قوائم متاحة';

  @override
  String get agentNoListingsYet => 'لم ينشر الوكيل أي عقارات حتى الآن';

  @override
  String get reportThisJob => 'الإبلاغ عن هذه الوظيفة';

  @override
  String get reportThisJobTooltip => 'الإبلاغ عن هذه الوظيفة';

  @override
  String get jobDetails => 'تفاصيل الوظيفة';

  @override
  String get jobDescription => 'وصف الوظيفة';

  @override
  String get applyNow => 'قدم الآن';

  @override
  String get experienceRequired => 'الخبرة المطلوبة';

  @override
  String get skills => 'المهارات';

  @override
  String get workingHours => 'ساعات العمل';

  @override
  String get attendance => 'الحضور';

  @override
  String get jobType => 'نوع الوظيفة';

  @override
  String get applicationForm => 'نموذج الطلب';

  @override
  String get uploadPortfolioOptional => 'رفع المحفظة (اختياري)';

  @override
  String get expectedSalary => 'الراتب المتوقع';

  @override
  String get iConfirmInformationAccurate => 'أؤكد أن المعلومات المقدمة دقيقة';

  @override
  String get apply => 'تقديم';

  @override
  String get pleaseConfirmInformationAccurate =>
      'يرجى التأكد من أن المعلومات المقدمة دقيقة';

  @override
  String get signInRequired => 'تسجيل الدخول مطلوب';

  @override
  String get signInRequiredToApply =>
      'يجب أن تكون مسجلاً للدخول للتقديم على الوظائف. يرجى تسجيل الدخول والمحاولة مرة أخرى.';

  @override
  String get applicationSubmitted => 'تم تقديم الطلب';

  @override
  String get applicationSubmittedSuccessfully => 'تم تقديم طلبك بنجاح!';

  @override
  String get alreadyApplied => 'تم التقديم مسبقاً';

  @override
  String get alreadyAppliedToJob => 'لقد تقدمت لهذه الوظيفة بالفعل.';

  @override
  String get failedToSubmitApplication =>
      'فشل تقديم الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String errorPickingFile(String error) {
    return 'خطأ في اختيار الملف: $error';
  }

  @override
  String get reportJob => 'الإبلاغ عن الوظيفة';

  @override
  String reportJobTitle(String jobTitle) {
    return 'الإبلاغ عن: $jobTitle';
  }

  @override
  String get selectReasonForReportingJob =>
      'الرجاء اختيار سبب للإبلاغ عن هذه الوظيفة:';

  @override
  String get additionalDetailsAboutReportingJob =>
      'قدم معلومات إضافية حول سبب إبلاغك عن هذه الوظيفة...';

  @override
  String get benefits => 'المزايا';

  @override
  String get addNewBuilding => 'إضافة مبنى جديد';

  @override
  String get addNewLand => 'إضافة أرض جديدة';

  @override
  String get addNewProperty => 'إضافة عقار جديد';

  @override
  String get beforeYouList => 'قبل أن تبدأ بالإدراج';

  @override
  String get beforeYouListSubtitle =>
      'أخبرنا إن كنت مالك العقار أو وكيلاً يدراج بالنيابة عن شخص آخر.';

  @override
  String get iAm => 'أنا..';

  @override
  String get select => 'اختر';

  @override
  String get back => 'رجوع';

  @override
  String get listYourProperty => 'قم بإدراج عقارك';

  @override
  String get forRent => 'للإيجار';

  @override
  String get forSale => 'للبيع';

  @override
  String get listingType => 'نوع الإدراج';

  @override
  String get selectType => 'اختر النوع';

  @override
  String get rentalPeriod => 'فترة الإيجار';

  @override
  String get clear => 'مسح';

  @override
  String get editPropertyDetails => 'تعديل تفاصيل العقار';

  @override
  String get addPropertyDetails => 'إضافة تفاصيل العقار';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get propertyTitle => 'عنوان العقار';

  @override
  String get enterPropertyTitle => 'أدخل عنوان العقار';

  @override
  String get titleIsRequired => 'العنوان مطلوب';

  @override
  String get description => 'الوصف';

  @override
  String get describeYourProperty => 'صف عقارك';

  @override
  String get city => 'المدينة';

  @override
  String get enterCity => 'أدخل المدينة';

  @override
  String get cityIsRequired => 'المدينة مطلوبة';

  @override
  String get rentalPrice => 'سعر الإيجار';

  @override
  String get salePrice => 'سعر البيع';

  @override
  String get enterPrice => 'أدخل السعر';

  @override
  String get priceIsRequired => 'السعر مطلوب';

  @override
  String get bedrooms => 'غرف النوم';

  @override
  String get bathrooms => 'الحمامات';

  @override
  String get sizeSqFt => 'المساحة (متر²)';

  @override
  String get floor => 'الطابق';

  @override
  String get ground => 'أرضي';

  @override
  String get buildingAgeYears => 'عمر البناء (بالسنوات)';

  @override
  String get condition => 'الحالة';

  @override
  String get papers => 'الأوراق';

  @override
  String get propertyImages => 'صور العقار';

  @override
  String imagesCounter(int count) {
    return '$count/10 صور';
  }

  @override
  String get maxImagesReached => 'تم بلوغ الحد الأقصى للصور (10/10)';

  @override
  String get tapToAddImages => 'اضغط لإضافة صور';

  @override
  String get amenities => 'المرافق';

  @override
  String get updateListing => 'تحديث الإعلان';

  @override
  String get createListing => 'إنشاء الإعلان';

  @override
  String get listingUpdatedSuccessfully => 'تم تحديث الإعلان بنجاح!';

  @override
  String get failedToUpdateListing => 'فشل تحديث الإعلان. حاول مرة أخرى.';

  @override
  String get listingCreatedSuccessfully => 'تم إنشاء الإعلان بنجاح!';

  @override
  String get failedToCreateListing => 'فشل إنشاء الإعلان. حاول مرة أخرى.';

  @override
  String errorPickingImages(String error) {
    return 'خطأ في اختيار الصور: $error';
  }

  @override
  String genericError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get amenityFurnished => 'مفروشة';

  @override
  String get amenityTerrace => 'تراس';

  @override
  String get amenityPrivatePool => 'مسبح خاص';

  @override
  String get amenityStorageRoom => 'غرفة تخزين';

  @override
  String get amenitySharedPool => 'مسبح مشترك';

  @override
  String get amenitySharedGym => 'نادي رياضي مشترك';

  @override
  String get amenitySecurity => 'أمن';

  @override
  String get amenitySeaView => 'إطلالة على البحر';

  @override
  String get amenityGarden => 'حديقة';

  @override
  String get amenityMountainView => 'إطلالة على الجبل';

  @override
  String get amenityElevator => 'مصعد';

  @override
  String get amenityParking => 'موقف سيارات';

  @override
  String get amenityCentralAC => 'تكييف مركزي';

  @override
  String get amenityHeating => 'تدفئة';

  @override
  String get amenitySolarSystem => 'نظام طاقة شمسية';

  @override
  String get amenityElectricity247 => 'كهرباء 24/7';

  @override
  String get amenityMaidRoom => 'غرفة خادمة';

  @override
  String get conditionNew => 'جديد';

  @override
  String get conditionExcellent => 'ممتاز';

  @override
  String get conditionGood => 'جيد';

  @override
  String get conditionNeedsRenovation => 'يحتاج ترميم';

  @override
  String get conditionOld => 'قديم';

  @override
  String get papersTitleDeed => 'صك ملكية';

  @override
  String get papersRentalContract => 'عقد إيجار';

  @override
  String get papersUnderConstruction => 'تحت الإنشاء';

  @override
  String get papersOther => 'أخرى';

  @override
  String get propertyOwner => 'مالك العقار';

  @override
  String get propertyTypeApartment => 'شقة';

  @override
  String get propertyTypeChalet => 'شاليه';

  @override
  String get propertyTypeStudio => 'استوديو';

  @override
  String get propertyTypeCommercial => 'تجاري';

  @override
  String get propertyTypeVilla => 'فيلا';

  @override
  String get propertyTypeLand => 'أرض';

  @override
  String get rentalPeriodDaily => 'يومي';

  @override
  String get rentalPeriodMonthly => 'شهري';

  @override
  String get rentalPeriodYearly => 'سنوي';

  @override
  String get searchResultsTitle => 'نتائج البحث';

  @override
  String get searchPropertiesHint => 'ابحث عن العقارات...';

  @override
  String get searchAction => 'بحث';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String errorSearching(String error) {
    return 'خطأ في البحث: $error';
  }

  @override
  String searchTitleWithQuery(String query) {
    return 'بحث: $query';
  }

  @override
  String failedToLoadSearchResults(String error) {
    return 'فشل تحميل نتائج البحث: $error';
  }

  @override
  String get contactSupportTitle => 'اتصل بالدعم';

  @override
  String get needHelp => 'هل تحتاج مساعدة؟';

  @override
  String get weWillGetBackSoon => 'سنعاود الاتصال بك في أقرب وقت ممكن.';

  @override
  String get fillFormAndWeWillGetBack =>
      'املأ النموذج أدناه وسنعاود الاتصال بك.';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get emailAddressRequiredLabel => 'البريد الإلكتروني *';

  @override
  String get enterYourEmailAddress => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get emailIsRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get pleaseEnterValidEmailAddress =>
      'يرجى إدخال عنوان بريد إلكتروني صالح';

  @override
  String get phoneNumberRequiredLabel => 'رقم الهاتف *';

  @override
  String get enterYourPhoneNumberText => 'أدخل رقم هاتفك';

  @override
  String get phoneNumberIsRequired => 'رقم الهاتف مطلوب';

  @override
  String get message => 'الرسالة';

  @override
  String get describeIssueOrQuestionRequiredLabel => 'صف مشكلتك أو سؤالك *';

  @override
  String get describeIssueOrQuestionHint =>
      'يرجى تقديم أكبر قدر ممكن من التفاصيل حول مشكلتك أو سؤالك...';

  @override
  String get messageIsRequired => 'الرسالة مطلوبة';

  @override
  String get messageMinLength => 'يجب أن تكون الرسالة 10 أحرف على الأقل';

  @override
  String get messageMaxLength => 'يجب أن تكون الرسالة أقل من 5000 حرف';

  @override
  String get ticketSubmittedSuccessfully => 'تم إرسال التذكرة بنجاح';

  @override
  String get failedToSubmitTicket => 'فشل إرسال التذكرة';

  @override
  String errorOccurredWithDetails(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String emailLabelWithValue(String email) {
    return 'البريد الإلكتروني: $email';
  }

  @override
  String phoneLabelWithValue(String phone) {
    return 'الهاتف: $phone';
  }

  @override
  String get supportResponseNote =>
      'نرد عادة خلال 48 ساعة. للمشكلات العاجلة، يرجى الاتصال بخط الدعم. يمكنك إرسال تذكرة واحدة فقط يومياً.';
}
