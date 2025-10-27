class JobApplication {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? portfolio;
  final String expectedSalary;
  final int experience;
  final String status;
  final String createdAt;
  final String title; // Job title

  JobApplication({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.portfolio,
    required this.expectedSalary,
    required this.experience,
    required this.status,
    required this.createdAt,
    required this.title,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    // Extract title from populated jobId if available
    String title = '';
    if (json['jobId'] != null) {
      if (json['jobId'] is Map && json['jobId']['title'] != null) {
        title = json['jobId']['title'];
      } else {
        title = json['jobId'].toString();
      }
    }

    return JobApplication(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      portfolio: json['portfolio'],
      expectedSalary: json['expectedSalary'] ?? '',
      experience: json['experience'] is int ? json['experience'] : int.tryParse(json['experience']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
      title: title,
    );
  }

  String get fullName => '$firstName $lastName';
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

