import 'package:flutter/material.dart';
import '../screens/services/job_search_results_page.dart';

class JobSearchWidget extends StatefulWidget {
  const JobSearchWidget({super.key});

  @override
  State<JobSearchWidget> createState() => _JobSearchWidgetState();
}

class _JobSearchWidgetState extends State<JobSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobSearchResultsPage(searchQuery: query),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Bar (transparent, no borders, hint color matches icon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.transparent, // transparent background
              borderRadius: BorderRadius.circular(30.0),
              // removed boxShadow to eliminate borders/shadow
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color.fromARGB(255, 69, 100, 201)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Color.fromARGB(255, 69, 100, 201),
                    decoration: const InputDecoration(
                      hintText: 'Search jobs...',
                      // remove all borders
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      // keep background transparent
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      // placeholder color same as icon
                      hintStyle: TextStyle(color: Color.fromARGB(255, 69, 100, 201)),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Color.fromARGB(255, 69, 100, 201)),
                  onPressed: _performSearch,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          // Horizontal separator line
          Container(
            height: 1.0,
            color: Colors.green,
            margin: const EdgeInsets.symmetric(horizontal: 0.0),
          ),
        ],
      ),
    );
  }
}
