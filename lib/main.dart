import 'dart:async';
import 'package:flutter/material.dart';
import 'app_header.dart';
import 'bottom_navbar.dart';
import 'services/auth_service.dart';
import 'services/device_uuid_service.dart';
import 'services/chat_service.dart';
import 'services/socket_service.dart';
import 'services/location_service.dart';
import 'services/badge_service.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/image_slider_widget.dart';
import 'widgets/banner_placeholder_widget.dart';
import 'widgets/latest_updates_widget.dart';
import 'widgets/listing_widgets/featured_listings_widget.dart';
import 'widgets/support_card_widget.dart';
import 'widgets/dynamic_services_widget.dart';
import 'widgets/dynamic_jobs_widget.dart';
import 'widgets/dynamic_agents_widget.dart';
import 'services/service_service.dart';
import 'services/news_service.dart';
import 'services/banner_service.dart';
import 'screens/listings/listings.dart';
import 'screens/agents/agents.dart';
import 'screens/services/services.dart';
import 'screens/chat/chat.dart';
import 'screens/add_listing/widgets/add_listing_modal.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication first to ensure auth data is loaded
  await AuthService.loadAuthData();
  
  // Then initialize device UUID service
  await DeviceUuidService.initialize();
  
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

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('app_locale_code');
      if (savedCode != null && savedCode.isNotEmpty) {
        setState(() {
          _locale = Locale(savedCode);
        });
      }
    } catch (_) {
      // Ignore errors; default to English
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale_code', newLocale.languageCode);
    } catch (_) {
      // Ignore persistence errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navbar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue;
            }
            return null; // default when not selected
          }),
          checkColor: const MaterialStatePropertyAll(Colors.white),
          // no custom side so unchecked border stays default
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 66, 66, 66),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blue.withOpacity(0.3),
          selectionHandleColor: Colors.blue,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.blue,
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      routes: appRoutes(),
      home: const SplashScreen(),
    );
  }
}

// Custom FloatingActionButton location with adjustable vertical offset
class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final BuildContext context;
  
  _CustomFloatingActionButtonLocation(this.context);
  
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Get the actual safe area from MediaQuery
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    
    // Calculate the bottom navigation bar height
    // Your custom navbar height is 80.0
    final double bottomNavBarHeight = 80.0;

    // Calculate the FAB position to sit on top of the bottom navigation bar
    // We want the FAB to be positioned so its bottom edge aligns with the top of the bottom nav bar
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2;

    // Position the FAB so it sits on top of the navbar, accounting for safe area
    // Add 10 pixels to lower the button slightly
    final double fabY = scaffoldGeometry.scaffoldSize.height - bottomNavBarHeight - bottomSafeArea - scaffoldGeometry.floatingActionButtonSize.height + 10;
    
    return Offset(fabX, fabY);
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 2; // start at index 2
  bool _isLoading = true;
  bool _isLoggedIn = false;
  int _unreadChatCount = 0;
  String? _currentLocation; // Store detected location
  StreamSubscription? _messageSubscription;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _readSubscription;
  Timer? _unreadCountTimer;

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
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
    _setupSocketListeners();
    _startUnreadCountTimer();
    _detectCurrentLocation(); // Detect location on app launch
    _startLocationMonitoring(); // Start monitoring location changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _notificationSubscription?.cancel();
    _readSubscription?.cancel();
    _unreadCountTimer?.cancel();
    LocationService.stopLocationMonitoring(); // Stop location monitoring
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Update badge when app comes to foreground
    if (state == AppLifecycleState.resumed && _isLoggedIn) {
      _fetchUnreadCount();
    }
  }

  Future<void> _checkAuthStatus() async {
    // Auth data should already be loaded in main(), just check the current state
    final isAuthenticated = AuthService.isLoggedIn;
    setState(() {
      _isLoggedIn = isAuthenticated;
      _isLoading = false;
    });
    
    // Connect socket and fetch unread count if logged in
    if (isAuthenticated) {
      await _connectSocket();
      await _fetchUnreadCount();
    } else {
      // Clear badge if not logged in
      await BadgeService().clearBadge();
    }
  }

  Future<void> _connectSocket() async {
    final token = AuthService.token;
    final userId = AuthService.currentUser?.id;
    
    if (token != null && userId != null) {
      try {
        await SocketService.instance.connect(token, userId);
      } catch (e) {
        // Silently fail
      }
    }
  }

  void _setupSocketListeners() {
    // Listen to message events to update unread count
    _messageSubscription = SocketService.instance.messageStream.listen(
      (message) async {
        // When a new message arrives from another user, fetch updated count
        final currentUserId = AuthService.currentUser?.id;
        if (message.senderId != currentUserId) {
          await _fetchUnreadCount();
        }
      },
    );

    // Listen to notification events to update unread count
    _notificationSubscription = SocketService.instance.notificationStream.listen(
      (data) async {
        final unreadCount = data['unreadCount'] as int?;
        if (unreadCount != null) {
          setState(() {
            _unreadChatCount = unreadCount;
          });
          // Update app badge count
          await BadgeService().updateBadgeCount(unreadCount);
        }
      },
    );

    // Listen to read events to decrease unread count
    _readSubscription = SocketService.instance.readStream.listen(
      (data) async {
        final readBy = data['readBy'] as String?;
        final currentUserId = AuthService.currentUser?.id;
        // If current user read messages, fetch updated count
        if (readBy == currentUserId) {
          await _fetchUnreadCount();
        }
      },
    );
  }

  void _startUnreadCountTimer() {
    // Refresh unread count every 30 seconds
    _unreadCountTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isLoggedIn) {
        _fetchUnreadCount();
      }
    });
  }

  Future<void> _fetchUnreadCount() async {
    final token = AuthService.token;
    if (token != null && _isLoggedIn) {
      try {
        final count = await ChatService.getUnreadCount(token);
        if (mounted) {
          setState(() {
            _unreadChatCount = count;
          });
          // Update app badge count
          await BadgeService().updateBadgeCount(count);
        }
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Detect current location from device GPS
  /// This runs on app launch and refreshes the location
  Future<void> _detectCurrentLocation() async {
    try {
      // Try to get last known location first for faster display
      final lastKnown = await LocationService.getLastKnownCity();
      if (lastKnown != null && mounted) {
        setState(() {
          _currentLocation = lastKnown;
        });
      }

      // Then refresh with current location in background
      final cityName = await LocationService.refreshCurrentCity();
      if (cityName != null && mounted) {
        setState(() {
          _currentLocation = cityName;
        });
      }
    } catch (e) {
      // Silently fail - location is optional
    }
  }

  /// Start monitoring location changes
  /// Updates the header location automatically when the device moves
  Future<void> _startLocationMonitoring() async {
    try {
      await LocationService.startLocationMonitoring((String newCity) {
        if (mounted) {
          setState(() {
            _currentLocation = newCity;
          });
        }
      });
    } catch (e) {
      // Silently fail - location monitoring is optional
    }
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
    
    // Disconnect socket and reset unread count
    SocketService.instance.disconnect();
    
    // Clear app badge on logout
    await BadgeService().clearBadge();
    
    setState(() {
      _isLoggedIn = false;
      _unreadChatCount = 0;
    });
    
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.loggedOutSuccessfully ?? 'Logged out successfully')),
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
    if (!_isLoggedIn) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseLoginToAddListing ?? 'You need to be signed in to add listings'),
        ),
      );
      Navigator.pushNamed(context, '/preLogin').then((_) {
        _checkAuthStatus();
      });
      return;
    }

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

    final l10n = AppLocalizations.of(context);
    final user = AuthService.currentUser;
    final headerName = _isLoggedIn && user != null ? user.fullName : (l10n?.guest ?? 'Guest');
    
    // Priority: detected current location > user.city > user.location > empty
    // Always show real-time detected location if available, regardless of login status
    final headerLocation = _currentLocation ?? 
        (_isLoggedIn && user != null && user.city != null
            ? user.city!
            : (_isLoggedIn && user != null && user.location != null
                ? user.location!
                : ""));
    
    final headerSubtitle = _isLoggedIn 
        ? (user?.role == 'user' && !(user?.hasListing ?? false) 
            ? null 
            : (l10n?.goToDashboard ?? "Go to Dashboard"))
        : (l10n?.login ?? "Login");

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
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Refresh unread count when navigating to chat page
          if (i == 4 && _isLoggedIn) {
            _fetchUnreadCount();
          }
        },
        unreadChatCount: _unreadChatCount,
      ),

      // ---------- replace previous FloatingActionButton with this ----------
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 65, 105, 183),
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
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
      ),

      // center it horizontally above the bottom bar, positioned relative to navbar height
      floatingActionButtonLocation: _CustomFloatingActionButtonLocation(context),
    );
  }
}

// Helper function to format relative time
String _formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 7) {
    return '${difference.inDays ~/ 7} week${difference.inDays ~/ 7 > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

// Updated HomePage class in main.dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MarketUpdate> _marketUpdates = [];
  bool _isLoadingNews = true;
  List<String> _bannerImages = [];
  bool _isLoadingBanner = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _fetchBanner();
  }

  Future<void> _fetchBanner() async {
    try {
      final banner = await BannerService.getBanner(BannerService.homeScreen);
      if (mounted) {
        setState(() {
          _bannerImages = banner?.imageUrls ?? [];
          _isLoadingBanner = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bannerImages = [];
          _isLoadingBanner = false;
        });
      }
    }
  }

  Future<void> _fetchNews() async {
    try {
      final newsResponse = await NewsService.getNews();
      final marketUpdates = newsResponse.data.map((newsItem) {
        return MarketUpdate(
          title: newsItem.body,
          time: _formatRelativeTime(newsItem.createdAt),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _marketUpdates = marketUpdates;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      // If news fetch fails, use empty list or show error silently
      if (mounted) {
        setState(() {
          _marketUpdates = [];
          _isLoadingNews = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using AuthService directly where needed; no local vars required

    // Find the MainScreen to get the navigation callback
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();

    // Recommended Agents are now fetched dynamically via FeaturedAgentsWidget

    return CustomScrollView(
      slivers: [
        // Rest of the content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 1. Banner
              _isLoadingBanner
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _bannerImages.isNotEmpty
                      ? ImageSliderWidget(imageUrls: _bannerImages)
                      : const BannerPlaceholderWidget(),
              const SizedBox(height: 10),
              // 2. Featured Listings
              FeaturedListingsWidget(
                title: AppLocalizations.of(context)?.featuredListings ?? 'Featured Listings',
                isMainPage: true,
                onSeeAll: () => mainScreenState
                    ?.navigateToTab(1), // Navigate to ListingsPage (index 1)
              ),
              const SizedBox(height: 10),
              // 3. Featured Services
              DynamicServicesWidget(
                category: ServiceCategory.featured,
                limit: 3,
                showSeeAll: true,
                onSeeAll: () => mainScreenState?.navigateToTab(3), // Navigate to ServicesPage (index 3)
              ),
              const SizedBox(height: 10),
              // 4. Contact Support
              const SupportCardWidget(),
              const SizedBox(height: 10),
              // 5. Featured Real Estate (Agents)
              DynamicAgentsWidget(
                category: AgentCategory.featuredAll,
                customTitle: 'Featured Real Estate',
                limit: 3,
                onSeeAll: () => mainScreenState?.navigateToTab(0), // Navigate to AgentsPage (index 0)
              ),
              const SizedBox(height: 10),
              // 6. Featured Jobs
              DynamicJobsWidget(
                category: JobCategory.featured,
                limit: 3,
                onSeeAll: () => Navigator.pushNamed(context, '/jobs'),
              ),
              const SizedBox(height: 10),
              // 7. Banner copy (duplicate banner)
              _isLoadingBanner
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _bannerImages.isNotEmpty
                      ? ImageSliderWidget(imageUrls: _bannerImages)
                      : const BannerPlaceholderWidget(),
              const SizedBox(height: 10),
              // 8. Latest Market Updates
              _isLoadingNews
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _marketUpdates.isEmpty
                      ? const SizedBox.shrink()
                      : LatestUpdatesWidget(updates: _marketUpdates),
              const SizedBox(height: 100), // Bottom padding for navbar
            ],
          ),
        ),
      ],
    );
  }
}
