import 'package:flutter/widgets.dart';
import 'screens/auth_pages/login_landing.dart';
import 'screens/auth_pages/login_email.dart';
import 'screens/auth_pages/pre_login_page.dart';
import 'screens/auth_pages/forgot_password.dart'; // Import the new forgot password page
import 'screens/auth_pages/signup_pages/signup_options.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_landing.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_landing.dart';
import 'screens/auth_pages/signup_pages/user/user_signup_1.dart';
import 'screens/auth_pages/signup_pages/user/user_signup_2.dart';
import 'screens/auth_pages/signup_pages/user/user_signup_3.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_signup_1.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_signup_2.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_signup_3.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_signup_1.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_signup_2.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_1.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_2.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_3.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_4.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_company_signup_1.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_company_signup_2.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_company_signup_3.dart';
import 'screens/auth_pages/verify_otp.dart';
import 'screens/dashboards/dashboard.dart';
import 'screens/dashboards/agent_individual_dashboard.dart';
import 'screens/dashboards/agent_company_dashboard.dart';
import 'screens/dashboards/service_provider_individual_dashboard.dart';
import 'screens/dashboards/service_provider_company_dashboard.dart';
import 'screens/dashboards/applications_page.dart';
import 'screens/dashboards/my_jobs_page.dart';
import 'screens/profile/profile.dart';
import 'screens/services/jobs.dart';
import 'screens/services/category_services_page.dart';
import 'screens/services/category_jobs_page.dart';
import 'widgets/dynamic_jobs_widget.dart'; // For JobCategory enum
import 'services/service_service.dart';
import 'screens/listings/featured_listings_page.dart';
import 'screens/listings/listings.dart';
import 'screens/profile/help_and_support.dart';
import 'screens/profile/terms_and_conditions/terms_and_conditions.dart';
import 'screens/profile/favorites.dart';
import 'screens/profile/referrals.dart';
import 'screens/profile/profile-dashboard.dart';
import 'screens/dashboards/service_provider_individual_dashboard_screens/edit_my_service.dart';
import 'screens/dashboards/service_provider_individual_dashboard_screens/add_service.dart';
import 'screens/dashboards/agent_individual_dashboard_screens/inactive_listings_screen.dart';
import 'screens/dashboards/agent_company_dashboard_screens/add_new_agent_screen.dart';
import 'screens/dashboards/my_agents_page.dart';
import 'screens/reviews/all_reviews_screen.dart';
import 'screens/reviews/all_reviews_page.dart';
import 'screens/search/search_results_page.dart';
import 'screens/search/advanced_filters_page.dart';
import 'screens/add_listing/property_type_selection_page.dart';
import 'screens/add_listing/add_listing_form_page.dart';
import 'screens/chat/chat.dart';
import 'screens/chat/chat_list_page.dart';
import 'screens/chat/blocked_users_page.dart';
import 'screens/listings/inactive_listings_page.dart';
import 'screens/listings/my_listings_page.dart';
import 'widgets/contact_support_form.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/loginLanding': (_) => const LoginLandingPage(),
    '/loginEmail': (_) => const LoginEmailPage(),
    '/preLogin': (context) => const PreLoginPage(),
    '/forgotPassword': (_) => const ForgotPasswordPage(), // Add the new route
    '/signupOptions': (_) => const SignupOptionsPage(),
    '/realEstateLanding': (_) => const RealEstateLandingPage(),
    '/serviceProviderLanding': (_) => const ServiceProviderLandingPage(),
    '/userSignup1': (_) => const UserSignupPage1(),
    '/userSignup2': (_) => const UserSignupPage2(),
    '/userSignup3': (_) => const UserSignupPage3(),
    '/realEstateSignup1': (_) => const RealEstateSignupPage1(),
    '/realEstateSignup2': (_) => const RealEstateSignupPage2(),
    '/realEstateSignup3': (_) => const RealEstateSignupPage3(),
    '/serviceProviderSignup1': (_) => const ServiceProviderSignupPage1(),
    '/serviceProviderSignup2': (_) => const ServiceProviderSignupPage2(),
    '/realEstateCompanySignup1': (_) => const RealEstateCompanySignupPage1(),
    '/realEstateCompanySignup2': (_) => const RealEstateCompanySignupPage2(),
    '/realEstateCompanySignup3': (_) => const RealEstateCompanySignupPage3(),
    '/realEstateCompanySignup4': (_) => const RealEstateCompanySignupPage4(),
    '/serviceProviderCompanySignup1': (_) =>
        const ServiceProviderCompanySignupPage1(),
    '/serviceProviderCompanySignup2': (_) =>
        const ServiceProviderCompanySignupPage2(),
    '/serviceProviderCompanySignup3': (_) =>
        const ServiceProviderCompanySignupPage3(),
    '/verifyOtp': (_) => const VerifyOtpPage(),
    '/dashboard': (context) => const DashboardPage(),
    '/agent-individual-dashboard': (context) =>
        const AgentIndividualDashboardPage(),
    '/agent-company-dashboard': (context) => const AgentCompanyDashboardPage(),
    '/service-provider-individual-dashboard': (context) =>
        const ServiceProviderIndividualDashboardPage(),
    '/service-provider-company-dashboard': (context) =>
        const ServiceProviderCompanyDashboardPage(),
    '/my-jobs': (context) => const MyJobsPage(),
    '/profile': (context) => const ProfileScreen(),
    '/jobs': (context) => const JobsPage(),
    '/featured-jobs': (context) =>
        const CategoryJobsPage(category: JobCategory.featured),
    '/for-you-jobs': (context) =>
        const CategoryJobsPage(category: JobCategory.forYou),
    '/recent-jobs': (context) =>
        const CategoryJobsPage(category: JobCategory.recent),
    '/featured-services': (context) =>
        const CategoryServicesPage(category: ServiceCategory.featured),
    '/top-rated-services': (context) =>
        const CategoryServicesPage(category: ServiceCategory.topRated),
    '/company-services': (context) =>
        const CategoryServicesPage(category: ServiceCategory.companies),
    '/individual-services': (context) =>
        const CategoryServicesPage(category: ServiceCategory.individual),
    '/featured-listings': (context) => const FeaturedListingsPage(),
    '/listings': (context) => const ListingsPage(),
    '/help-and-support': (context) => const HelpAndSupportPage(),
    '/terms-and-conditions': (context) => const TermsAndConditionsPage(),
    '/favorites': (context) => const FavoritesPage(),
    '/referrals': (context) => const ReferralsPage(),
    '/profile-dashboard': (context) => const ProfileDashboardPage(),
    '/edit-my-service': (context) => const EditMyService(),
    '/add-service': (context) => const AddService(),
    '/inactive-listings': (context) => const InactiveListings(),
    '/add-new-agent': (context) => const AddNewAgentScreen(),
    '/all-reviews': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return AllReviewsScreen(
        objectId: args['objectId'],
        table: args['table'],
        objectName: args['objectName'],
      );
    },
    '/my-reviews': (_) => const AllReviewsPage(),
    '/search-results': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return SearchResultsPage(
        initialQuery: args?['query'],
        initialCategory: args?['category'],
        initialFilters: args?['filters'],
      );
    },
    '/advanced-filters': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return AdvancedFiltersPage(
        initialQuery: args?['query'] ?? '',
        initialFilters: args?['filters'],
      );
    },
    '/property-type-selection': (_) => const PropertyTypeSelectionPage(),
    '/add-listing-form': (_) => const AddListingFormPage(),
    '/chat': (_) => const ChatPage(),
    '/chat-list': (_) => const ChatListPage(),
    '/blocked-users': (_) => const BlockedUsersPage(),
    '/inactive-listings-page': (_) => const InactiveListingsPage(),
    '/my-listings-page': (_) => const MyListingsPage(),
    '/my-agents-page': (_) => const MyAgentsPage(),
    '/applications': (_) => const ApplicationsPage(),
    '/contact-support': (_) => const ContactSupportForm(),
  };
}
