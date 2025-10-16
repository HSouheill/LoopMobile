import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/job_detail.dart';
import 'auth_service.dart';

class JobService {
  static final String baseUrl = '${Environment.apiUrl}jobs';
  
  static Future<JobsResponse> getJobs({
    int page = 1,
    int limit = 3,
    bool? isFeatured,
    String? sort = 'date_desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
      };
      
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['jobs'] != null) {
          final jobs = (data['jobs'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
          final meta = JobMeta.fromJson(data['meta']);
          return JobsResponse(jobs: jobs, meta: meta);
        } else {
          throw Exception('No jobs found in response');
        }
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Get my jobs (for service provider company dashboard)
  static Future<JobsResponse> getMyJobs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      final uri = Uri.parse('${Environment.apiUrl}jobs/my-jobs').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['jobs'] != null) {
          final jobs = (data['jobs'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
          final meta = JobMeta.fromJson(data['meta']);
          return JobsResponse(jobs: jobs, meta: meta);
        } else {
          throw Exception('No jobs found in response');
        }
      } else {
        throw Exception('Failed to load my jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching my jobs: $e');
    }
  }
  
  static Future<JobDetail> getJobDetail(String jobId) async {
    try {
      final url = Uri.parse('$baseUrl/$jobId');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The job data is nested under 'job' key according to the API response
        if (data['job'] != null) {
          return JobDetail.fromJson(data['job']);
        } else {
          throw Exception('No job data found in response');
        }
      } else {
        throw Exception('Failed to load job detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job detail: $e');
    }
  }
  
  static String getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    return '${Environment.apiUrl}assets/$imageUrl';
  }

  // Create a new job
  static Future<Job> createJob({
    required String title,
    required String location,
    required String jobType,
    required Map<String, int> experienceRange,
    required String workingHours,
    required String attendance,
    required String description,
    String? imageUrl,
    List<String>? skills,
    bool isFeatured = false,
  }) async {
    try {
      final url = Uri.parse(baseUrl);
      final body = {
        'title': title,
        'location': location,
        'jobType': jobType,
        'experienceRange': experienceRange,
        'workingHours': workingHours,
        'attendance': attendance,
        'description': description,
        'isFeatured': isFeatured,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        if (skills != null && skills.isNotEmpty) 'skills': skills,
      };

      final response = await http.post(
        url,
        headers: {
          ...AuthService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['job'] != null) {
          return Job.fromJson(data['job']);
        } else {
          throw Exception('No job data found in response');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  // Update an existing job
  static Future<Job> updateJob({
    required String jobId,
    String? title,
    String? location,
    String? jobType,
    Map<String, int>? experienceRange,
    String? workingHours,
    String? attendance,
    String? description,
    String? imageUrl,
    List<String>? skills,
    bool? isFeatured,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$jobId');
      final body = <String, dynamic>{};
      
      if (title != null) body['title'] = title;
      if (location != null) body['location'] = location;
      if (jobType != null) body['jobType'] = jobType;
      if (experienceRange != null) body['experienceRange'] = experienceRange;
      if (workingHours != null) body['workingHours'] = workingHours;
      if (attendance != null) body['attendance'] = attendance;
      if (description != null) body['description'] = description;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (skills != null) body['skills'] = skills;
      if (isFeatured != null) body['isFeatured'] = isFeatured;

      final response = await http.put(
        url,
        headers: {
          ...AuthService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['job'] != null) {
          return Job.fromJson(data['job']);
        } else {
          throw Exception('No job data found in response');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating job: $e');
    }
  }

  // Delete a job
  static Future<bool> deleteJob(String jobId) async {
    try {
      final url = Uri.parse('$baseUrl/$jobId');
      final response = await http.delete(
        url,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting job: $e');
    }
  }
}

// Response class for jobs with pagination
class JobsResponse {
  final List<Job> jobs;
  final JobMeta meta;

  JobsResponse({
    required this.jobs,
    required this.meta,
  });
}

// Meta class for pagination
class JobMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  JobMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory JobMeta.fromJson(Map<String, dynamic> json) {
    return JobMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}

// Job model for the list view
class Job {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String jobType;
  final String imageUrl;
  final String description;
  final List<String> skills;
  final String workingHours;
  final String attendance;
  final Map<String, int> experienceRange;
  final bool isFeatured;
  final String createdAt;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.imageUrl,
    required this.description,
    required this.skills,
    required this.workingHours,
    required this.attendance,
    required this.experienceRange,
    required this.isFeatured,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? json['userId']?['companyName'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      imageUrl: JobService.getImageUrl(json['imageUrl'] ?? ''),
      description: json['description'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      workingHours: json['workingHours'] ?? '',
      attendance: json['attendance'] ?? '',
      experienceRange: _parseExperienceRange(json['experienceRange']),
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  static Map<String, int> _parseExperienceRange(dynamic experienceRange) {
    print('DEBUG: Parsing experienceRange: $experienceRange (type: ${experienceRange.runtimeType})');
    
    if (experienceRange == null) {
      print('DEBUG: experienceRange is null, returning defaults');
      return {'min': 0, 'max': 1};
    }
    
    if (experienceRange is Map) {
      final min = experienceRange['min'];
      final max = experienceRange['max'];
      
      print('DEBUG: min: $min (type: ${min.runtimeType}), max: $max (type: ${max.runtimeType})');
      
      final result = {
        'min': min is int ? min : int.tryParse(min?.toString() ?? '0') ?? 0,
        'max': max is int ? max : int.tryParse(max?.toString() ?? '1') ?? 1,
      };
      
      print('DEBUG: Parsed result: $result');
      return result;
    }
    
    print('DEBUG: experienceRange is not a Map, returning defaults');
    return {'min': 0, 'max': 1};
  }
}
