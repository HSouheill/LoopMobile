import 'package:flutter/material.dart';
import 'app_header.dart';
import 'bottom_navbar.dart';
import 'under_construction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navbar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // start at index 0

  final List<Widget> _pages = const [
  UnderConstructionPage(pageName: "Search"),
  UnderConstructionPage(pageName: "Notifications"),
  HomePage(), // index 2 → center
  UnderConstructionPage(pageName: "Profile"),
  UnderConstructionPage(pageName: "Settings"),
];

final List<String> _pageTitles = const [
  'Search',
  'Notifications',
  'Home',   // index 2
  'Profile',
  'Settings',
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: _pageTitles[_currentIndex]),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Welcome to the Homepage!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'This is a template page to show how content can be structured.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber.shade700),
                title: Text('Template Item ${index + 1}'),
                subtitle:
                    const Text('This is a description for the list item.'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
