import 'package:flutter/material.dart';
import 'app_header.dart';
import 'bottom_navbar.dart';
import 'services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'routes.dart';
import 'widgets/search_and_categories_widget.dart';
import 'widgets/image_slider_widget.dart';
import 'widgets/latest_updates_widget.dart';
import 'widgets/listing_widgets/featured_listings_widget.dart';
import 'widgets/support_card_widget.dart';
import 'widgets/agent_widgets/featured_agents_widget.dart';
import 'widgets/dynamic_services_widget.dart';
import 'services/service_service.dart';
import 'screens/listings/listings.dart';
import 'screens/agents/agents.dart';
import 'screens/services/services.dart';
import 'screens/chat/chat.dart';
import 'screens/add_listing/widgets/add_listing_modal.dart';

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

// Custom FloatingActionButton location with adjustable vertical offset
class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double offsetFromBottom;

  _CustomFloatingActionButtonLocation(this.offsetFromBottom);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2;
    final double fabY = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height - offsetFromBottom;
    return Offset(fabX, fabY);
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
    ChatPage(),
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

  // Add this method to handle navigation from widgets
  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Method to show the modal when FAB is clicked
  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const AddListingModal();
      },
    );
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
    final headerSubtitle = _isLoggedIn 
        ? (user?.role == 'user' ? null : "Go to Dashboard")
        : "Login";

      return Scaffold(
      extendBody: true, // allow overlap with bottomNavigationBar
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

      // ---------- replace previous FloatingActionButton with this ----------
      floatingActionButton: Material(
        elevation: 6,
        color: const Color.fromARGB(255, 67, 91, 171),
        shape: const RoundedRectangleBorder(
          // top radius = half the width → perfect semicircle on top
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          onTap: _showAddModal,
          child: const SizedBox(
            width: 72,   // diameter
            height: 36,  // half the diameter → gives a top semicircle
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),

      // center it horizontally above the bottom bar with custom vertical offset
      floatingActionButtonLocation: _CustomFloatingActionButtonLocation(80), // Adjust the 60 value to move up/down
    );
  }
}

// Updated HomePage class in main.dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using AuthService directly where needed; no local vars required

    // Find the MainScreen to get the navigation callback
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();

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

    // Recommended Agents are now fetched dynamically via FeaturedAgentsWidget


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
          // Updated to use callback for navigation
          FeaturedListingsWidget(
            title: 'Featured Listings',
            isMainPage: true,
            onSeeAll: () => mainScreenState
                ?.navigateToTab(1), // Navigate to ListingsPage (index 1)
          ),
          const SizedBox(height: 10),
          const SupportCardWidget(),
          const SizedBox(height: 10),
          // Recommended Agents (featured, fetched from API, limited to 3 on main)
          FeaturedAgentsWidget(
            title: 'Recommended Agents',
            isMainPage: true,
            onSeeAll: () => mainScreenState?.navigateToTab(0),
          ),
          // Companies Services section - now fetched dynamically
          DynamicServicesWidget(
            category: ServiceCategory.companies,
            limit: 3,
            showSeeAll: true,
            onSeeAll: () => mainScreenState?.navigateToTab(3), // Navigate to ServicesPage (index 3)
          ),
          const SizedBox(height: 10),
          // Individual Services section - now fetched dynamically
          DynamicServicesWidget(
            category: ServiceCategory.individual,
            limit: 3,
            showSeeAll: true,
            onSeeAll: () => mainScreenState?.navigateToTab(3), // Navigate to ServicesPage (index 3)
          ),
          const SizedBox(height: 100), // Added extra bottom padding to prevent content from being hidden behind navbar
        ],
      ),
    );
  }
}
