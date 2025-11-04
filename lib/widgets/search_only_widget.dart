import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../screens/agents/agent_search_results_page.dart';

class SearchOnlyWidget extends StatefulWidget {
  const SearchOnlyWidget({super.key});

  @override
  State<SearchOnlyWidget> createState() => _SearchOnlyWidgetState();
}

class _SearchOnlyWidgetState extends State<SearchOnlyWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgentSearchResultsPage(searchQuery: query),
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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Color.fromARGB(255, 69, 100, 201),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.searchAgents ?? 'Search agents...',
                      // remove all borders
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      // keep background transparent
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      // placeholder color same as icon
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 69, 100, 201)),
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
