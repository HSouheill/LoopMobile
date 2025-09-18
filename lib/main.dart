import 'package:flutter/material.dart';
import 'app_header.dart';
import 'bottom_navbar.dart';
import 'widgets/under_construction.dart';
import 'services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'routes.dart';
import 'widgets/search_and_categories_widget.dart';
import 'widgets/image_slider_widget.dart';
import 'widgets/latest_updates_widget.dart';
import 'widgets/featured_listings_widget.dart';
import 'widgets/support_card_widget.dart';
import 'widgets/recommended_agents_widget.dart';
import 'screens/listings/listings.dart';
import 'screens/agents/agents.dart';
import 'screens/services/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
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
    AgentsPage(),
    ListingsPage(),
    HomePage(), // index 2 → center
    ServicesPage(),
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

  void _handleSubtitleTap() {
    if (_isLoggedIn) {
      Navigator.pushNamed(context, '/dashboard');
    } else {
      Navigator.pushNamed(context, '/preLogin').then((_) {
        _checkAuthStatus();
      });
    }
  }

  void _handleLogout() async {
    await AuthService.signOut();
    setState(() {
      _isLoggedIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  void _handleProfileNavigation() {
    Navigator.pushNamed(context, '/profile').then((result) {
      if (result == true) {
        setState(() {});
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

    final List<String> sliderImages = [
      'https://images.rawpixel.com/image_png_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvcHg2OTE4MDAtaW1hZ2UtMDVhLXJtNTA1XzEtbDA5YWp5c3UucG5n.png',
      'https://images.rawpixel.com/image_png_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvcHg1NjkzMjEtaW1hZ2VfMS1renAycXhwOC5wbmc.png',
    ];

    final List<MarketUpdate> marketUpdates = [
      MarketUpdate(
        title:
            'Real Estate CEO John Smith Unveils Bold Vision for the Future of Urban...',
        time: '1 Hour ago',
      ),
      MarketUpdate(
        title:
            'New report shows rising demand for sustainable housing in urban centers.',
        time: '3 Hours ago',
      ),
      MarketUpdate(
        title:
            'Local council approves new zoning laws for mixed-use developments.',
        time: 'Yesterday',
      ),
      MarketUpdate(
        title:
            'Property values in the city\'s downtown core see record growth.',
        time: '2 days ago',
      ),
    ];

    final List<PropertyListing> featuredProperties = [
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Modern Family House with Garden',
        price: '\$750,000/Month',
        agentName: 'Sarah Johnson',
        location: 'Beverly Hills, CA',
        isFeatured: true,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Modern Family House with Garden',
        price: '\$750,000/Month',
        agentName: 'Sarah Johnson',
        location: 'Beverly Hills, CA',
        isFeatured: true,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Luxury Downtown Penthouse',
        price: '\$1,250,000',
        agentName: 'Michael Chen',
        location: 'Manhattan, NY',
        isFeatured: true,
      ),
    ];

    // Data for the Recommended Agents widget
    final List<Agent> recommendedAgents = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'John Real Estate',
        propertyCount: 38,
        location: 'Hazmieh, Mount Lebanon',
        rating: 4.7,
        reviewCount: 128,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Jane Property Group',
        propertyCount: 52,
        location: 'Beirut, Lebanon',
        rating: 4.9,
        reviewCount: 210,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1043473/pexels-photo-1043473.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Elite Homes',
        propertyCount: 25,
        location: 'Jounieh, Mount Lebanon',
        rating: 4.6,
        reviewCount: 95,
      ),
    ];

    // Data for the Companies Services widget (uses customText instead of property count)
    final List<Agent> companiesServicesAgents = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Alpha Maintenance Co.',
        propertyCount: 0,
        location: 'Beirut, Lebanon',
        rating: 4.8,
        reviewCount: 152,
        customText: 'Electrical, plumbing',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3861964/pexels-photo-3861964.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'BrightClean Services',
        propertyCount: 0,
        location: 'Jounieh, Mount Lebanon',
        rating: 4.6,
        reviewCount: 89,
        customText: 'Deep Cleaning',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/7567843/pexels-photo-7567843.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'SecureGuard Systems',
        propertyCount: 0,
        location: 'Hazmieh, Mount Lebanon',
        rating: 4.7,
        reviewCount: 110,
        customText: 'CCTV',
      ),
    ];

    final List<Agent> individualServicesAgents = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3757941/pexels-photo-3757941.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Sam The Plumber',
        propertyCount: 0,
        location: 'Beirut, Lebanon',
        rating: 4.5,
        reviewCount: 42,
        customText: 'Plumbing, repairs',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1680143/pexels-photo-1680143.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Lina Painter',
        propertyCount: 0,
        location: 'Jounieh, Mount Lebanon',
        rating: 4.6,
        reviewCount: 37,
        customText: 'Interior painting',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3815587/pexels-photo-3815587.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Fadi Electric',
        propertyCount: 0,
        location: 'Hazmieh, Mount Lebanon',
        rating: 4.7,
        reviewCount: 58,
        customText: 'Electrical fixes',
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SearchAndCategoriesWidget(),
          const SizedBox(height: 10),
          ImageSliderWidget(imageUrls: sliderImages),
          const SizedBox(height: 10),
          LatestUpdatesWidget(updates: marketUpdates),
          const SizedBox(height: 10),
          FeaturedListingsWidget(
            title: 'Featured Listings',
            listings: featuredProperties,
          ),
          const SizedBox(height: 10),
          const SupportCardWidget(),
          const SizedBox(height: 10),

          // Call the new Recommended Agents widget here
          RecommendedAgentsWidget(
            title: 'Recommended Agents',
            agents: recommendedAgents,
          ),
          const SizedBox(height: 10),

          // Companies Services section using customText instead of property count
          RecommendedAgentsWidget(
            title: 'Companies Services',
            agents: companiesServicesAgents,
            showPropertyCount: false,
          ),
          const SizedBox(height: 10),

          // Individual Services section using customText instead of property count
          RecommendedAgentsWidget(
            title: 'Individual Services',
            agents: individualServicesAgents,
            showPropertyCount: false,
          ),
          const SizedBox(height: 10),

          // Welcome / sample section removed as requested
        ],
      ),
    );
  }
}
