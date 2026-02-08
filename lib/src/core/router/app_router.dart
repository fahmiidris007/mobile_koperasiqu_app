import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/ekyc_page.dart';
import '../../features/auth/presentation/pages/pending_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/main_shell.dart';
import '../../features/savings/presentation/pages/savings_detail_page.dart';
import '../../features/savings/presentation/pages/deposit_page.dart';
import '../../features/savings/presentation/pages/withdrawal_page.dart';
import '../../features/shopping/presentation/pages/catalog_page.dart';
import '../../features/shopping/presentation/pages/product_detail_page.dart';
import '../../features/shopping/presentation/pages/checkout_page.dart';
import '../../features/ppob/presentation/pages/ppob_menu_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// App route paths
class Routes {
  Routes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String ekyc = '/ekyc';
  static const String pending = '/pending';

  static const String dashboard = '/dashboard';
  static const String savings = '/savings';
  static const String deposit = '/savings/deposit';
  static const String withdrawal = '/savings/withdrawal';
  static const String shopping = '/shopping';
  static const String productDetail = '/shopping/product/:id';
  static const String checkout = '/shopping/checkout';
  static const String ppob = '/ppob';
  static const String profile = '/profile';
}

/// App router configuration class
class AppRouter {
  AppRouter._();

  /// GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: Routes.ekyc, builder: (context, state) => const EkycPage()),
      GoRoute(
        path: Routes.pending,
        builder: (context, state) => const PendingPage(),
      ),

      // Main app with shell (bottom navigation)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: Routes.savings,
            builder: (context, state) => const SavingsDetailPage(),
          ),
          GoRoute(
            path: Routes.shopping,
            builder: (context, state) => const CatalogPage(),
          ),
          GoRoute(
            path: Routes.ppob,
            builder: (context, state) => const PpobMenuPage(),
          ),
        ],
      ),

      // Profile (without bottom navigation)
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfilePage(),
      ),

      // Deposit (without bottom navigation)
      GoRoute(
        path: Routes.deposit,
        builder: (context, state) => const DepositPage(),
      ),

      // Withdrawal (without bottom navigation)
      GoRoute(
        path: Routes.withdrawal,
        builder: (context, state) => const WithdrawalPage(),
      ),

      // Product detail (without bottom navigation)
      GoRoute(
        path: Routes.productDetail,
        builder: (context, state) {
          final id = state.extra as String;
          return ProductDetailPage(productId: id);
        },
      ),

      // Checkout (without bottom navigation)
      GoRoute(
        path: Routes.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
    ],
  );
}
