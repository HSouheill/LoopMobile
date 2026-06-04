import 'package:flutter/material.dart';
import '../search/city_selection_page.dart';

class JobAdvancedFiltersPage extends StatefulWidget {
  final String initialQuery;
  final Map<String, dynamic>? initialFilters;

  const JobAdvancedFiltersPage({
    super.key,
    required this.initialQuery,
    this.initialFilters,
  });

  @override
  State<JobAdvancedFiltersPage> createState() => _JobAdvancedFiltersPageState();
}

class _JobAdvancedFiltersPageState extends State<JobAdvancedFiltersPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Filter values
  String? _selectedLocation;
  String? _selectedJobType;
  int? _minExperience;
  int? _maxExperience;
  String? _selectedAttendance;
  String? _selectedSort;
  bool? _isFeatured;
  DateTime? _createdFrom;
  DateTime? _createdTo;

  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance'
  ];

  final List<String> _attendanceTypes = [
    'On site',
    'Online',
    'Hybrid',
    'Remote'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    
    // Initialize filters from initial values
    if (widget.initialFilters != null) {
      _selectedLocation = widget.initialFilters!['location']?.toString();
      _selectedJobType = widget.initialFilters!['jobType']?.toString();
      if (widget.initialFilters!['minExperience'] != null) {
        _minExperience = int.tryParse(widget.initialFilters!['minExperience'].toString());
      }
      if (widget.initialFilters!['maxExperience'] != null) {
        _maxExperience = int.tryParse(widget.initialFilters!['maxExperience'].toString());
      }
      _selectedAttendance = widget.initialFilters!['attendance']?.toString();
      _selectedSort = widget.initialFilters!['sort']?.toString();
      if (widget.initialFilters!['isFeatured'] != null) {
        _isFeatured = widget.initialFilters!['isFeatured'] == true || 
                     widget.initialFilters!['isFeatured'] == 'true';
      }
      if (widget.initialFilters!['skills'] != null) {
        final skills = widget.initialFilters!['skills'];
        if (skills is String) {
          _skillsController.text = skills;
        } else if (skills is List) {
          _skillsController.text = skills.join(', ');
        }
      }
      if (widget.initialFilters!['createdFrom'] != null) {
        final dateStr = widget.initialFilters!['createdFrom'].toString();
        _createdFrom = DateTime.tryParse(dateStr);
      }
      if (widget.initialFilters!['createdTo'] != null) {
        final dateStr = widget.initialFilters!['createdTo'].toString();
        _createdTo = DateTime.tryParse(dateStr);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedLocation = null;
      _selectedJobType = null;
      _minExperience = null;
      _maxExperience = null;
      _selectedAttendance = null;
      _selectedSort = null;
      _isFeatured = null;
      _createdFrom = null;
      _createdTo = null;
      _skillsController.clear();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim();

    final filters = <String, dynamic>{};
    
    if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
      filters['location'] = _selectedLocation;
    }
    if (_selectedJobType != null && _selectedJobType!.isNotEmpty) {
      filters['jobType'] = _selectedJobType;
    }
    if (_minExperience != null) {
      filters['minExperience'] = _minExperience;
    }
    if (_maxExperience != null) {
      filters['maxExperience'] = _maxExperience;
    }
    if (_selectedAttendance != null && _selectedAttendance!.isNotEmpty) {
      filters['attendance'] = _selectedAttendance;
    }
    if (_skillsController.text.trim().isNotEmpty) {
      filters['skills'] = _skillsController.text.trim();
    }
    if (_createdFrom != null) {
      filters['createdFrom'] = _createdFrom!.toIso8601String();
    }
    if (_createdTo != null) {
      filters['createdTo'] = _createdTo!.toIso8601String();
    }
    if (_isFeatured != null) {
      filters['isFeatured'] = _isFeatured;
    }
    if (_selectedSort != null && _selectedSort != 'score') {
      filters['sort'] = _selectedSort;
    }

    Navigator.pop(context, {
      'query': query,
      'filters': filters,
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_createdFrom ?? DateTime.now()) : (_createdTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _createdFrom = picked;
        } else {
          _createdTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Jobs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search
              _buildSectionTitle('Search'),
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Enter search terms...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24.0),

              // Location
              _buildSectionTitle('Location'),
              GestureDetector(
                onTap: () async {
                  final selectedLocation = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CitySelectionPage(
                        selectedCity: _selectedLocation,
                      ),
                    ),
                  );
                  if (selectedLocation != _selectedLocation) {
                    setState(() {
                      _selectedLocation = selectedLocation;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select location',
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _selectedLocation ?? 'All',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: _selectedLocation != null
                          ? Colors.black87
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Job Type
              _buildSectionTitle('Job Type'),
              DropdownButtonFormField<String>(
                value: _selectedJobType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select job type',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All'),
                  ),
                  ..._jobTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value;
                  });
                },
              ),
              const SizedBox(height: 24.0),

              // Experience Range
              _buildSectionTitle('Experience Range (years)'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        border: OutlineInputBorder(),
                        hintText: '0',
                      ),
                      initialValue: _minExperience?.toString(),
                      onChanged: (value) {
                        setState(() {
                          _minExperience = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max',
                        border: OutlineInputBorder(),
                        hintText: '10+',
                      ),
                      initialValue: _maxExperience?.toString(),
                      onChanged: (value) {
                        setState(() {
                          _maxExperience = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Attendance
              _buildSectionTitle('Attendance'),
              DropdownButtonFormField<String>(
                value: _selectedAttendance,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select attendance type',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All'),
                  ),
                  ..._attendanceTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAttendance = value;
                  });
                },
              ),
              const SizedBox(height: 24.0),

              // Skills
              _buildSectionTitle('Skills'),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  hintText: 'Enter skills (comma-separated)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 24.0),

              // Date Range
              _buildSectionTitle('Date Posted'),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'From',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _createdFrom != null
                              ? '${_createdFrom!.day}/${_createdFrom!.month}/${_createdFrom!.year}'
                              : 'All',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'To',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _createdTo != null
                              ? '${_createdTo!.day}/${_createdTo!.month}/${_createdTo!.year}'
                              : 'All',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Featured
              _buildSectionTitle('Featured'),
              Row(
                children: [
                  Expanded(
                    child: _buildBooleanButton(null, 'All'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildBooleanButton(true, 'Featured'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildBooleanButton(false, 'Not Featured'),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Sort Options
              _buildSectionTitle('Sort By'),
              DropdownButtonFormField<String>(
                value: _selectedSort ?? 'score',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'score',
                    child: Text('Relevance'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'date_desc',
                    child: Text('Newest First'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'date_asc',
                    child: Text('Oldest First'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'title_asc',
                    child: Text('Title A-Z'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'title_desc',
                    child: Text('Title Z-A'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'location_asc',
                    child: Text('Location A-Z'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'location_desc',
                    child: Text('Location Z-A'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'featured_first',
                    child: Text('Featured First'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value;
                  });
                },
              ),
              const SizedBox(height: 32.0),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _clearAllFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 103, 155, 218),
                              const Color.fromARGB(255, 69, 100, 201),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: _applyFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 103, 155, 218),
                              const Color.fromARGB(255, 69, 100, 201),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'Search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBooleanButton(bool? value, String label) {
    final isSelected = _isFeatured == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isFeatured = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 103, 155, 218),
              const Color.fromARGB(255, 69, 100, 201),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(138, 116, 116, 116),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

