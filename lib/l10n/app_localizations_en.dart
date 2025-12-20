// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String underConstructionPage(String pageName) {
    return '$pageName Page is under construction 🚧';
  }

  @override
  String get agents => 'Agents';

  @override
  String get realEstate => 'Real Estate';

  @override
  String get listings => 'Listings';

  @override
  String get home => 'Home';

  @override
  String get services => 'Services';

  @override
  String get chat => 'Chat';

  @override
  String get appTitle => 'Flutter Navbar App';

  @override
  String get loggedOutSuccessfully => 'Logged out successfully';

  @override
  String get guest => 'Guest';

  @override
  String get goToDashboard => 'Go to Dashboard';

  @override
  String get login => 'Login';

  @override
  String get featuredListings => 'Featured Listings';

  @override
  String get recommendedAgents => 'Recommended Agents';

  @override
  String get latestMarketUpdates => 'Latest Market Updates';

  @override
  String get supportCardDescription =>
      'Facing Legal Issues Or Other Concerns Related To Your Property? Our Expert Support Team Is Just A Message Away Ready To Assist You';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get featuredServices => 'Featured Services';

  @override
  String get topRatedServices => 'Top Rated Services';

  @override
  String get companyServices => 'Company Services';

  @override
  String get individualServices => 'Individual Services';

  @override
  String get featuredCompanies => 'Featured Companies';

  @override
  String get topCompanies => 'Top Companies';

  @override
  String get failedToLoadFeaturedServiceProviders =>
      'Failed to load featured service providers';

  @override
  String get errorFetchingFeaturedServiceProviders =>
      'Error fetching featured service providers';

  @override
  String get failedToLoadTopRatedServiceProviders =>
      'Failed to load top rated service providers';

  @override
  String get errorFetchingTopRatedServiceProviders =>
      'Error fetching top rated service providers';

  @override
  String get failedToLoadServiceProviders => 'Failed to load service providers';

  @override
  String get errorFetchingServiceProviders =>
      'Error fetching service providers';

  @override
  String get noServiceProvidersFound => 'No service providers found';

  @override
  String get failedToLoadServiceProvider => 'Failed to load service provider';

  @override
  String get errorFetchingServiceProvider => 'Error fetching service provider';

  @override
  String get noServiceProviderDataFound => 'No service provider data found';

  @override
  String get failedToLoadMyServices => 'Failed to load my services';

  @override
  String get errorFetchingMyServices => 'Error fetching my services';

  @override
  String get failedToLoadAgentServices => 'Failed to load agent services';

  @override
  String get errorFetchingAgentServices => 'Error fetching agent services';

  @override
  String get failedToCreateService => 'Failed to create service';

  @override
  String get pleaseEnterServiceTitle => 'Please enter a service title';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterValidPortfolioUrl =>
      'Please enter a valid portfolio URL';

  @override
  String get pleaseCheckInputAndTryAgain =>
      'Please check your input and try again';

  @override
  String get failedToCreateServiceTryAgain =>
      'Failed to create service. Please try again.';

  @override
  String get unableToConnectToServer =>
      'Unable to connect to server. Please check your internet connection and try again.';

  @override
  String get failedToUpdateService => 'Failed to update service';

  @override
  String get failedToUpdateServiceTryAgain =>
      'Failed to update service. Please try again.';

  @override
  String get failedToDeleteService => 'Failed to delete service';

  @override
  String get failedToDeleteServiceTryAgain =>
      'Failed to delete service. Please try again.';

  @override
  String get failedToSearchServiceProviders =>
      'Failed to search service providers';

  @override
  String get errorSearchingServiceProviders =>
      'Error searching service providers';

  @override
  String failedToLoadCategory(String categoryName) {
    return 'Failed to load $categoryName';
  }

  @override
  String noCategoryFound(String categoryName) {
    return 'No $categoryName found';
  }

  @override
  String get noServicesFound => 'No services found';

  @override
  String get featuredJobs => 'Featured Jobs';

  @override
  String get forYouJobs => 'Job Vacancies';

  @override
  String get recentJobs => 'Recent Jobs';

  @override
  String get recommendedJobs => 'Recommended Jobs';

  @override
  String get failedToLoadJobs => 'Failed to load jobs';

  @override
  String get errorFetchingJobs => 'Error fetching jobs';

  @override
  String get noJobsFound => 'No jobs found';

  @override
  String get failedToLoadJobDetails => 'Failed to load job details';

  @override
  String get seeAll => 'See all';

  @override
  String get sortBy => 'Sort by';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get retry => 'Retry';

  @override
  String get page => 'Page';

  @override
  String get ofText => 'of';

  @override
  String get exploreJobs => 'Explore Jobs';

  @override
  String showingCountOfTotal(int count, int total) {
    return 'Showing $count of $total featured services';
  }

  @override
  String get failedToLoadFeaturedServices => 'Failed to load featured services';

  @override
  String get noFeaturedServicesFound => 'No featured services found';

  @override
  String get about => 'About';

  @override
  String get description => 'Description';

  @override
  String get readMore => 'Read More';

  @override
  String get readLess => 'Read Less';

  @override
  String get noServicesAvailable => 'No services available';

  @override
  String get contactDetails => 'Contact Details';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone:';

  @override
  String get location => 'Location:';

  @override
  String get company => 'Company:';

  @override
  String get startChat => 'Start Chat';

  @override
  String get reportServiceProvider => 'Report this service provider';

  @override
  String get reportServiceProviderTooltip => 'Report this service provider';

  @override
  String get pleaseLoginToStartChat => 'Please log in to start a chat';

  @override
  String get failedToStartChat => 'Failed to start chat. Please try again.';

  @override
  String get couldNotMakePhoneCall => 'Could not make phone call';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get errorOpeningPortfolio => 'Error opening portfolio';

  @override
  String get noPortfolioAvailable => 'No portfolio available';

  @override
  String get noServiceProviderDataAvailable =>
      'No service provider data available';

  @override
  String professionalServiceProviderDescription(
    String displayName,
    String city,
    String country,
  ) {
    return 'Professional $displayName providing quality services in $city, $country.';
  }

  @override
  String individualServiceProviderDescription(
    String firstName,
    String lastName,
    String city,
    String country,
  ) {
    return '$firstName $lastName is a professional service provider based in $city, $country.';
  }

  @override
  String searchFor(String query) {
    return 'Search: \"$query\"';
  }

  @override
  String get searchingServiceProviders => 'Searching service providers...';

  @override
  String get tryDifferentKeywords => 'Try searching with different keywords';

  @override
  String get goBack => 'Go Back';

  @override
  String get unknownError => 'Unknown error occurred';

  @override
  String agentServicesTitle(String agentName) {
    return '$agentName\'s Services';
  }

  @override
  String agentListingsTitle(String firstName) {
    return '$firstName\'s Listings';
  }

  @override
  String get failedToLoadServices => 'Failed to load services';

  @override
  String get pleaseLoginToStartChatAgent => 'Please log in to start a chat';

  @override
  String get failedToStartChatAgent =>
      'Failed to start chat. Please try again.';

  @override
  String get couldNotMakePhoneCallAgent => 'Could not make phone call';

  @override
  String errorOpeningLinkAgent(String error) {
    return 'Error opening link: $error';
  }

  @override
  String get reportAgent => 'Report this agent';

  @override
  String get reportAgentTooltip => 'Report this agent';

  @override
  String get aboutAgent => 'About';

  @override
  String get readMoreAgent => 'Read More';

  @override
  String get readLessAgent => 'Read Less';

  @override
  String get detailsAgent => 'Details';

  @override
  String get emailAgent => 'Email:';

  @override
  String get serviceAreas => 'Service Areas:';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get noProfileImage => 'No profile image';

  @override
  String get failedToLoadAgentData => 'Failed to load agent data';

  @override
  String get noAgentDataAvailable => 'No agent data available';

  @override
  String searchResultsFor(String query) {
    return 'Search Results for \"$query\"';
  }

  @override
  String foundAgentsFor(int count, String query) {
    return 'Found $count agents for \"$query\"';
  }

  @override
  String get searchingAgents => 'Searching agents...';

  @override
  String get errorSearchingAgents => 'Error searching agents';

  @override
  String get noAgentsFound => 'No agents found';

  @override
  String get tryDifferentKeywordsAgent =>
      'Try searching with different keywords';

  @override
  String get featuredAgents => 'Featured Agents';

  @override
  String get topRatedAgents => 'Top Rated Agents';

  @override
  String get recommendedAgentsTitle => 'Recommended Agents';

  @override
  String failedToLoadAgents(String categoryName) {
    return 'Failed to load $categoryName';
  }

  @override
  String get noAgentsFoundCategory => 'No agents found';

  @override
  String get agentDashboard => 'Agent Dashboard';

  @override
  String get stats => 'Stats';

  @override
  String get totalListings => 'Total Listings:';

  @override
  String get profileViews => 'Profile Views:';

  @override
  String get activeListings => 'Active Listings:';

  @override
  String get totalChats => 'Total Chats:';

  @override
  String get addNewListing => 'Add New Listing';

  @override
  String get inactiveListings => 'Inactive Listings';

  @override
  String get noInactiveListings => 'No inactive listings';

  @override
  String get listingsLeft => 'Listings Left';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get myListings => 'My Listings';

  @override
  String get noActiveListings => 'No active listings';

  @override
  String get ratingAndReviews => 'Rating & Reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get plansAndSubscription => 'Plans & Subscription';

  @override
  String get currentSubscription => 'Current Subscription';

  @override
  String get daysLeft => 'days left';

  @override
  String get links => 'Links';

  @override
  String get deleteListing => 'Delete Listing';

  @override
  String deleteListingConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get delete => 'Delete';

  @override
  String get listingDeletedSuccessfully => 'Listing deleted successfully';

  @override
  String get failedToDeleteListing => 'Failed to delete listing';

  @override
  String errorDeletingListing(String error) {
    return 'Error deleting listing: $error';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get soldFunctionalityNotImplemented =>
      'Sold functionality not implemented yet';

  @override
  String get boostFunctionalityNotImplemented =>
      'Boost functionality not implemented yet';

  @override
  String hiUser(String name) {
    return 'Hi, $name';
  }

  @override
  String get activePlan => 'Active Plan:';

  @override
  String validUntil(String date) {
    return 'Valid Until: $date';
  }

  @override
  String get noPlan => 'No Plan';

  @override
  String get myAgents => 'My Agents';

  @override
  String totalAgents(int count) {
    return 'Total Agents: $count';
  }

  @override
  String pageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get noAgentsFoundMy => 'No agents found';

  @override
  String get loadMore => 'Load More';

  @override
  String get noEmail => 'No email';

  @override
  String get noPhone => 'No phone';

  @override
  String joined(String date) {
    return 'Joined: $date';
  }

  @override
  String errorLoadingAgents(String error) {
    return 'Error loading agents: $error';
  }

  @override
  String get billingHistory => 'Billing History';

  @override
  String get date => 'Date';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get searchAgents => 'Search agents...';

  @override
  String get topAgents => 'Top Agents';

  @override
  String get forYouAgents => 'For You';

  @override
  String failedToLoadAgentsWidget(String error) {
    return 'Failed to load agents: $error';
  }

  @override
  String properties(int count) {
    return '$count Properties';
  }

  @override
  String failedToLoadListingsCategory(String categoryName, String error) {
    return 'Failed to load $categoryName: $error';
  }

  @override
  String get noListingsFound => 'No listings found';

  @override
  String get featuredLabel => 'Featured';

  @override
  String showingFeaturedListings(int count, int total) {
    return 'Showing $count of $total featured listings';
  }

  @override
  String get failedToLoadFeaturedListings => 'Failed to load featured listings';

  @override
  String get noFeaturedListingsFound => 'No featured listings found';

  @override
  String errorLoadingListings(String error) {
    return 'Error loading listings: $error';
  }

  @override
  String get activateFunctionalityNotImplemented =>
      'Wait for admin to approve listing';

  @override
  String get editButton => 'Edit';

  @override
  String get soldButton => 'Sold';

  @override
  String get boostButton => 'Boost';

  @override
  String get promoteButton => 'Promote';

  @override
  String get reportListing => 'Report this listing';

  @override
  String get phoneNumberNotAvailable => 'Phone number not available';

  @override
  String get couldNotOpenWhatsApp => 'Could not open WhatsApp';

  @override
  String errorOpeningWhatsApp(String error) {
    return 'Error opening WhatsApp: $error';
  }

  @override
  String get dateNotAvailable => 'Date not available';

  @override
  String get propertyDetails => 'Property Details';

  @override
  String get amenitiesLabel => 'Amenities';

  @override
  String get relatedListings => 'Related Listings';

  @override
  String get propertyCodeLabel => 'Property Code:';

  @override
  String get listedDateLabel => 'Listed Date:';

  @override
  String get propertyCodeCopied => 'Property code copied to clipboard';

  @override
  String get callButton => 'Call';

  @override
  String get whatsAppButton => 'WhatsApp';

  @override
  String sizeLabel(String size) {
    return 'Size: $size sqm';
  }

  @override
  String bedroomsBathrooms(String bedrooms, String bathrooms) {
    return '$bedrooms Bedrooms, $bathrooms Bathrooms';
  }

  @override
  String bedroomsOnly(String bedrooms) {
    return '$bedrooms Bedrooms';
  }

  @override
  String bathroomsOnly(String bathrooms) {
    return '$bathrooms Bathrooms';
  }

  @override
  String get typeLabel => 'Type:';

  @override
  String get floorLabel => 'Floor:';

  @override
  String get conditionLabel => 'Condition:';

  @override
  String buildingAgeLabel(String age) {
    return 'Building Age: $age years';
  }

  @override
  String get papersLabel => 'Papers:';

  @override
  String get availableForLabel => 'Available for:';

  @override
  String availableFromLabel(String date) {
    return 'Available from: $date';
  }

  @override
  String get newListings => 'New Listings';

  @override
  String get apartments => 'Apartments';

  @override
  String get chalets => 'Chalets';

  @override
  String get villas => 'Villas';

  @override
  String get land => 'Land';

  @override
  String get commercial => 'Commercial';

  @override
  String get bedText => 'bed';

  @override
  String get bathText => 'bath';

  @override
  String noCategoryListingsFound(String categoryName) {
    return 'No $categoryName found';
  }

  @override
  String pageCurrentOfTotal(int current, int total) {
    return '$current / $total';
  }

  @override
  String get signUp => 'Sign Up';

  @override
  String get logIn => 'Log in';

  @override
  String get usingEmail => 'Using Email';

  @override
  String get usingPhoneNumber => 'Using Phone Number';

  @override
  String get emailOrUsername => 'Email or Username';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get dontHaveAnAccountFull => 'Don\'t Have an account? ';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? ';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get logInWithEmailAddress => 'Log in with Email Address';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get verifyByEmail => 'Verify By Email';

  @override
  String get verifyByPhone => 'Verify By Phone';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String enterOtpSentToPhone(String phone) {
    return 'Enter the OTP sent to your phone number $phone';
  }

  @override
  String get didntReceiveOtp => 'Didn\'t receive OTP? ';

  @override
  String get resend => 'Resend';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterEmail => 'Enter Email';

  @override
  String get createPassword => 'Create Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get selectCountry => 'Select Country';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get selectCity => 'Select City';

  @override
  String get completeSignup => 'Complete Signup';

  @override
  String get liveLocation => 'Live Location';

  @override
  String get thisFieldIsRequired => 'This field is required';

  @override
  String get required => 'Required';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get minimum6Characters => 'Minimum 6 characters';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get invalidPhone => 'Invalid phone';

  @override
  String get pleaseEnterYourPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get invalidOtp => 'Invalid OTP';

  @override
  String get enterPhoneNumberBelow =>
      'Enter your phone number below. We\'ll send a verification code to proceed with resetting your password';

  @override
  String get enterEmailBelow =>
      'Enter your email address below. We\'ll send a password reset link to proceed with resetting your password';

  @override
  String get passwordResetSent => 'Password reset link/code sent successfully!';

  @override
  String get failedToSendReset =>
      'Failed to send reset link/code. Please check your input.';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get invalidCredentials => 'Invalid credentials. Please try again.';

  @override
  String get verificationSuccessful =>
      'Verification successful! You are now signed in.';

  @override
  String get verificationSuccessfulManual =>
      'Verification successful! Please sign in manually.';

  @override
  String get verificationSuccessfulContinue =>
      'Verification successful! Please sign in to continue.';

  @override
  String get otpVerificationFailed => 'OTP verification failed';

  @override
  String networkError(String error) {
    return 'Network error: $error';
  }

  @override
  String get otpSentToPhone =>
      'OTP sent to your phone. Please verify to complete signup.';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get pleaseAgreeToTerms =>
      'Please agree to the Terms of Service and Privacy Policy to continue';

  @override
  String get otpResendFunctionalityComingSoon =>
      'OTP resend functionality coming soon';

  @override
  String get signUpAs => 'Sign up as';

  @override
  String get user => 'User';

  @override
  String get serviceProvider => 'Service Provider';

  @override
  String get signUpAsRealEstate => 'Sign Up as Real Estate';

  @override
  String get signUpAsServiceProvider => 'Sign Up as Service Provider';

  @override
  String get realEstateAgent => 'Real Estate Agent';

  @override
  String get realEstateCompany => 'Real Estate Company';

  @override
  String get individualServiceProvider => 'Individual Service Provider';

  @override
  String get serviceProviderCompany => 'Service Provider Company';

  @override
  String get forFreelancersOrSelfEmployed =>
      'For Freelancers or Self-employed Providers';

  @override
  String get forBusinessesWithTeam =>
      'For Businesses with a team or registered office';

  @override
  String get companyName => 'Company Name';

  @override
  String get signInToChat => 'Sign in to Chat';

  @override
  String get signInToChatDescription =>
      'You need to be signed in to access your chats and start conversations.';

  @override
  String get unread => 'Unread';

  @override
  String unreadCount(int count) {
    return 'Unread $count';
  }

  @override
  String get search => 'Search...';

  @override
  String get searchJobs => 'Search jobs...';

  @override
  String get searchServiceProviders => 'Search service providers...';

  @override
  String get seeBlockedContacts => 'See Blocked Contacts';

  @override
  String get pleaseSignInToAccessChats => 'Please sign in to access your chats';

  @override
  String errorLoadingChats(String error) {
    return 'Error loading chats: $error';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get noChatsYet => 'No chats yet';

  @override
  String get pleaseSignInToChat => 'Please sign in to chat';

  @override
  String get startConversation => 'Start a conversation with someone';

  @override
  String get signInToAccessChatsDescription =>
      'Sign in to access your chats and start conversations';

  @override
  String get justNow => 'Just now';

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get blockUser => 'Block User';

  @override
  String get blockUserConfirm =>
      'Are you sure you want to block this user? You won\'t be able to send or receive messages from them.';

  @override
  String get userBlockedSuccessfully => 'User blocked successfully';

  @override
  String errorBlockingUser(String error) {
    return 'Error blocking user: $error';
  }

  @override
  String errorInitializingChat(String error) {
    return 'Error initializing chat: $error';
  }

  @override
  String errorSendingMessage(String error) {
    return 'Error sending message: $error';
  }

  @override
  String errorDeletingMessage(String error) {
    return 'Error deleting message: $error';
  }

  @override
  String get report => 'Report';

  @override
  String get startConversationPrompt => 'Start the conversation!';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get you => 'You';

  @override
  String errorLoadingBlockedUsers(String error) {
    return 'Error loading blocked users: $error';
  }

  @override
  String userUnblockedSuccessfully(String name) {
    return '$name unblocked successfully';
  }

  @override
  String errorUnblockingUser(String error) {
    return 'Error unblocking user: $error';
  }

  @override
  String get unblockUser => 'Unblock User';

  @override
  String unblockUserConfirm(String name) {
    return 'Are you sure you want to unblock $name? You will be able to send and receive messages from them again.';
  }

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get noBlockedUsers => 'No blocked users';

  @override
  String get blockedUsersDescription => 'Users you block will appear here';

  @override
  String get reason => 'Reason:';

  @override
  String get blocked => 'Blocked';

  @override
  String blockedAgo(String timeAgo) {
    return 'Blocked $timeAgo';
  }

  @override
  String get unknownUser => 'Unknown User';

  @override
  String dayAgo(int count) {
    return '$count day ago';
  }

  @override
  String daysAgoFull(int count) {
    return '$count days ago';
  }

  @override
  String hourAgo(int count) {
    return '$count hour ago';
  }

  @override
  String hoursAgoFull(int count) {
    return '$count hours ago';
  }

  @override
  String minuteAgo(int count) {
    return '$count minute ago';
  }

  @override
  String minutesAgoFull(int count) {
    return '$count minutes ago';
  }

  @override
  String get pleaseSelectReasonForReporting =>
      'Please select a reason for reporting';

  @override
  String errorSubmittingReport(String error) {
    return 'Error submitting report: $error';
  }

  @override
  String get reportMessage => 'Report Message';

  @override
  String reportMessagePrompt(String message) {
    return 'Report message: \"$message\"';
  }

  @override
  String get selectReasonForReporting =>
      'Please select a reason for reporting this message:';

  @override
  String get additionalDetailsOptional => 'Additional details (optional):';

  @override
  String get provideAdditionalInformation =>
      'Provide additional information about why you are reporting this message...';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get submit => 'Submit';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get portfolioPdf => 'Portfolio PDF';

  @override
  String get viewPortfolio => 'View Portfolio';

  @override
  String get updatePortfolio => 'Update Portfolio';

  @override
  String get addPortfolio => 'Add Portfolio';

  @override
  String get addNewPdf => '+ Add New PDF';

  @override
  String get deletePortfolio => 'Delete Portfolio';

  @override
  String get deletePortfolioConfirm =>
      'Are you sure you want to delete your portfolio PDF?';

  @override
  String get portfolioUrlNotAvailable => 'Portfolio URL is not available';

  @override
  String errorUploadingFile(String error) {
    return 'Error uploading file: $error';
  }

  @override
  String errorSelectingFile(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String couldNotOpenPdfBrowser(String url) {
    return 'Could not open PDF in browser. URL: $url';
  }

  @override
  String get urlCopiedToClipboard => 'URL copied to clipboard';

  @override
  String failedToCopyUrl(String error) {
    return 'Failed to copy URL: $error';
  }

  @override
  String errorOpeningPdf(String error) {
    return 'Error opening PDF: $error';
  }

  @override
  String get myJobs => 'My Jobs';

  @override
  String get noJobsPostedYet => 'No jobs posted yet';

  @override
  String get contractType => 'Contract Type:';

  @override
  String get experience => 'Experience:';

  @override
  String experienceYears(int min, int max) {
    return 'Experience: $min-$max years';
  }

  @override
  String get postNewJob => 'Post New Job';

  @override
  String get applications => 'Applications';

  @override
  String get noApplicationsYet => 'No applications yet';

  @override
  String get viewAll => 'View All';

  @override
  String get newBadge => 'NEW';

  @override
  String get deleteJob => 'Delete Job';

  @override
  String deleteJobConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get jobDeletedSuccessfully => 'Job deleted successfully!';

  @override
  String errorDeletingJob(String error) {
    return 'Error deleting job: $error';
  }

  @override
  String get myServices => 'My Services';

  @override
  String get addService => 'Add Service';

  @override
  String get showMore => 'Show More';

  @override
  String get showLess => 'Show Less';

  @override
  String get addYourFirstService => 'Add your first service to get started';

  @override
  String get deleteService => 'Delete Service';

  @override
  String deleteServiceConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get serviceDeletedSuccessfully => 'Service deleted successfully';

  @override
  String get boostService => 'Boost Service';

  @override
  String boostServiceConfirm(String title) {
    return 'Boost \"$title\" to get more visibility?';
  }

  @override
  String get activateListing => 'Activate Listing';

  @override
  String get perMonth => '/ Month';

  @override
  String get addSocialAccountUrl => 'Add Social Account URL';

  @override
  String get exampleFacebook => 'example: Facebook';

  @override
  String get addSocialAccountUrlHint => 'add social account URL';

  @override
  String get adding => 'Adding...';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get urlMustStartWithHttp => 'URL must start with http:// or https://';

  @override
  String get socialLinkAddedSuccessfully => 'Social link added successfully';

  @override
  String errorAddingSocialLink(String error) {
    return 'Error adding social link: $error';
  }

  @override
  String get deleteSocialLink => 'Delete Social Link';

  @override
  String deleteSocialLinkConfirm(String linkName) {
    return 'Are you sure you want to delete \"$linkName\"?';
  }

  @override
  String get socialLinkDeletedSuccessfully =>
      'Social link deleted successfully';

  @override
  String errorDeletingSocialLink(String error) {
    return 'Error deleting social link: $error';
  }

  @override
  String get openLink => 'Open link';

  @override
  String get deleteLink => 'Delete link';

  @override
  String get listingsLabel => 'Listings';

  @override
  String get daysLabel => 'Days';

  @override
  String get idealForSmallAgencies =>
      'Ideal for Small Agencies with Moderate Needs';

  @override
  String get forHighVolumeProfessionals =>
      'For High-volume Professionals & Teams';

  @override
  String get basicPlan => 'Basic';

  @override
  String get standardPlan => 'Standard';

  @override
  String get unlimitedPlan => 'Unlimited';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get profileImageUpdatedSuccessfully =>
      'Profile image updated successfully!';

  @override
  String errorUpdatingProfileImage(String error) {
    return 'Error updating profile image: $error';
  }

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get chooseImageSource =>
      'Choose where to get your profile image from:';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get logout => 'Logout';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      '⚠️ WARNING: This action is NOT reversible!';

  @override
  String get deletingAccountWillRemove =>
      'Deleting your account will permanently remove:';

  @override
  String get allPersonalData => '• All your personal data';

  @override
  String get allListingsAndServices => '• All your listings and services';

  @override
  String get allMessagesAndChatHistory =>
      '• All your messages and chat history';

  @override
  String get allReviewsAndFavorites => '• All your reviews and favorites';

  @override
  String get allSubscriptions => '• All your subscriptions';

  @override
  String get deleteAccountConfirmation =>
      'This action cannot be undone. Are you absolutely sure you want to delete your account?';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String errorDeletingAccount(String error) {
    return 'Error deleting account: $error';
  }

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get favorites => 'Favorites';

  @override
  String get referrals => 'Referrals';

  @override
  String get noUserDataAvailable => 'No user data available';

  @override
  String get enterYourPhoneNumber => 'Enter your phone number';

  @override
  String get phoneNumberPlaceholder => '00 123 456';

  @override
  String get editEmailAndNumber => 'Edit Email & Number';

  @override
  String get processing => 'Processing...';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get reEnterPassword => 'Re-enter password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changing => 'Changing...';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get newMessages => 'New Messages';

  @override
  String get listingApproval => 'Listing Approval';

  @override
  String get serviceRequests => 'Service Requests';

  @override
  String get promotions => 'Promotions';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get hideSocialLinks => 'Hide Social Links';

  @override
  String get hideContactInfo => 'Hide Contact Info';

  @override
  String get profileDashboard => 'Profile Dashboard';

  @override
  String get helloProfileDashboard =>
      'Hello, this is the Profile Dashboard screen';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get favoritesDescription => 'Items you favorite will appear here';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get failedToRemoveFavorite => 'Failed to remove favorite';

  @override
  String get networkErrorOccurred => 'Network error occurred';

  @override
  String get failedToLoadFavorites => 'Failed to load favorites';

  @override
  String showingXOfYItems(int current, int total) {
    return 'Showing $current of $total items';
  }

  @override
  String get loadingMore => 'Loading more...';

  @override
  String get referralsTitle => 'Referrals';

  @override
  String get helloReferrals => 'Hello, this is the Referrals screen';

  @override
  String get updateContactInformation =>
      'How do I update my contact information?';

  @override
  String get resetPasswordAnswer =>
      'To reset your password, go to profile and click on \'Reset Password\'.';

  @override
  String get howToListNewService => 'How do I list a new service?';

  @override
  String get listNewServiceAnswer =>
      'Create a service provider account, then access the dashboard to add new services.';

  @override
  String get canEditOrDeleteService =>
      'Can I edit or delete a service I posted?';

  @override
  String get editOrDeleteServiceAnswer =>
      'It is possible to edit and delete services in the dashboard.';

  @override
  String get whatHappensAfterServiceRequest =>
      'What happens after I receive a service request?';

  @override
  String get viewRequestsAnswer => 'You can view requests in the dashboard.';

  @override
  String get howDoIDeleteMyAccount => 'How do I delete my account?';

  @override
  String get deleteAccountAnswer =>
      'Delete your account option is present at the bottom of profile.';

  @override
  String get submitATicket => 'Submit a Ticket';

  @override
  String get whatsYourIssueAbout => 'What\'s Your Issue About?';

  @override
  String get selectIssue => 'Select Issue';

  @override
  String get paymentProblem => 'Payment Problem';

  @override
  String get technicalError => 'Technical Error';

  @override
  String get accountIssue => 'Account Issue';

  @override
  String get describeYourIssueHere => 'Describe your issue here...';

  @override
  String get submitTicket => 'Submit Ticket';

  @override
  String get verifyPhoneNumber => 'Verify Phone Number';

  @override
  String enter6DigitCode(String phoneNumber) {
    return 'Enter the 6-digit code sent to\n$phoneNumber';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get verify => 'Verify';

  @override
  String get noChangesDetected => 'No changes detected';

  @override
  String get otpResentSuccessfully => 'OTP resent successfully';

  @override
  String errorRequestingOtp(String error) {
    return 'Error requesting OTP: $error';
  }

  @override
  String errorVerifyingOtp(String error) {
    return 'Error verifying OTP: $error';
  }

  @override
  String failedToUpdateSetting(String error) {
    return 'Failed to update setting: $error';
  }

  @override
  String get myReviews => 'My Reviews';

  @override
  String totalReviews(int count) {
    return 'Total Reviews: $count';
  }

  @override
  String get errorLoadingReviews => 'Error loading reviews';

  @override
  String get reviewsWillAppearHere =>
      'Reviews will appear here when you receive them.';

  @override
  String reviewsFor(String objectName) {
    return 'Reviews for $objectName';
  }

  @override
  String get failedToLoadReviews => 'Failed to load reviews';

  @override
  String beFirstToReview(String table) {
    return 'Be the first to review this $table!';
  }

  @override
  String reviewCount(int count) {
    return '$count Review';
  }

  @override
  String reviewCountPlural(int count) {
    return '$count Reviews';
  }

  @override
  String get loadMoreReviews => 'Load More Reviews';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get tapToRate => 'Tap to rate';

  @override
  String star(int count) {
    return '$count star';
  }

  @override
  String stars(int count) {
    return '$count stars';
  }

  @override
  String get shareExperienceWithAgent =>
      'Share your experience with this agent...';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get pleaseLoginToSubmitReview => 'Please log in to submit a review';

  @override
  String get reviewSubmittedSuccessfully => 'Review submitted successfully!';

  @override
  String get sessionExpired => 'Session expired. Please log in again.';

  @override
  String get pleaseLoginToAddListing => 'Please log in to add listings';

  @override
  String get alreadyReviewedAgent => 'You have already reviewed this agent';

  @override
  String get failedToSubmitReview => 'Failed to submit review';

  @override
  String networkErrorReview(String error) {
    return 'Network error: $error';
  }

  @override
  String get submitting => 'Submitting...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get reportReview => 'Report Review';

  @override
  String reportReviewBy(String reviewerName) {
    return 'Report review by: $reviewerName';
  }

  @override
  String get selectReasonForReportingReview =>
      'Please select a reason for reporting this review:';

  @override
  String get additionalDetailsOptionalReview =>
      'Additional details (optional):';

  @override
  String get provideAdditionalInformationReview =>
      'Provide additional information about why you are reporting this review...';

  @override
  String get pleaseSelectReasonForReportingReview =>
      'Please select a reason for reporting';

  @override
  String errorSubmittingReviewReport(String error) {
    return 'Error submitting report: $error';
  }

  @override
  String get reportThisReview => 'Report this review';

  @override
  String get reviews => 'Reviews';

  @override
  String seeAllReviews(int count) {
    return 'See All $count Reviews';
  }

  @override
  String get noReviewsAvailable => 'No reviews available';

  @override
  String get serviceProviderNoReviewsYet =>
      'This service provider hasn\'t received any reviews yet';

  @override
  String get agentNoReviewsYet => 'This agent hasn\'t received any reviews yet';

  @override
  String get noListingsAvailable => 'No listings available';

  @override
  String get agentNoListingsYet =>
      'This agent hasn\'t posted any properties yet';

  @override
  String get reportThisJob => 'Report this job';

  @override
  String get reportThisJobTooltip => 'Report this job';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get jobDescription => 'Job Description';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get experienceRequired => 'Experience Required';

  @override
  String get skills => 'Skills';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get attendance => 'Attendance';

  @override
  String get jobType => 'Job Type';

  @override
  String get applicationForm => 'Application Form';

  @override
  String get uploadPortfolioOptional => 'Upload Portfolio (Optional)';

  @override
  String get expectedSalary => 'Expected Salary';

  @override
  String get iConfirmInformationAccurate =>
      'I Confirm That The Submitted Information Is Accurate';

  @override
  String get apply => 'Apply';

  @override
  String get pleaseConfirmInformationAccurate =>
      'Please confirm that the submitted information is accurate';

  @override
  String get signInRequired => 'Sign In Required';

  @override
  String get signInRequiredToApply =>
      'You need to be signed in to apply to jobs. Please sign in and try again.';

  @override
  String get applicationSubmitted => 'Application Submitted';

  @override
  String get applicationSubmittedSuccessfully =>
      'Your application has been submitted successfully!';

  @override
  String get alreadyApplied => 'Already Applied';

  @override
  String get alreadyAppliedToJob => 'You have already applied to this job.';

  @override
  String get failedToSubmitApplication =>
      'Failed to submit application. Please try again.';

  @override
  String errorPickingFile(String error) {
    return 'Error picking file: $error';
  }

  @override
  String get reportJob => 'Report Job';

  @override
  String reportJobTitle(String jobTitle) {
    return 'Report: $jobTitle';
  }

  @override
  String get selectReasonForReportingJob =>
      'Please select a reason for reporting this job:';

  @override
  String get additionalDetailsAboutReportingJob =>
      'Provide additional information about why you are reporting this job...';

  @override
  String get benefits => 'Benefits';

  @override
  String get addNewBuilding => 'Add New Building';

  @override
  String get addNewLand => 'Add New Land';

  @override
  String get addNewProperty => 'Add New Property';

  @override
  String get beforeYouList => 'Before You List';

  @override
  String get beforeYouListSubtitle =>
      'Let us know if you\'re the owner of the property or an agent listing on someone\'s behalf.';

  @override
  String get iAm => 'I am..';

  @override
  String get select => 'Select';

  @override
  String get back => 'Back';

  @override
  String get listYourProperty => 'List Your Property';

  @override
  String get forRent => 'For Rent';

  @override
  String get forSale => 'For Sale';

  @override
  String get listingType => 'Listing Type';

  @override
  String get selectType => 'Select Type';

  @override
  String get rentalPeriod => 'Rental Period';

  @override
  String get clear => 'Clear';

  @override
  String get editPropertyDetails => 'Edit Property Details';

  @override
  String get addPropertyDetails => 'Add Property Details';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get propertyTitle => 'Property Title';

  @override
  String get enterPropertyTitle => 'Enter property title';

  @override
  String get titleIsRequired => 'Title is required';

  @override
  String get describeYourProperty => 'Describe your property';

  @override
  String get city => 'City';

  @override
  String get enterCity => 'Enter city';

  @override
  String get cityIsRequired => 'City is required';

  @override
  String get rentalPrice => 'Rental Price';

  @override
  String get salePrice => 'Sale Price';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get priceIsRequired => 'Price is required';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get sizeSqFt => 'Size (sq meters)';

  @override
  String get floor => 'Floor';

  @override
  String get ground => 'Ground';

  @override
  String get buildingAgeYears => 'Building Age (years)';

  @override
  String get condition => 'Condition';

  @override
  String get papers => 'Papers';

  @override
  String get propertyImages => 'Property Images';

  @override
  String imagesCounter(int count) {
    return '$count/10 images';
  }

  @override
  String get maxImagesReached => 'Maximum images reached (10/10)';

  @override
  String get tapToAddImages => 'Tap to add images';

  @override
  String get amenities => 'Amenities';

  @override
  String get updateListing => 'Update Listing';

  @override
  String get createListing => 'Create Listing';

  @override
  String get listingUpdatedSuccessfully => 'Listing updated successfully!';

  @override
  String get failedToUpdateListing =>
      'Failed to update listing. Please try again.';

  @override
  String get listingCreatedSuccessfully => 'Listing created successfully!';

  @override
  String get failedToCreateListing =>
      'Failed to create listing. Please try again.';

  @override
  String errorPickingImages(String error) {
    return 'Error picking images: $error';
  }

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get amenityFurnished => 'Furnished';

  @override
  String get amenityTerrace => 'Terrace';

  @override
  String get amenityPrivatePool => 'Private Pool';

  @override
  String get amenityStorageRoom => 'Storage Room';

  @override
  String get amenitySharedPool => 'Shared Pool';

  @override
  String get amenitySharedGym => 'Shared Gym';

  @override
  String get amenitySecurity => 'Security';

  @override
  String get amenitySeaView => 'Sea View';

  @override
  String get amenityGarden => 'Garden';

  @override
  String get amenityMountainView => 'Mountain View';

  @override
  String get amenityElevator => 'Elevator';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityCentralAC => 'Central AC';

  @override
  String get amenityHeating => 'Heating';

  @override
  String get amenitySolarSystem => 'Solar System';

  @override
  String get amenityElectricity247 => '24/7 Electricity';

  @override
  String get amenityMaidRoom => 'Maid Room';

  @override
  String get conditionNew => 'New';

  @override
  String get conditionExcellent => 'Excellent';

  @override
  String get conditionGood => 'Good';

  @override
  String get conditionNeedsRenovation => 'Needs Renovation';

  @override
  String get conditionOld => 'Old';

  @override
  String get papersTitleDeed => 'Title Deed';

  @override
  String get papersRentalContract => 'Rental Contract';

  @override
  String get papersUnderConstruction => 'Under Construction';

  @override
  String get papersOther => 'Other';

  @override
  String get propertyOwner => 'Property Owner';

  @override
  String get propertyTypeApartment => 'Apartment';

  @override
  String get propertyTypeChalet => 'Chalet';

  @override
  String get propertyTypeStudio => 'Studio';

  @override
  String get propertyTypeCommercial => 'Commercial';

  @override
  String get propertyTypeVilla => 'Villa';

  @override
  String get propertyTypeLand => 'Land';

  @override
  String get propertyTypeIndustrial => 'Industrial';

  @override
  String get propertyTypeRoom => 'Room';

  @override
  String get propertyTypeBuilding => 'Building';

  @override
  String get propertyTypeInternational => 'International';

  @override
  String get rentalPeriodDaily => 'Daily';

  @override
  String get rentalPeriodMonthly => 'Monthly';

  @override
  String get rentalPeriodYearly => 'Yearly';

  @override
  String get searchResultsTitle => 'Search Results';

  @override
  String get searchPropertiesHint => 'Search properties...';

  @override
  String get searchAction => 'Search';

  @override
  String get noResultsFound => 'No results found';

  @override
  String errorSearching(String error) {
    return 'Error searching: $error';
  }

  @override
  String searchTitleWithQuery(String query) {
    return 'Search: $query';
  }

  @override
  String failedToLoadSearchResults(String error) {
    return 'Failed to load search results: $error';
  }

  @override
  String get contactSupportTitle => 'Contact Support';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get weWillGetBackSoon => 'We\'ll get back to you as soon as possible.';

  @override
  String get fillFormAndWeWillGetBack =>
      'Fill out the form below and we\'ll get back to you.';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get emailAddressRequiredLabel => 'Email Address *';

  @override
  String get enterYourEmailAddress => 'Enter your email address';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get pleaseEnterValidEmailAddress =>
      'Please enter a valid email address';

  @override
  String get phoneNumberRequiredLabel => 'Phone Number *';

  @override
  String get enterYourPhoneNumberText => 'Enter your phone number';

  @override
  String get phoneNumberIsRequired => 'Phone number is required';

  @override
  String get message => 'Message';

  @override
  String get describeIssueOrQuestionRequiredLabel =>
      'Describe your issue or question *';

  @override
  String get describeIssueOrQuestionHint =>
      'Please provide as much details as possible about your issue or question...';

  @override
  String get messageIsRequired => 'Message is required';

  @override
  String get messageMinLength => 'Message must be at least 10 characters long';

  @override
  String get messageMaxLength => 'Message must be less than 5000 characters';

  @override
  String get ticketSubmittedSuccessfully => 'Ticket submitted successfully';

  @override
  String get failedToSubmitTicket => 'Failed to submit ticket';

  @override
  String errorOccurredWithDetails(String error) {
    return 'An error occurred: $error';
  }

  @override
  String emailLabelWithValue(String email) {
    return 'Email: $email';
  }

  @override
  String phoneLabelWithValue(String phone) {
    return 'Phone: $phone';
  }

  @override
  String get supportResponseNote =>
      'We typically respond within 48 hours. For urgent issues, please call our support line. You may only send one ticket per day.';
}
