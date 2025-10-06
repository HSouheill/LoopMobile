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
import 'screens/auth_pages/signup_pages/service_provider/service_provider_signup_1.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_signup_2.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_1.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_2.dart';
import 'screens/auth_pages/signup_pages/agent/real_estate_company_signup_3.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_company_signup_1.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_company_signup_2.dart';
import 'screens/auth_pages/signup_pages/service_provider/service_provider_company_signup_3.dart';
import 'screens/auth_pages/verify_otp.dart';
import 'screens/dashboards/dashboard.dart';
import 'screens/dashboards/agent_individual_dashboard.dart';
import 'screens/dashboards/agent_company_dashboard.dart';
import 'screens/dashboards/service_provider_individual_dashboard.dart';
import 'screens/dashboards/service_provider_company_dashboard.dart';
import 'screens/profile/profile.dart';
import 'screens/services/jobs.dart';
import 'screens/services/category_services_page.dart';
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
import 'screens/reviews/all_reviews_screen.dart';
import 'screens/search/search_results_page.dart';
import 'screens/search/advanced_filters_page.dart';

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
    '/serviceProviderSignup1': (_) => const ServiceProviderSignupPage1(),
    '/serviceProviderSignup2': (_) => const ServiceProviderSignupPage2(),
    '/realEstateCompanySignup1': (_) => const RealEstateCompanySignupPage1(),
    '/realEstateCompanySignup2': (_) => const RealEstateCompanySignupPage2(),
    '/realEstateCompanySignup3': (_) => const RealEstateCompanySignupPage3(),
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
    '/profile': (context) => const ProfileScreen(),
    '/jobs': (context) => const JobsPage(),
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
  };
}
