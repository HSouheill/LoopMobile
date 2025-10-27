class JobApplication {
  final String id;
  final String jobId;
  final String applicantId;
  final String jobOwnerId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? portfolio;
  final String expectedSalary;
  final int experience;
  final String status;
  final String createdAt;
  
  // Populated fields
  final ApplicantInfo? applicant;
  final JobInfo? job;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.jobOwnerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.portfolio,
    required this.expectedSalary,
    required this.experience,
    required this.status,
    required this.createdAt,
    this.applicant,
    this.job,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['_id'] ?? '',
      jobId: json['jobId'] is String ? json['jobId'] : (json['jobId']?['_id'] ?? ''),
      applicantId: json['applicantId'] is String ? json['applicantId'] : (json['applicantId']?['_id'] ?? ''),
      jobOwnerId: json['jobOwnerId'] is String ? json['jobOwnerId'] : (json['jobOwnerId']?['_id'] ?? ''),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      portfolio: json['portfolio'],
      expectedSalary: json['expectedSalary'] ?? '',
      experience: json['experience'] is int ? json['experience'] : int.tryParse(json['experience']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
      applicant: json['applicantId'] is Map ? ApplicantInfo.fromJson(json['applicantId']) : null,
      job: json['jobId'] is Map ? JobInfo.fromJson(json['jobId']) : null,
    );
  }

  String get fullName => '$firstName $lastName';
}

class ApplicantInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? companyName;

  ApplicantInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.companyName,
  });

  factory ApplicantInfo.fromJson(Map<String, dynamic> json) {
    return ApplicantInfo(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      companyName: json['companyName'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class JobInfo {
  final String id;
  final String title;
  final String? location;
  final String? jobType;

  JobInfo({
    required this.id,
    required this.title,
    this.location,
    this.jobType,
  });

  factory JobInfo.fromJson(Map<String, dynamic> json) {
    return JobInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'],
      jobType: json['jobType'],
    );
  }
}

class JobApplicationsResponse {
  final List<JobApplication> applications;
  final JobApplicationMeta meta;

  JobApplicationsResponse({
    required this.applications,
    required this.meta,
  });

  factory JobApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return JobApplicationsResponse(
      applications: (json['applications'] as List?)
              ?.map((app) => JobApplication.fromJson(app))
              .toList() ??
          [],
      meta: JobApplicationMeta.fromJson(json['meta']),
    );
  }
}

class JobApplicationMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  JobApplicationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory JobApplicationMeta.fromJson(Map<String, dynamic> json) {
    return JobApplicationMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

