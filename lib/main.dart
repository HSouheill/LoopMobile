// File: lib/main.dart

import 'package:flutter/material.dart';
import 'app_header.dart';
import 'bottom_navbar.dart';
import 'under_construction.dart';
import 'services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // A static method to easily access the state from anywhere in the app
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default to English

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navbar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Add these for localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale, // Use the state variable
      routes: appRoutes(),
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
  int _currentIndex = 2; // start at index 2
  bool _isLoading = true;
  bool _isLoggedIn = false;

  final List<Widget> _pages = const [
    UnderConstructionPage(pageName: "Agents"),
    UnderConstructionPage(pageName: "Listings"),
    HomePage(), // index 2 → center
    UnderConstructionPage(pageName: "Services"),
    UnderConstructionPage(pageName: "Chat"),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await AuthService.checkAuthStatus();
    setState(() {
      _isLoggedIn = isAuthenticated;
      _isLoading = false;
    });
  }

  // Handle subtitle tap action in main page
  void _handleSubtitleTap() {
    if (_isLoggedIn) {
      // Navigate to dashboard or user profile
      Navigator.pushNamed(context, '/dashboard');
    } else {
      // Navigate to login
      Navigator.pushNamed(context, '/preLogin').then((_) {
        // Refresh auth status when returning from login
        _checkAuthStatus();
      });
    }
  }

  // Handle logout
  void _handleLogout() async {
    await AuthService.signOut();
    setState(() {
      _isLoggedIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  // Handle profile navigation with refresh
  void _handleProfileNavigation() {
    Navigator.pushNamed(context, '/profile').then((result) {
      // If result is true, it means we need to refresh the UI
      if (result == true) {
        setState(() {
          // This will trigger a rebuild of the header with updated user data
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get user data for header
    final user = AuthService.currentUser;
    final headerName = _isLoggedIn && user != null ? user.fullName : 'Guest';
    final headerLocation = _isLoggedIn && user != null && user.city != null 
        ? user.city! 
        : (_isLoggedIn && user != null && user.location != null 
            ? user.location!
            : "");
    final headerSubtitle = _isLoggedIn ? "Go to Dashboard" : "Login";

    return Scaffold(
      appBar: AppHeaderWithRefresh(
        name: headerName,
        location: headerLocation,
        subtitle: headerSubtitle,
        onSubtitleTap: _handleSubtitleTap,
        isLoggedIn: _isLoggedIn,
        onLogout: _isLoggedIn ? _handleLogout : null,
        onProfileTap: _isLoggedIn ? _handleProfileNavigation : null,
      ),
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
    final user = AuthService.currentUser;
    final isLoggedIn = AuthService.isLoggedIn;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            isLoggedIn ? 'Welcome back, ${user?.fullName ?? 'User'}!' : 'Welcome to the Homepage!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            isLoggedIn 
                ? 'Here are your personalized recommendations and updates.'
                : 'This is a template page to show how content can be structured.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber.shade700),
                title: Text('${isLoggedIn ? 'Personal' : 'Template'} Item ${index + 1}'),
                subtitle: Text(
                  isLoggedIn 
                      ? 'This is a personalized item for ${user?.fullName ?? 'you'}.'
                      : 'This is a description for the list item.'
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}