class JobDetail {
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
  final String userId;

  JobDetail({
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
    required this.userId,
  });

  factory JobDetail.fromJson(Map<String, dynamic> json) {
    return JobDetail(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? json['userId']?['companyName'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      workingHours: json['workingHours'] ?? '',
      attendance: json['attendance'] ?? '',
      experienceRange: _parseExperienceRange(json['experienceRange']),
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] ?? '',
      userId: json['userId']?['_id'] ?? json['userId'] ?? '',
    );
  }

  static Map<String, int> _parseExperienceRange(dynamic experienceRange) {
    print('DEBUG JobDetail: Parsing experienceRange: $experienceRange (type: ${experienceRange.runtimeType})');
    
    if (experienceRange == null) {
      print('DEBUG JobDetail: experienceRange is null, returning defaults');
      return {'min': 0, 'max': 1};
    }
    
    if (experienceRange is Map) {
      final min = experienceRange['min'];
      final max = experienceRange['max'];
      
      print('DEBUG JobDetail: min: $min (type: ${min.runtimeType}), max: $max (type: ${max.runtimeType})');
      
      final result = {
        'min': min is int ? min : int.tryParse(min?.toString() ?? '0') ?? 0,
        'max': max is int ? max : int.tryParse(max?.toString() ?? '1') ?? 1,
      };
      
      print('DEBUG JobDetail: Parsed result: $result');
      return result;
    }
    
    print('DEBUG JobDetail: experienceRange is not a Map, returning defaults');
    return {'min': 0, 'max': 1};
  }

  // Factory method to create a sample job detail
  factory JobDetail.sample() {
    return JobDetail(
      id: 'sample-id',
      title: 'Graphic Designer',
      companyName: 'Corpring Co',
      location: 'Hazmieh, Mount Lebanon',
      jobType: 'Full Time',
      imageUrl: 'https://images.pexels.com/photos/3184432/pexels-photo-3184432.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      description: "We're looking for a creative Graphic Designer with a strong portfolio in branding and digital media. You'll be responsible for designing marketing materials, collaborating with teams, and maintaining brand consistency across all visual communications. The ideal candidate will have experience in both print and digital design, with a keen eye for detail and the ability to work under tight deadlines.",
      skills: ['Adobe Photoshop', 'Illustrator', 'Figma'],
      workingHours: '9AM-5PM',
      attendance: 'Hybrid',
      experienceRange: {'min': 2, 'max': 4},
      isFeatured: true,
      createdAt: '2025-01-01T00:00:00.000Z',
      userId: 'sample-user-id',
    );
  }
}
