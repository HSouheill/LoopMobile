import 'dart:convert';
import 'dart:io';
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
    File? imageFile,
    String? imageUrl,
    List<String>? skills,
    bool isFeatured = false,
  }) async {
    try {
      final url = Uri.parse(baseUrl);
      
      // If we have an image file, use multipart form data
      if (imageFile != null) {
        final request = http.MultipartRequest('POST', url);
        
        // Add authentication headers
        final authHeaders = AuthService.getAuthHeaders();
        request.headers.addAll(authHeaders);
        
        // Add text fields
        request.fields['title'] = title;
        request.fields['location'] = location;
        request.fields['jobType'] = jobType;
        request.fields['experienceRange'] = json.encode(experienceRange);
        request.fields['workingHours'] = workingHours;
        request.fields['attendance'] = attendance;
        request.fields['description'] = description;
        request.fields['isFeatured'] = isFeatured.toString();
        
        if (skills != null && skills.isNotEmpty) {
          request.fields['skills'] = json.encode(skills);
        }
        
        // Add the image file
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // This should match the field name expected by multer
            imageFile.path,
          ),
        );
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
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
      } else {
        // No image file, send as JSON
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
          try {
            final updatedJob = Job.fromJson(data['job']);
            return updatedJob;
          } catch (parseError) {
            throw Exception('Failed to parse updated job: $parseError');
          }
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

  // Search jobs
  static Future<JobsResponse> searchJobs({
    required String query,
    int page = 1,
    int limit = 20,
    String? location,
    String? jobType,
    int? minExperience,
    int? maxExperience,
    String? attendance,
    String? skills,
    DateTime? createdFrom,
    DateTime? createdTo,
    bool? isFeatured,
    String sort = 'score',
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        if (location != null) 'location': location,
        if (jobType != null) 'jobType': jobType,
        if (minExperience != null) 'minExperience': minExperience.toString(),
        if (maxExperience != null) 'maxExperience': maxExperience.toString(),
        if (attendance != null) 'attendance': attendance,
        if (skills != null) 'skills': skills,
        if (createdFrom != null) 'createdFrom': createdFrom.toIso8601String(),
        if (createdTo != null) 'createdTo': createdTo.toIso8601String(),
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
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
        throw Exception('Failed to search jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching jobs: $e');
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
      companyName: _parseCompanyName(json),
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      imageUrl: JobService.getImageUrl(json['imageUrl'] ?? ''),
      description: json['description'] ?? '',
      skills: _parseSkills(json['skills']),
      workingHours: json['workingHours'] ?? '',
      attendance: json['attendance'] ?? '',
      experienceRange: _parseExperienceRange(json['experienceRange']),
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  static String _parseCompanyName(Map<String, dynamic> json) {
    try {
      // First check if companyName is directly available
      if (json['companyName'] != null && json['companyName'] is String) {
        return json['companyName'];
      }
      
      // Then check if userId is an object with companyName
      if (json['userId'] != null && json['userId'] is Map) {
        final userId = json['userId'] as Map<String, dynamic>;
        if (userId['companyName'] != null) {
          return userId['companyName'].toString();
        }
      }
      
      return '';
    } catch (e) {
      return '';
    }
  }

  static List<String> _parseSkills(dynamic skills) {
    if (skills == null) return [];
    
    if (skills is List) {
      return skills.map((skill) => skill.toString()).toList();
    }
    
    if (skills is String) {
      return [skills];
    }
    
    return [];
  }

  static Map<String, int> _parseExperienceRange(dynamic experienceRange) {
    try {
      if (experienceRange == null) {
        return {'min': 0, 'max': 1};
      }
      
      // Handle if it's a List (e.g., [0, 5])
      if (experienceRange is List && experienceRange.length >= 2) {
        final min = experienceRange[0];
        final max = experienceRange[1];
        return {
          'min': min is int ? min : int.tryParse(min?.toString() ?? '0') ?? 0,
          'max': max is int ? max : int.tryParse(max?.toString() ?? '1') ?? 1,
        };
      }
      
      // Handle if it's a Map (e.g., {min: 0, max: 5})
      if (experienceRange is Map) {
        final min = experienceRange['min'];
        final max = experienceRange['max'];
        
        final result = {
          'min': min is int ? min : int.tryParse(min?.toString() ?? '0') ?? 0,
          'max': max is int ? max : int.tryParse(max?.toString() ?? '1') ?? 1,
        };
        
        return result;
      }
      
      return {'min': 0, 'max': 1};
    } catch (e) {
      return {'min': 0, 'max': 1};
    }
  }
}
