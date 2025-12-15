import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Text for a page that is under construction.
  ///
  /// In en, this message translates to:
  /// **'{pageName} Page is under construction 🚧'**
  String underConstructionPage(String pageName);

  /// No description provided for @agents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agents;

  /// No description provided for @realEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get realEstate;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Navbar App'**
  String get appTitle;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @featuredListings.
  ///
  /// In en, this message translates to:
  /// **'Featured Listings'**
  String get featuredListings;

  /// No description provided for @recommendedAgents.
  ///
  /// In en, this message translates to:
  /// **'Recommended Agents'**
  String get recommendedAgents;

  /// No description provided for @latestMarketUpdates.
  ///
  /// In en, this message translates to:
  /// **'Latest Market Updates'**
  String get latestMarketUpdates;

  /// No description provided for @supportCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Facing Legal Issues Or Other Concerns Related To Your Property? Our Expert Support Team Is Just A Message Away Ready To Assist You'**
  String get supportCardDescription;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @featuredServices.
  ///
  /// In en, this message translates to:
  /// **'Featured Services'**
  String get featuredServices;

  /// No description provided for @topRatedServices.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Services'**
  String get topRatedServices;

  /// No description provided for @companyServices.
  ///
  /// In en, this message translates to:
  /// **'Company Services'**
  String get companyServices;

  /// No description provided for @individualServices.
  ///
  /// In en, this message translates to:
  /// **'Individual Services'**
  String get individualServices;

  /// No description provided for @featuredCompanies.
  ///
  /// In en, this message translates to:
  /// **'Featured Companies'**
  String get featuredCompanies;

  /// No description provided for @topCompanies.
  ///
  /// In en, this message translates to:
  /// **'Top Companies'**
  String get topCompanies;

  /// No description provided for @failedToLoadFeaturedServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load featured service providers'**
  String get failedToLoadFeaturedServiceProviders;

  /// No description provided for @errorFetchingFeaturedServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Error fetching featured service providers'**
  String get errorFetchingFeaturedServiceProviders;

  /// No description provided for @failedToLoadTopRatedServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load top rated service providers'**
  String get failedToLoadTopRatedServiceProviders;

  /// No description provided for @errorFetchingTopRatedServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Error fetching top rated service providers'**
  String get errorFetchingTopRatedServiceProviders;

  /// No description provided for @failedToLoadServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load service providers'**
  String get failedToLoadServiceProviders;

  /// No description provided for @errorFetchingServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Error fetching service providers'**
  String get errorFetchingServiceProviders;

  /// No description provided for @noServiceProvidersFound.
  ///
  /// In en, this message translates to:
  /// **'No service providers found'**
  String get noServiceProvidersFound;

  /// No description provided for @failedToLoadServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Failed to load service provider'**
  String get failedToLoadServiceProvider;

  /// No description provided for @errorFetchingServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Error fetching service provider'**
  String get errorFetchingServiceProvider;

  /// No description provided for @noServiceProviderDataFound.
  ///
  /// In en, this message translates to:
  /// **'No service provider data found'**
  String get noServiceProviderDataFound;

  /// No description provided for @failedToLoadMyServices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load my services'**
  String get failedToLoadMyServices;

  /// No description provided for @errorFetchingMyServices.
  ///
  /// In en, this message translates to:
  /// **'Error fetching my services'**
  String get errorFetchingMyServices;

  /// No description provided for @failedToLoadAgentServices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load agent services'**
  String get failedToLoadAgentServices;

  /// No description provided for @errorFetchingAgentServices.
  ///
  /// In en, this message translates to:
  /// **'Error fetching agent services'**
  String get errorFetchingAgentServices;

  /// No description provided for @failedToCreateService.
  ///
  /// In en, this message translates to:
  /// **'Failed to create service'**
  String get failedToCreateService;

  /// No description provided for @pleaseEnterServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a service title'**
  String get pleaseEnterServiceTitle;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterValidPortfolioUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid portfolio URL'**
  String get pleaseEnterValidPortfolioUrl;

  /// No description provided for @pleaseCheckInputAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again'**
  String get pleaseCheckInputAndTryAgain;

  /// No description provided for @failedToCreateServiceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to create service. Please try again.'**
  String get failedToCreateServiceTryAgain;

  /// No description provided for @unableToConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server. Please check your internet connection and try again.'**
  String get unableToConnectToServer;

  /// No description provided for @failedToUpdateService.
  ///
  /// In en, this message translates to:
  /// **'Failed to update service'**
  String get failedToUpdateService;

  /// No description provided for @failedToUpdateServiceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to update service. Please try again.'**
  String get failedToUpdateServiceTryAgain;

  /// No description provided for @failedToDeleteService.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete service'**
  String get failedToDeleteService;

  /// No description provided for @failedToDeleteServiceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete service. Please try again.'**
  String get failedToDeleteServiceTryAgain;

  /// No description provided for @failedToSearchServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Failed to search service providers'**
  String get failedToSearchServiceProviders;

  /// No description provided for @errorSearchingServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Error searching service providers'**
  String get errorSearchingServiceProviders;

  /// Error message when failing to load a category of services
  ///
  /// In en, this message translates to:
  /// **'Failed to load {categoryName}'**
  String failedToLoadCategory(String categoryName);

  /// Message shown when no services found in a category
  ///
  /// In en, this message translates to:
  /// **'No {categoryName} found'**
  String noCategoryFound(String categoryName);

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @featuredJobs.
  ///
  /// In en, this message translates to:
  /// **'Featured Jobs'**
  String get featuredJobs;

  /// No description provided for @forYouJobs.
  ///
  /// In en, this message translates to:
  /// **'Job Vacancies'**
  String get forYouJobs;

  /// No description provided for @recentJobs.
  ///
  /// In en, this message translates to:
  /// **'Recent Jobs'**
  String get recentJobs;

  /// No description provided for @recommendedJobs.
  ///
  /// In en, this message translates to:
  /// **'Recommended Jobs'**
  String get recommendedJobs;

  /// No description provided for @failedToLoadJobs.
  ///
  /// In en, this message translates to:
  /// **'Failed to load jobs'**
  String get failedToLoadJobs;

  /// No description provided for @errorFetchingJobs.
  ///
  /// In en, this message translates to:
  /// **'Error fetching jobs'**
  String get errorFetchingJobs;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get noJobsFound;

  /// No description provided for @failedToLoadJobDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load job details'**
  String get failedToLoadJobDetails;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @ofText.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofText;

  /// No description provided for @exploreJobs.
  ///
  /// In en, this message translates to:
  /// **'Explore Jobs'**
  String get exploreJobs;

  /// Showing count and total for featured services
  ///
  /// In en, this message translates to:
  /// **'Showing {count} of {total} featured services'**
  String showingCountOfTotal(int count, int total);

  /// No description provided for @failedToLoadFeaturedServices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load featured services'**
  String get failedToLoadFeaturedServices;

  /// No description provided for @noFeaturedServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No featured services found'**
  String get noFeaturedServicesFound;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLess;

  /// No description provided for @noServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServicesAvailable;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get location;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company:'**
  String get company;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @reportServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Report this service provider'**
  String get reportServiceProvider;

  /// No description provided for @reportServiceProviderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Report this service provider'**
  String get reportServiceProviderTooltip;

  /// No description provided for @pleaseLoginToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Please log in to start a chat'**
  String get pleaseLoginToStartChat;

  /// No description provided for @failedToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat. Please try again.'**
  String get failedToStartChat;

  /// No description provided for @couldNotMakePhoneCall.
  ///
  /// In en, this message translates to:
  /// **'Could not make phone call'**
  String get couldNotMakePhoneCall;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @errorOpeningPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Error opening portfolio'**
  String get errorOpeningPortfolio;

  /// No description provided for @noPortfolioAvailable.
  ///
  /// In en, this message translates to:
  /// **'No portfolio available'**
  String get noPortfolioAvailable;

  /// No description provided for @noServiceProviderDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No service provider data available'**
  String get noServiceProviderDataAvailable;

  /// Description for service provider company
  ///
  /// In en, this message translates to:
  /// **'Professional {displayName} providing quality services in {city}, {country}.'**
  String professionalServiceProviderDescription(
    String displayName,
    String city,
    String country,
  );

  /// Description for individual service provider
  ///
  /// In en, this message translates to:
  /// **'{firstName} {lastName} is a professional service provider based in {city}, {country}.'**
  String individualServiceProviderDescription(
    String firstName,
    String lastName,
    String city,
    String country,
  );

  /// Search results title
  ///
  /// In en, this message translates to:
  /// **'Search: \"{query}\"'**
  String searchFor(String query);

  /// No description provided for @searchingServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Searching service providers...'**
  String get searchingServiceProviders;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// Title for agent services page
  ///
  /// In en, this message translates to:
  /// **'{agentName}\'s Services'**
  String agentServicesTitle(String agentName);

  /// Title for agent listings section
  ///
  /// In en, this message translates to:
  /// **'{firstName}\'s Listings'**
  String agentListingsTitle(String firstName);

  /// No description provided for @failedToLoadServices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load services'**
  String get failedToLoadServices;

  /// No description provided for @pleaseLoginToStartChatAgent.
  ///
  /// In en, this message translates to:
  /// **'Please log in to start a chat'**
  String get pleaseLoginToStartChatAgent;

  /// No description provided for @failedToStartChatAgent.
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat. Please try again.'**
  String get failedToStartChatAgent;

  /// No description provided for @couldNotMakePhoneCallAgent.
  ///
  /// In en, this message translates to:
  /// **'Could not make phone call'**
  String get couldNotMakePhoneCallAgent;

  /// Error message when opening a link
  ///
  /// In en, this message translates to:
  /// **'Error opening link: {error}'**
  String errorOpeningLinkAgent(String error);

  /// No description provided for @reportAgent.
  ///
  /// In en, this message translates to:
  /// **'Report this agent'**
  String get reportAgent;

  /// No description provided for @reportAgentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Report this agent'**
  String get reportAgentTooltip;

  /// No description provided for @aboutAgent.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutAgent;

  /// No description provided for @readMoreAgent.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMoreAgent;

  /// No description provided for @readLessAgent.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLessAgent;

  /// No description provided for @detailsAgent.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsAgent;

  /// No description provided for @emailAgent.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get emailAgent;

  /// No description provided for @serviceAreas.
  ///
  /// In en, this message translates to:
  /// **'Service Areas:'**
  String get serviceAreas;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @noProfileImage.
  ///
  /// In en, this message translates to:
  /// **'No profile image'**
  String get noProfileImage;

  /// No description provided for @failedToLoadAgentData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load agent data'**
  String get failedToLoadAgentData;

  /// No description provided for @noAgentDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No agent data available'**
  String get noAgentDataAvailable;

  /// Search results title for agents
  ///
  /// In en, this message translates to:
  /// **'Search Results for \"{query}\"'**
  String searchResultsFor(String query);

  /// Found agents count message
  ///
  /// In en, this message translates to:
  /// **'Found {count} agents for \"{query}\"'**
  String foundAgentsFor(int count, String query);

  /// No description provided for @searchingAgents.
  ///
  /// In en, this message translates to:
  /// **'Searching agents...'**
  String get searchingAgents;

  /// No description provided for @errorSearchingAgents.
  ///
  /// In en, this message translates to:
  /// **'Error searching agents'**
  String get errorSearchingAgents;

  /// No description provided for @noAgentsFound.
  ///
  /// In en, this message translates to:
  /// **'No agents found'**
  String get noAgentsFound;

  /// No description provided for @tryDifferentKeywordsAgent.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywordsAgent;

  /// No description provided for @featuredAgents.
  ///
  /// In en, this message translates to:
  /// **'Featured Agents'**
  String get featuredAgents;

  /// No description provided for @topRatedAgents.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Agents'**
  String get topRatedAgents;

  /// No description provided for @recommendedAgentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Agents'**
  String get recommendedAgentsTitle;

  /// Error message when failing to load agents by category
  ///
  /// In en, this message translates to:
  /// **'Failed to load {categoryName}'**
  String failedToLoadAgents(String categoryName);

  /// No description provided for @noAgentsFoundCategory.
  ///
  /// In en, this message translates to:
  /// **'No agents found'**
  String get noAgentsFoundCategory;

  /// No description provided for @agentDashboard.
  ///
  /// In en, this message translates to:
  /// **'Agent Dashboard'**
  String get agentDashboard;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @totalListings.
  ///
  /// In en, this message translates to:
  /// **'Total Listings:'**
  String get totalListings;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile Views:'**
  String get profileViews;

  /// No description provided for @activeListings.
  ///
  /// In en, this message translates to:
  /// **'Active Listings:'**
  String get activeListings;

  /// No description provided for @totalChats.
  ///
  /// In en, this message translates to:
  /// **'Total Chats:'**
  String get totalChats;

  /// No description provided for @addNewListing.
  ///
  /// In en, this message translates to:
  /// **'Add New Listing'**
  String get addNewListing;

  /// No description provided for @inactiveListings.
  ///
  /// In en, this message translates to:
  /// **'Inactive Listings'**
  String get inactiveListings;

  /// No description provided for @noInactiveListings.
  ///
  /// In en, this message translates to:
  /// **'No inactive listings'**
  String get noInactiveListings;

  /// No description provided for @listingsLeft.
  ///
  /// In en, this message translates to:
  /// **'Listings Left'**
  String get listingsLeft;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @noActiveListings.
  ///
  /// In en, this message translates to:
  /// **'No active listings'**
  String get noActiveListings;

  /// No description provided for @ratingAndReviews.
  ///
  /// In en, this message translates to:
  /// **'Rating & Reviews'**
  String get ratingAndReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @plansAndSubscription.
  ///
  /// In en, this message translates to:
  /// **'Plans & Subscription'**
  String get plansAndSubscription;

  /// No description provided for @currentSubscription.
  ///
  /// In en, this message translates to:
  /// **'Current Subscription'**
  String get currentSubscription;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListing;

  /// Delete listing confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteListingConfirm(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @listingDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted successfully'**
  String get listingDeletedSuccessfully;

  /// No description provided for @failedToDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete listing'**
  String get failedToDeleteListing;

  /// Error message when deleting listing
  ///
  /// In en, this message translates to:
  /// **'Error deleting listing: {error}'**
  String errorDeletingListing(String error);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @soldFunctionalityNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Sold functionality not implemented yet'**
  String get soldFunctionalityNotImplemented;

  /// No description provided for @boostFunctionalityNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Boost functionality not implemented yet'**
  String get boostFunctionalityNotImplemented;

  /// Greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String hiUser(String name);

  /// No description provided for @activePlan.
  ///
  /// In en, this message translates to:
  /// **'Active Plan:'**
  String get activePlan;

  /// Valid until date
  ///
  /// In en, this message translates to:
  /// **'Valid Until: {date}'**
  String validUntil(String date);

  /// No description provided for @noPlan.
  ///
  /// In en, this message translates to:
  /// **'No Plan'**
  String get noPlan;

  /// No description provided for @myAgents.
  ///
  /// In en, this message translates to:
  /// **'My Agents'**
  String get myAgents;

  /// Total agents count
  ///
  /// In en, this message translates to:
  /// **'Total Agents: {count}'**
  String totalAgents(int count);

  /// Page number display
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(int current, int total);

  /// No description provided for @noAgentsFoundMy.
  ///
  /// In en, this message translates to:
  /// **'No agents found'**
  String get noAgentsFoundMy;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// Joined date
  ///
  /// In en, this message translates to:
  /// **'Joined: {date}'**
  String joined(String date);

  /// Error loading agents message
  ///
  /// In en, this message translates to:
  /// **'Error loading agents: {error}'**
  String errorLoadingAgents(String error);

  /// No description provided for @billingHistory.
  ///
  /// In en, this message translates to:
  /// **'Billing History'**
  String get billingHistory;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @searchAgents.
  ///
  /// In en, this message translates to:
  /// **'Search agents...'**
  String get searchAgents;

  /// No description provided for @topAgents.
  ///
  /// In en, this message translates to:
  /// **'Top Agents'**
  String get topAgents;

  /// No description provided for @forYouAgents.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get forYouAgents;

  /// Error message when failing to load agents in widget
  ///
  /// In en, this message translates to:
  /// **'Failed to load agents: {error}'**
  String failedToLoadAgentsWidget(String error);

  /// Property count text
  ///
  /// In en, this message translates to:
  /// **'{count} Properties'**
  String properties(int count);

  /// Error message when failing to load listings by category
  ///
  /// In en, this message translates to:
  /// **'Failed to load {categoryName}: {error}'**
  String failedToLoadListingsCategory(String categoryName, String error);

  /// No description provided for @noListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get noListingsFound;

  /// No description provided for @featuredLabel.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredLabel;

  /// Showing count and total for featured listings
  ///
  /// In en, this message translates to:
  /// **'Showing {count} of {total} featured listings'**
  String showingFeaturedListings(int count, int total);

  /// No description provided for @failedToLoadFeaturedListings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load featured listings'**
  String get failedToLoadFeaturedListings;

  /// No description provided for @noFeaturedListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No featured listings found'**
  String get noFeaturedListingsFound;

  /// Error loading listings message
  ///
  /// In en, this message translates to:
  /// **'Error loading listings: {error}'**
  String errorLoadingListings(String error);

  /// No description provided for @activateFunctionalityNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Activate functionality not implemented yet'**
  String get activateFunctionalityNotImplemented;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @soldButton.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get soldButton;

  /// No description provided for @boostButton.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get boostButton;

  /// No description provided for @promoteButton.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promoteButton;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report this listing'**
  String get reportListing;

  /// No description provided for @phoneNumberNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNumberNotAvailable;

  /// No description provided for @couldNotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get couldNotOpenWhatsApp;

  /// Error message when opening WhatsApp
  ///
  /// In en, this message translates to:
  /// **'Error opening WhatsApp: {error}'**
  String errorOpeningWhatsApp(String error);

  /// No description provided for @dateNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Date not available'**
  String get dateNotAvailable;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// No description provided for @amenitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenitiesLabel;

  /// No description provided for @relatedListings.
  ///
  /// In en, this message translates to:
  /// **'Related Listings'**
  String get relatedListings;

  /// No description provided for @propertyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Code:'**
  String get propertyCodeLabel;

  /// No description provided for @listedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Listed Date:'**
  String get listedDateLabel;

  /// No description provided for @propertyCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Property code copied to clipboard'**
  String get propertyCodeCopied;

  /// No description provided for @callButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// No description provided for @whatsAppButton.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsAppButton;

  /// Property size label
  ///
  /// In en, this message translates to:
  /// **'Size: {size} sqm'**
  String sizeLabel(String size);

  /// Bedrooms and bathrooms count
  ///
  /// In en, this message translates to:
  /// **'{bedrooms} Bedrooms, {bathrooms} Bathrooms'**
  String bedroomsBathrooms(String bedrooms, String bathrooms);

  /// Bedrooms count only
  ///
  /// In en, this message translates to:
  /// **'{bedrooms} Bedrooms'**
  String bedroomsOnly(String bedrooms);

  /// Bathrooms count only
  ///
  /// In en, this message translates to:
  /// **'{bathrooms} Bathrooms'**
  String bathroomsOnly(String bathrooms);

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get typeLabel;

  /// No description provided for @floorLabel.
  ///
  /// In en, this message translates to:
  /// **'Floor:'**
  String get floorLabel;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition:'**
  String get conditionLabel;

  /// Building age label
  ///
  /// In en, this message translates to:
  /// **'Building Age: {age} years'**
  String buildingAgeLabel(String age);

  /// No description provided for @papersLabel.
  ///
  /// In en, this message translates to:
  /// **'Papers:'**
  String get papersLabel;

  /// No description provided for @availableForLabel.
  ///
  /// In en, this message translates to:
  /// **'Available for:'**
  String get availableForLabel;

  /// Available from date label
  ///
  /// In en, this message translates to:
  /// **'Available from: {date}'**
  String availableFromLabel(String date);

  /// No description provided for @newListings.
  ///
  /// In en, this message translates to:
  /// **'New Listings'**
  String get newListings;

  /// No description provided for @apartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get apartments;

  /// No description provided for @chalets.
  ///
  /// In en, this message translates to:
  /// **'Chalets'**
  String get chalets;

  /// No description provided for @villas.
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get villas;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get land;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercial;

  /// No description provided for @bedText.
  ///
  /// In en, this message translates to:
  /// **'bed'**
  String get bedText;

  /// No description provided for @bathText.
  ///
  /// In en, this message translates to:
  /// **'bath'**
  String get bathText;

  /// Message when no listings found in category
  ///
  /// In en, this message translates to:
  /// **'No {categoryName} found'**
  String noCategoryListingsFound(String categoryName);

  /// Page indicator in format current/total
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String pageCurrentOfTotal(int current, int total);

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @usingEmail.
  ///
  /// In en, this message translates to:
  /// **'Using Email'**
  String get usingEmail;

  /// No description provided for @usingPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Using Phone Number'**
  String get usingPhoneNumber;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// No description provided for @dontHaveAnAccountFull.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Have an account? '**
  String get dontHaveAnAccountFull;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpButton;

  /// No description provided for @logInWithEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Log in with Email Address'**
  String get logInWithEmailAddress;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @verifyByEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify By Email'**
  String get verifyByEmail;

  /// No description provided for @verifyByPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify By Phone'**
  String get verifyByPhone;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// OTP verification instruction
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your phone number {phone}'**
  String enterOtpSentToPhone(String phone);

  /// No description provided for @didntReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP? '**
  String get didntReceiveOtp;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @completeSignup.
  ///
  /// In en, this message translates to:
  /// **'Complete Signup'**
  String get completeSignup;

  /// No description provided for @liveLocation.
  ///
  /// In en, this message translates to:
  /// **'Live Location'**
  String get liveLocation;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @minimum6Characters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minimum6Characters;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone'**
  String get invalidPhone;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtp;

  /// No description provided for @enterPhoneNumberBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number below. We\'ll send a verification code to proceed with resetting your password'**
  String get enterPhoneNumberBelow;

  /// No description provided for @enterEmailBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address below. We\'ll send a password reset link to proceed with resetting your password'**
  String get enterEmailBelow;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link/code sent successfully!'**
  String get passwordResetSent;

  /// No description provided for @failedToSendReset.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link/code. Please check your input.'**
  String get failedToSendReset;

  /// Welcome message after login
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeBack(String name);

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification successful! You are now signed in.'**
  String get verificationSuccessful;

  /// No description provided for @verificationSuccessfulManual.
  ///
  /// In en, this message translates to:
  /// **'Verification successful! Please sign in manually.'**
  String get verificationSuccessfulManual;

  /// No description provided for @verificationSuccessfulContinue.
  ///
  /// In en, this message translates to:
  /// **'Verification successful! Please sign in to continue.'**
  String get verificationSuccessfulContinue;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed'**
  String get otpVerificationFailed;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error: {error}'**
  String networkError(String error);

  /// No description provided for @otpSentToPhone.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your phone. Please verify to complete signup.'**
  String get otpSentToPhone;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailed;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service and Privacy Policy to continue'**
  String get pleaseAgreeToTerms;

  /// No description provided for @otpResendFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'OTP resend functionality coming soon'**
  String get otpResendFunctionalityComingSoon;

  /// No description provided for @signUpAs.
  ///
  /// In en, this message translates to:
  /// **'Sign up as'**
  String get signUpAs;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @serviceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProvider;

  /// No description provided for @signUpAsRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Sign Up as Real Estate'**
  String get signUpAsRealEstate;

  /// No description provided for @signUpAsServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Sign Up as Service Provider'**
  String get signUpAsServiceProvider;

  /// No description provided for @realEstateAgent.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Agent'**
  String get realEstateAgent;

  /// No description provided for @realEstateCompany.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Company'**
  String get realEstateCompany;

  /// No description provided for @individualServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Individual Service Provider'**
  String get individualServiceProvider;

  /// No description provided for @serviceProviderCompany.
  ///
  /// In en, this message translates to:
  /// **'Service Provider Company'**
  String get serviceProviderCompany;

  /// No description provided for @forFreelancersOrSelfEmployed.
  ///
  /// In en, this message translates to:
  /// **'For Freelancers or Self-employed Providers'**
  String get forFreelancersOrSelfEmployed;

  /// No description provided for @forBusinessesWithTeam.
  ///
  /// In en, this message translates to:
  /// **'For Businesses with a team or registered office'**
  String get forBusinessesWithTeam;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @signInToChat.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Chat'**
  String get signInToChat;

  /// No description provided for @signInToChatDescription.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to access your chats and start conversations.'**
  String get signInToChatDescription;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Unread message count
  ///
  /// In en, this message translates to:
  /// **'Unread {count}'**
  String unreadCount(int count);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @searchJobs.
  ///
  /// In en, this message translates to:
  /// **'Search jobs...'**
  String get searchJobs;

  /// No description provided for @searchServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Search service providers...'**
  String get searchServiceProviders;

  /// No description provided for @seeBlockedContacts.
  ///
  /// In en, this message translates to:
  /// **'See Blocked Contacts'**
  String get seeBlockedContacts;

  /// No description provided for @pleaseSignInToAccessChats.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to access your chats'**
  String get pleaseSignInToAccessChats;

  /// Error loading chats message
  ///
  /// In en, this message translates to:
  /// **'Error loading chats: {error}'**
  String errorLoadingChats(String error);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @pleaseSignInToChat.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to chat'**
  String get pleaseSignInToChat;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with someone'**
  String get startConversation;

  /// No description provided for @signInToAccessChatsDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your chats and start conversations'**
  String get signInToAccessChatsDescription;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Days ago format
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// Hours ago format
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// Minutes ago format
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @blockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user? You won\'t be able to send or receive messages from them.'**
  String get blockUserConfirm;

  /// No description provided for @userBlockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get userBlockedSuccessfully;

  /// Error blocking user message
  ///
  /// In en, this message translates to:
  /// **'Error blocking user: {error}'**
  String errorBlockingUser(String error);

  /// Error initializing chat message
  ///
  /// In en, this message translates to:
  /// **'Error initializing chat: {error}'**
  String errorInitializingChat(String error);

  /// Error sending message
  ///
  /// In en, this message translates to:
  /// **'Error sending message: {error}'**
  String errorSendingMessage(String error);

  /// Error deleting message
  ///
  /// In en, this message translates to:
  /// **'Error deleting message: {error}'**
  String errorDeletingMessage(String error);

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @startConversationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startConversationPrompt;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Error loading blocked users message
  ///
  /// In en, this message translates to:
  /// **'Error loading blocked users: {error}'**
  String errorLoadingBlockedUsers(String error);

  /// User unblocked successfully message
  ///
  /// In en, this message translates to:
  /// **'{name} unblocked successfully'**
  String userUnblockedSuccessfully(String name);

  /// Error unblocking user message
  ///
  /// In en, this message translates to:
  /// **'Error unblocking user: {error}'**
  String errorUnblockingUser(String error);

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// Unblock user confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock {name}? You will be able to send and receive messages from them again.'**
  String unblockUserConfirm(String name);

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get noBlockedUsers;

  /// No description provided for @blockedUsersDescription.
  ///
  /// In en, this message translates to:
  /// **'Users you block will appear here'**
  String get blockedUsersDescription;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get reason;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// Blocked time ago message
  ///
  /// In en, this message translates to:
  /// **'Blocked {timeAgo}'**
  String blockedAgo(String timeAgo);

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// Single day ago
  ///
  /// In en, this message translates to:
  /// **'{count} day ago'**
  String dayAgo(int count);

  /// Multiple days ago
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgoFull(int count);

  /// Single hour ago
  ///
  /// In en, this message translates to:
  /// **'{count} hour ago'**
  String hourAgo(int count);

  /// Multiple hours ago
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgoFull(int count);

  /// Single minute ago
  ///
  /// In en, this message translates to:
  /// **'{count} minute ago'**
  String minuteAgo(int count);

  /// Multiple minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgoFull(int count);

  /// No description provided for @pleaseSelectReasonForReporting.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting'**
  String get pleaseSelectReasonForReporting;

  /// Error submitting report message
  ///
  /// In en, this message translates to:
  /// **'Error submitting report: {error}'**
  String errorSubmittingReport(String error);

  /// No description provided for @reportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report Message'**
  String get reportMessage;

  /// Report message prompt
  ///
  /// In en, this message translates to:
  /// **'Report message: \"{message}\"'**
  String reportMessagePrompt(String message);

  /// No description provided for @selectReasonForReporting.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting this message:'**
  String get selectReasonForReporting;

  /// No description provided for @additionalDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional):'**
  String get additionalDetailsOptional;

  /// No description provided for @provideAdditionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Provide additional information about why you are reporting this message...'**
  String get provideAdditionalInformation;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @portfolioPdf.
  ///
  /// In en, this message translates to:
  /// **'Portfolio PDF'**
  String get portfolioPdf;

  /// No description provided for @viewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View Portfolio'**
  String get viewPortfolio;

  /// No description provided for @updatePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Update Portfolio'**
  String get updatePortfolio;

  /// No description provided for @addPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Add Portfolio'**
  String get addPortfolio;

  /// No description provided for @addNewPdf.
  ///
  /// In en, this message translates to:
  /// **'+ Add New PDF'**
  String get addNewPdf;

  /// No description provided for @deletePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Delete Portfolio'**
  String get deletePortfolio;

  /// No description provided for @deletePortfolioConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your portfolio PDF?'**
  String get deletePortfolioConfirm;

  /// No description provided for @portfolioUrlNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Portfolio URL is not available'**
  String get portfolioUrlNotAvailable;

  /// Error uploading file message
  ///
  /// In en, this message translates to:
  /// **'Error uploading file: {error}'**
  String errorUploadingFile(String error);

  /// Error selecting file message
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {error}'**
  String errorSelectingFile(String error);

  /// Error opening PDF in browser
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF in browser. URL: {url}'**
  String couldNotOpenPdfBrowser(String url);

  /// No description provided for @urlCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get urlCopiedToClipboard;

  /// Failed to copy URL message
  ///
  /// In en, this message translates to:
  /// **'Failed to copy URL: {error}'**
  String failedToCopyUrl(String error);

  /// Error opening PDF message
  ///
  /// In en, this message translates to:
  /// **'Error opening PDF: {error}'**
  String errorOpeningPdf(String error);

  /// No description provided for @myJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get myJobs;

  /// No description provided for @noJobsPostedYet.
  ///
  /// In en, this message translates to:
  /// **'No jobs posted yet'**
  String get noJobsPostedYet;

  /// No description provided for @contractType.
  ///
  /// In en, this message translates to:
  /// **'Contract Type:'**
  String get contractType;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience:'**
  String get experience;

  /// Experience years range
  ///
  /// In en, this message translates to:
  /// **'Experience: {min}-{max} years'**
  String experienceYears(int min, int max);

  /// No description provided for @postNewJob.
  ///
  /// In en, this message translates to:
  /// **'Post New Job'**
  String get postNewJob;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplicationsYet;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @deleteJob.
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get deleteJob;

  /// Delete job confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteJobConfirm(String title);

  /// No description provided for @jobDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Job deleted successfully!'**
  String get jobDeletedSuccessfully;

  /// Error deleting job message
  ///
  /// In en, this message translates to:
  /// **'Error deleting job: {error}'**
  String errorDeletingJob(String error);

  /// No description provided for @myServices.
  ///
  /// In en, this message translates to:
  /// **'My Services'**
  String get myServices;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @addYourFirstService.
  ///
  /// In en, this message translates to:
  /// **'Add your first service to get started'**
  String get addYourFirstService;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// Delete service confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteServiceConfirm(String title);

  /// No description provided for @serviceDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get serviceDeletedSuccessfully;

  /// No description provided for @boostService.
  ///
  /// In en, this message translates to:
  /// **'Boost Service'**
  String get boostService;

  /// Boost service confirmation message
  ///
  /// In en, this message translates to:
  /// **'Boost \"{title}\" to get more visibility?'**
  String boostServiceConfirm(String title);

  /// No description provided for @activateListing.
  ///
  /// In en, this message translates to:
  /// **'Activate Listing'**
  String get activateListing;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ Month'**
  String get perMonth;

  /// No description provided for @addSocialAccountUrl.
  ///
  /// In en, this message translates to:
  /// **'Add Social Account URL'**
  String get addSocialAccountUrl;

  /// No description provided for @exampleFacebook.
  ///
  /// In en, this message translates to:
  /// **'example: Facebook'**
  String get exampleFacebook;

  /// No description provided for @addSocialAccountUrlHint.
  ///
  /// In en, this message translates to:
  /// **'add social account URL'**
  String get addSocialAccountUrlHint;

  /// No description provided for @adding.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get adding;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @urlMustStartWithHttp.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get urlMustStartWithHttp;

  /// No description provided for @socialLinkAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Social link added successfully'**
  String get socialLinkAddedSuccessfully;

  /// Error adding social link message
  ///
  /// In en, this message translates to:
  /// **'Error adding social link: {error}'**
  String errorAddingSocialLink(String error);

  /// No description provided for @deleteSocialLink.
  ///
  /// In en, this message translates to:
  /// **'Delete Social Link'**
  String get deleteSocialLink;

  /// Delete social link confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{linkName}\"?'**
  String deleteSocialLinkConfirm(String linkName);

  /// No description provided for @socialLinkDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Social link deleted successfully'**
  String get socialLinkDeletedSuccessfully;

  /// Error deleting social link message
  ///
  /// In en, this message translates to:
  /// **'Error deleting social link: {error}'**
  String errorDeletingSocialLink(String error);

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @deleteLink.
  ///
  /// In en, this message translates to:
  /// **'Delete link'**
  String get deleteLink;

  /// No description provided for @listingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listingsLabel;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysLabel;

  /// No description provided for @idealForSmallAgencies.
  ///
  /// In en, this message translates to:
  /// **'Ideal for Small Agencies with Moderate Needs'**
  String get idealForSmallAgencies;

  /// No description provided for @forHighVolumeProfessionals.
  ///
  /// In en, this message translates to:
  /// **'For High-volume Professionals & Teams'**
  String get forHighVolumeProfessionals;

  /// No description provided for @basicPlan.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicPlan;

  /// No description provided for @standardPlan.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standardPlan;

  /// No description provided for @unlimitedPlan.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimitedPlan;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @profileImageUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully!'**
  String get profileImageUpdatedSuccessfully;

  /// Error updating profile image message
  ///
  /// In en, this message translates to:
  /// **'Error updating profile image: {error}'**
  String errorUpdatingProfileImage(String error);

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose where to get your profile image from:'**
  String get chooseImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ WARNING: This action is NOT reversible!'**
  String get deleteAccountWarning;

  /// No description provided for @deletingAccountWillRemove.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently remove:'**
  String get deletingAccountWillRemove;

  /// No description provided for @allPersonalData.
  ///
  /// In en, this message translates to:
  /// **'• All your personal data'**
  String get allPersonalData;

  /// No description provided for @allListingsAndServices.
  ///
  /// In en, this message translates to:
  /// **'• All your listings and services'**
  String get allListingsAndServices;

  /// No description provided for @allMessagesAndChatHistory.
  ///
  /// In en, this message translates to:
  /// **'• All your messages and chat history'**
  String get allMessagesAndChatHistory;

  /// No description provided for @allReviewsAndFavorites.
  ///
  /// In en, this message translates to:
  /// **'• All your reviews and favorites'**
  String get allReviewsAndFavorites;

  /// No description provided for @allSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'• All your subscriptions'**
  String get allSubscriptions;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you absolutely sure you want to delete your account?'**
  String get deleteAccountConfirmation;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// Error deleting account message
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String errorDeletingAccount(String error);

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @referrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get referrals;

  /// No description provided for @noUserDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No user data available'**
  String get noUserDataAvailable;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @phoneNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'00 123 456'**
  String get phoneNumberPlaceholder;

  /// No description provided for @editEmailAndNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit Email & Number'**
  String get editEmailAndNumber;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reEnterPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changing.
  ///
  /// In en, this message translates to:
  /// **'Changing...'**
  String get changing;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @newMessages.
  ///
  /// In en, this message translates to:
  /// **'New Messages'**
  String get newMessages;

  /// No description provided for @listingApproval.
  ///
  /// In en, this message translates to:
  /// **'Listing Approval'**
  String get listingApproval;

  /// No description provided for @serviceRequests.
  ///
  /// In en, this message translates to:
  /// **'Service Requests'**
  String get serviceRequests;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @hideSocialLinks.
  ///
  /// In en, this message translates to:
  /// **'Hide Social Links'**
  String get hideSocialLinks;

  /// No description provided for @hideContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Hide Contact Info'**
  String get hideContactInfo;

  /// No description provided for @profileDashboard.
  ///
  /// In en, this message translates to:
  /// **'Profile Dashboard'**
  String get profileDashboard;

  /// No description provided for @helloProfileDashboard.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is the Profile Dashboard screen'**
  String get helloProfileDashboard;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// Items count display
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @favoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Items you favorite will appear here'**
  String get favoritesDescription;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @failedToRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove favorite'**
  String get failedToRemoveFavorite;

  /// No description provided for @networkErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get networkErrorOccurred;

  /// No description provided for @failedToLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites'**
  String get failedToLoadFavorites;

  /// Showing current and total items count
  ///
  /// In en, this message translates to:
  /// **'Showing {current} of {total} items'**
  String showingXOfYItems(int current, int total);

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @referralsTitle.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get referralsTitle;

  /// No description provided for @helloReferrals.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is the Referrals screen'**
  String get helloReferrals;

  /// No description provided for @updateContactInformation.
  ///
  /// In en, this message translates to:
  /// **'How do I update my contact information?'**
  String get updateContactInformation;

  /// No description provided for @resetPasswordAnswer.
  ///
  /// In en, this message translates to:
  /// **'To reset your password, go to profile and click on \'Reset Password\'.'**
  String get resetPasswordAnswer;

  /// No description provided for @howToListNewService.
  ///
  /// In en, this message translates to:
  /// **'How do I list a new service?'**
  String get howToListNewService;

  /// No description provided for @listNewServiceAnswer.
  ///
  /// In en, this message translates to:
  /// **'Create a service provider account, then access the dashboard to add new services.'**
  String get listNewServiceAnswer;

  /// No description provided for @canEditOrDeleteService.
  ///
  /// In en, this message translates to:
  /// **'Can I edit or delete a service I posted?'**
  String get canEditOrDeleteService;

  /// No description provided for @editOrDeleteServiceAnswer.
  ///
  /// In en, this message translates to:
  /// **'It is possible to edit and delete services in the dashboard.'**
  String get editOrDeleteServiceAnswer;

  /// No description provided for @whatHappensAfterServiceRequest.
  ///
  /// In en, this message translates to:
  /// **'What happens after I receive a service request?'**
  String get whatHappensAfterServiceRequest;

  /// No description provided for @viewRequestsAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can view requests in the dashboard.'**
  String get viewRequestsAnswer;

  /// No description provided for @howDoIDeleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get howDoIDeleteMyAccount;

  /// No description provided for @deleteAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Delete your account option is present at the bottom of profile.'**
  String get deleteAccountAnswer;

  /// No description provided for @submitATicket.
  ///
  /// In en, this message translates to:
  /// **'Submit a Ticket'**
  String get submitATicket;

  /// No description provided for @whatsYourIssueAbout.
  ///
  /// In en, this message translates to:
  /// **'What\'s Your Issue About?'**
  String get whatsYourIssueAbout;

  /// No description provided for @selectIssue.
  ///
  /// In en, this message translates to:
  /// **'Select Issue'**
  String get selectIssue;

  /// No description provided for @paymentProblem.
  ///
  /// In en, this message translates to:
  /// **'Payment Problem'**
  String get paymentProblem;

  /// No description provided for @technicalError.
  ///
  /// In en, this message translates to:
  /// **'Technical Error'**
  String get technicalError;

  /// No description provided for @accountIssue.
  ///
  /// In en, this message translates to:
  /// **'Account Issue'**
  String get accountIssue;

  /// No description provided for @describeYourIssueHere.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue here...'**
  String get describeYourIssueHere;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// Enter 6-digit code instruction
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to\n{phoneNumber}'**
  String enter6DigitCode(String phoneNumber);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @noChangesDetected.
  ///
  /// In en, this message translates to:
  /// **'No changes detected'**
  String get noChangesDetected;

  /// No description provided for @otpResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccessfully;

  /// Error requesting OTP message
  ///
  /// In en, this message translates to:
  /// **'Error requesting OTP: {error}'**
  String errorRequestingOtp(String error);

  /// Error verifying OTP message
  ///
  /// In en, this message translates to:
  /// **'Error verifying OTP: {error}'**
  String errorVerifyingOtp(String error);

  /// Failed to update setting message
  ///
  /// In en, this message translates to:
  /// **'Failed to update setting: {error}'**
  String failedToUpdateSetting(String error);

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// Total reviews count
  ///
  /// In en, this message translates to:
  /// **'Total Reviews: {count}'**
  String totalReviews(int count);

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews'**
  String get errorLoadingReviews;

  /// No description provided for @reviewsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Reviews will appear here when you receive them.'**
  String get reviewsWillAppearHere;

  /// Reviews page title
  ///
  /// In en, this message translates to:
  /// **'Reviews for {objectName}'**
  String reviewsFor(String objectName);

  /// No description provided for @failedToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedToLoadReviews;

  /// Message when no reviews exist
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this {table}!'**
  String beFirstToReview(String table);

  /// Review count singular
  ///
  /// In en, this message translates to:
  /// **'{count} Review'**
  String reviewCount(int count);

  /// Review count plural
  ///
  /// In en, this message translates to:
  /// **'{count} Reviews'**
  String reviewCountPlural(int count);

  /// No description provided for @loadMoreReviews.
  ///
  /// In en, this message translates to:
  /// **'Load More Reviews'**
  String get loadMoreReviews;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tapToRate;

  /// Star rating singular
  ///
  /// In en, this message translates to:
  /// **'{count} star'**
  String star(int count);

  /// Star rating plural
  ///
  /// In en, this message translates to:
  /// **'{count} stars'**
  String stars(int count);

  /// No description provided for @shareExperienceWithAgent.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this agent...'**
  String get shareExperienceWithAgent;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @pleaseLoginToSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Please log in to submit a review'**
  String get pleaseLoginToSubmitReview;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @pleaseLoginToAddListing.
  ///
  /// In en, this message translates to:
  /// **'Please log in to add listings'**
  String get pleaseLoginToAddListing;

  /// No description provided for @alreadyReviewedAgent.
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this agent'**
  String get alreadyReviewedAgent;

  /// No description provided for @failedToSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get failedToSubmitReview;

  /// Network error for reviews
  ///
  /// In en, this message translates to:
  /// **'Network error: {error}'**
  String networkErrorReview(String error);

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reportReview.
  ///
  /// In en, this message translates to:
  /// **'Report Review'**
  String get reportReview;

  /// Report review dialog title
  ///
  /// In en, this message translates to:
  /// **'Report review by: {reviewerName}'**
  String reportReviewBy(String reviewerName);

  /// No description provided for @selectReasonForReportingReview.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting this review:'**
  String get selectReasonForReportingReview;

  /// No description provided for @additionalDetailsOptionalReview.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional):'**
  String get additionalDetailsOptionalReview;

  /// No description provided for @provideAdditionalInformationReview.
  ///
  /// In en, this message translates to:
  /// **'Provide additional information about why you are reporting this review...'**
  String get provideAdditionalInformationReview;

  /// No description provided for @pleaseSelectReasonForReportingReview.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting'**
  String get pleaseSelectReasonForReportingReview;

  /// Error submitting review report
  ///
  /// In en, this message translates to:
  /// **'Error submitting report: {error}'**
  String errorSubmittingReviewReport(String error);

  /// No description provided for @reportThisReview.
  ///
  /// In en, this message translates to:
  /// **'Report this review'**
  String get reportThisReview;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// See all reviews button
  ///
  /// In en, this message translates to:
  /// **'See All {count} Reviews'**
  String seeAllReviews(int count);

  /// No description provided for @noReviewsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No reviews available'**
  String get noReviewsAvailable;

  /// No description provided for @serviceProviderNoReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'This service provider hasn\'t received any reviews yet'**
  String get serviceProviderNoReviewsYet;

  /// No description provided for @agentNoReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'This agent hasn\'t received any reviews yet'**
  String get agentNoReviewsYet;

  /// No description provided for @noListingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No listings available'**
  String get noListingsAvailable;

  /// No description provided for @agentNoListingsYet.
  ///
  /// In en, this message translates to:
  /// **'This agent hasn\'t posted any properties yet'**
  String get agentNoListingsYet;

  /// No description provided for @reportThisJob.
  ///
  /// In en, this message translates to:
  /// **'Report this job'**
  String get reportThisJob;

  /// No description provided for @reportThisJobTooltip.
  ///
  /// In en, this message translates to:
  /// **'Report this job'**
  String get reportThisJobTooltip;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @experienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Experience Required'**
  String get experienceRequired;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @applicationForm.
  ///
  /// In en, this message translates to:
  /// **'Application Form'**
  String get applicationForm;

  /// No description provided for @uploadPortfolioOptional.
  ///
  /// In en, this message translates to:
  /// **'Upload Portfolio (Optional)'**
  String get uploadPortfolioOptional;

  /// No description provided for @expectedSalary.
  ///
  /// In en, this message translates to:
  /// **'Expected Salary'**
  String get expectedSalary;

  /// No description provided for @iConfirmInformationAccurate.
  ///
  /// In en, this message translates to:
  /// **'I Confirm That The Submitted Information Is Accurate'**
  String get iConfirmInformationAccurate;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @pleaseConfirmInformationAccurate.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that the submitted information is accurate'**
  String get pleaseConfirmInformationAccurate;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign In Required'**
  String get signInRequired;

  /// No description provided for @signInRequiredToApply.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to apply to jobs. Please sign in and try again.'**
  String get signInRequiredToApply;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted'**
  String get applicationSubmitted;

  /// No description provided for @applicationSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your application has been submitted successfully!'**
  String get applicationSubmittedSuccessfully;

  /// No description provided for @alreadyApplied.
  ///
  /// In en, this message translates to:
  /// **'Already Applied'**
  String get alreadyApplied;

  /// No description provided for @alreadyAppliedToJob.
  ///
  /// In en, this message translates to:
  /// **'You have already applied to this job.'**
  String get alreadyAppliedToJob;

  /// No description provided for @failedToSubmitApplication.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit application. Please try again.'**
  String get failedToSubmitApplication;

  /// Error picking file message
  ///
  /// In en, this message translates to:
  /// **'Error picking file: {error}'**
  String errorPickingFile(String error);

  /// No description provided for @reportJob.
  ///
  /// In en, this message translates to:
  /// **'Report Job'**
  String get reportJob;

  /// Report job title
  ///
  /// In en, this message translates to:
  /// **'Report: {jobTitle}'**
  String reportJobTitle(String jobTitle);

  /// No description provided for @selectReasonForReportingJob.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting this job:'**
  String get selectReasonForReportingJob;

  /// No description provided for @additionalDetailsAboutReportingJob.
  ///
  /// In en, this message translates to:
  /// **'Provide additional information about why you are reporting this job...'**
  String get additionalDetailsAboutReportingJob;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @addNewBuilding.
  ///
  /// In en, this message translates to:
  /// **'Add New Building'**
  String get addNewBuilding;

  /// No description provided for @addNewLand.
  ///
  /// In en, this message translates to:
  /// **'Add New Land'**
  String get addNewLand;

  /// No description provided for @addNewProperty.
  ///
  /// In en, this message translates to:
  /// **'Add New Property'**
  String get addNewProperty;

  /// No description provided for @beforeYouList.
  ///
  /// In en, this message translates to:
  /// **'Before You List'**
  String get beforeYouList;

  /// No description provided for @beforeYouListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let us know if you\'re the owner of the property or an agent listing on someone\'s behalf.'**
  String get beforeYouListSubtitle;

  /// No description provided for @iAm.
  ///
  /// In en, this message translates to:
  /// **'I am..'**
  String get iAm;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @listYourProperty.
  ///
  /// In en, this message translates to:
  /// **'List Your Property'**
  String get listYourProperty;

  /// No description provided for @forRent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get forRent;

  /// No description provided for @forSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get forSale;

  /// No description provided for @listingType.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get listingType;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectType;

  /// No description provided for @rentalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rental Period'**
  String get rentalPeriod;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @editPropertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Property Details'**
  String get editPropertyDetails;

  /// No description provided for @addPropertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Property Details'**
  String get addPropertyDetails;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @propertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Title'**
  String get propertyTitle;

  /// No description provided for @enterPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter property title'**
  String get enterPropertyTitle;

  /// No description provided for @titleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleIsRequired;

  /// No description provided for @describeYourProperty.
  ///
  /// In en, this message translates to:
  /// **'Describe your property'**
  String get describeYourProperty;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @cityIsRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityIsRequired;

  /// No description provided for @rentalPrice.
  ///
  /// In en, this message translates to:
  /// **'Rental Price'**
  String get rentalPrice;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale Price'**
  String get salePrice;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @priceIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceIsRequired;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @sizeSqFt.
  ///
  /// In en, this message translates to:
  /// **'Size (sq meters)'**
  String get sizeSqFt;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @ground.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get ground;

  /// No description provided for @buildingAgeYears.
  ///
  /// In en, this message translates to:
  /// **'Building Age (years)'**
  String get buildingAgeYears;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @papers.
  ///
  /// In en, this message translates to:
  /// **'Papers'**
  String get papers;

  /// No description provided for @propertyImages.
  ///
  /// In en, this message translates to:
  /// **'Property Images'**
  String get propertyImages;

  /// No description provided for @imagesCounter.
  ///
  /// In en, this message translates to:
  /// **'{count}/10 images'**
  String imagesCounter(int count);

  /// No description provided for @maxImagesReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum images reached (10/10)'**
  String get maxImagesReached;

  /// No description provided for @tapToAddImages.
  ///
  /// In en, this message translates to:
  /// **'Tap to add images'**
  String get tapToAddImages;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @updateListing.
  ///
  /// In en, this message translates to:
  /// **'Update Listing'**
  String get updateListing;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @listingUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Listing updated successfully!'**
  String get listingUpdatedSuccessfully;

  /// No description provided for @failedToUpdateListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to update listing. Please try again.'**
  String get failedToUpdateListing;

  /// No description provided for @listingCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get listingCreatedSuccessfully;

  /// No description provided for @failedToCreateListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to create listing. Please try again.'**
  String get failedToCreateListing;

  /// No description provided for @errorPickingImages.
  ///
  /// In en, this message translates to:
  /// **'Error picking images: {error}'**
  String errorPickingImages(String error);

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(String error);

  /// No description provided for @amenityFurnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get amenityFurnished;

  /// No description provided for @amenityTerrace.
  ///
  /// In en, this message translates to:
  /// **'Terrace'**
  String get amenityTerrace;

  /// No description provided for @amenityPrivatePool.
  ///
  /// In en, this message translates to:
  /// **'Private Pool'**
  String get amenityPrivatePool;

  /// No description provided for @amenityStorageRoom.
  ///
  /// In en, this message translates to:
  /// **'Storage Room'**
  String get amenityStorageRoom;

  /// No description provided for @amenitySharedPool.
  ///
  /// In en, this message translates to:
  /// **'Shared Pool'**
  String get amenitySharedPool;

  /// No description provided for @amenitySharedGym.
  ///
  /// In en, this message translates to:
  /// **'Shared Gym'**
  String get amenitySharedGym;

  /// No description provided for @amenitySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get amenitySecurity;

  /// No description provided for @amenitySeaView.
  ///
  /// In en, this message translates to:
  /// **'Sea View'**
  String get amenitySeaView;

  /// No description provided for @amenityGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get amenityGarden;

  /// No description provided for @amenityMountainView.
  ///
  /// In en, this message translates to:
  /// **'Mountain View'**
  String get amenityMountainView;

  /// No description provided for @amenityElevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get amenityElevator;

  /// No description provided for @amenityParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get amenityParking;

  /// No description provided for @amenityCentralAC.
  ///
  /// In en, this message translates to:
  /// **'Central AC'**
  String get amenityCentralAC;

  /// No description provided for @amenityHeating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get amenityHeating;

  /// No description provided for @amenitySolarSystem.
  ///
  /// In en, this message translates to:
  /// **'Solar System'**
  String get amenitySolarSystem;

  /// No description provided for @amenityElectricity247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Electricity'**
  String get amenityElectricity247;

  /// No description provided for @amenityMaidRoom.
  ///
  /// In en, this message translates to:
  /// **'Maid Room'**
  String get amenityMaidRoom;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @conditionExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get conditionExcellent;

  /// No description provided for @conditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get conditionGood;

  /// No description provided for @conditionNeedsRenovation.
  ///
  /// In en, this message translates to:
  /// **'Needs Renovation'**
  String get conditionNeedsRenovation;

  /// No description provided for @conditionOld.
  ///
  /// In en, this message translates to:
  /// **'Old'**
  String get conditionOld;

  /// No description provided for @papersTitleDeed.
  ///
  /// In en, this message translates to:
  /// **'Title Deed'**
  String get papersTitleDeed;

  /// No description provided for @papersRentalContract.
  ///
  /// In en, this message translates to:
  /// **'Rental Contract'**
  String get papersRentalContract;

  /// No description provided for @papersUnderConstruction.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get papersUnderConstruction;

  /// No description provided for @papersOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get papersOther;

  /// No description provided for @propertyOwner.
  ///
  /// In en, this message translates to:
  /// **'Property Owner'**
  String get propertyOwner;

  /// No description provided for @propertyTypeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get propertyTypeApartment;

  /// No description provided for @propertyTypeChalet.
  ///
  /// In en, this message translates to:
  /// **'Chalet'**
  String get propertyTypeChalet;

  /// No description provided for @propertyTypeStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get propertyTypeStudio;

  /// No description provided for @propertyTypeCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get propertyTypeCommercial;

  /// No description provided for @propertyTypeVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get propertyTypeVilla;

  /// No description provided for @propertyTypeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get propertyTypeLand;

  /// No description provided for @propertyTypeIndustrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get propertyTypeIndustrial;

  /// No description provided for @propertyTypeRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get propertyTypeRoom;

  /// No description provided for @propertyTypeBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get propertyTypeBuilding;

  /// No description provided for @propertyTypeInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get propertyTypeInternational;

  /// No description provided for @rentalPeriodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get rentalPeriodDaily;

  /// No description provided for @rentalPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rentalPeriodMonthly;

  /// No description provided for @rentalPeriodYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get rentalPeriodYearly;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResultsTitle;

  /// No description provided for @searchPropertiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search properties...'**
  String get searchPropertiesHint;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @errorSearching.
  ///
  /// In en, this message translates to:
  /// **'Error searching: {error}'**
  String errorSearching(String error);

  /// No description provided for @searchTitleWithQuery.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}'**
  String searchTitleWithQuery(String query);

  /// No description provided for @failedToLoadSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Failed to load search results: {error}'**
  String failedToLoadSearchResults(String error);

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @weWillGetBackSoon.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get back to you as soon as possible.'**
  String get weWillGetBackSoon;

  /// No description provided for @fillFormAndWeWillGetBack.
  ///
  /// In en, this message translates to:
  /// **'Fill out the form below and we\'ll get back to you.'**
  String get fillFormAndWeWillGetBack;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @emailAddressRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get emailAddressRequiredLabel;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @pleaseEnterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmailAddress;

  /// No description provided for @phoneNumberRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneNumberRequiredLabel;

  /// No description provided for @enterYourPhoneNumberText.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumberText;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @describeIssueOrQuestionRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue or question *'**
  String get describeIssueOrQuestionRequiredLabel;

  /// No description provided for @describeIssueOrQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide as much details as possible about your issue or question...'**
  String get describeIssueOrQuestionHint;

  /// No description provided for @messageIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageIsRequired;

  /// No description provided for @messageMinLength.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 10 characters long'**
  String get messageMinLength;

  /// No description provided for @messageMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Message must be less than 5000 characters'**
  String get messageMaxLength;

  /// No description provided for @ticketSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket submitted successfully'**
  String get ticketSubmittedSuccessfully;

  /// No description provided for @failedToSubmitTicket.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit ticket'**
  String get failedToSubmitTicket;

  /// No description provided for @errorOccurredWithDetails.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurredWithDetails(String error);

  /// No description provided for @emailLabelWithValue.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailLabelWithValue(String email);

  /// No description provided for @phoneLabelWithValue.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabelWithValue(String phone);

  /// No description provided for @supportResponseNote.
  ///
  /// In en, this message translates to:
  /// **'We typically respond within 48 hours. For urgent issues, please call our support line. You may only send one ticket per day.'**
  String get supportResponseNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
