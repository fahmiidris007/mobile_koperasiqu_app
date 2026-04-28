import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/ekyc_page.dart';
import '../../features/auth/presentation/pages/verify_register_otp_page.dart';
import '../../features/auth/presentation/pages/pending_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/main_shell.dart';
import '../../features/savings/presentation/pages/savings_detail_page.dart';
import '../../features/savings/presentation/pages/deposit_page.dart';
import '../../features/savings/presentation/pages/upload_payment_proof_page.dart';
import '../../features/savings/presentation/pages/withdrawal_page.dart';
import '../../features/savings/presentation/pages/transaction_detail_page.dart';
import '../../features/savings/domain/entities/wallet_transaction.dart';
import '../../features/shopping/presentation/pages/catalog_page.dart';
import '../../features/shopping/presentation/pages/product_detail_page.dart';
import '../../features/shopping/presentation/pages/wishlist_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/account_security_page.dart';
import '../../features/profile/presentation/pages/two_factor_auth_page.dart';
import '../../features/savings/presentation/pages/transaction_history_page.dart';
import '../../features/dashboard/presentation/pages/notification_page.dart';

/// App route paths
class Routes {
  Routes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String ekyc = '/ekyc';
  static const String verifyRegisterOtp = '/verify-register-otp';
  static const String pending = '/pending';

  static const String dashboard = '/dashboard';
  static const String savings = '/savings';
  static const String deposit = '/savings/deposit';
  static const String depositProof = '/savings/deposit/proof';
  static const String withdrawal = '/savings/withdrawal';
  static const String shopping = '/shopping';
  static const String wishlist = '/shopping/wishlist';
  static const String productDetail = '/shopping/product/:id';
  static const String checkout = '/shopping/checkout';
  static const String ppob = '/ppob';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String accountSecurity = '/profile/security';
  static const String twoFactorAuth = '/profile/security/2fa';
  static const String forgotPassword = '/forgot-password';
  static const String transactionHistory = '/savings/history';
  static const String transactionDetail = '/savings/history/detail';
  static const String notifications = '/notifications';
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
        path: Routes.verifyRegisterOtp,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyRegisterOtpPage(email: email);
        },
      ),
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
            path: Routes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          // GoRoute(
          //   path: Routes.ppob,
          //   builder: (context, state) => const PpobMenuPage(),
          // ),
        ],
      ),

      // Deposit (without bottom navigation)
      GoRoute(
        path: Routes.deposit,
        builder: (context, state) => const DepositPage(),
      ),

      // Upload payment proof — step 2 of deposit flow
      GoRoute(
        path: Routes.depositProof,
        builder: (context, state) {
          final amount = state.extra as int? ?? 0;
          return UploadPaymentProofPage(amount: amount);
        },
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

      // Wishlist page (without bottom navigation)
      GoRoute(
        path: Routes.wishlist,
        builder: (context, state) => const WishlistPage(),
      ),

      // Transaction history (without bottom navigation)
      GoRoute(
        path: Routes.transactionHistory,
        builder: (context, state) => const TransactionHistoryPage(),
      ),

      // Notification page (without bottom navigation)
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationPage(),
      ),

      // Edit profile (without bottom navigation)
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),

      // Account security (without bottom navigation)
      GoRoute(
        path: Routes.accountSecurity,
        builder: (context, state) => const AccountSecurityPage(),
      ),

      // Two Factor Auth (without bottom navigation)
      GoRoute(
        path: Routes.twoFactorAuth,
        builder: (context, state) => const TwoFactorAuthPage(),
      ),

      // Forgot Password (without bottom navigation)
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Transaction Detail (without bottom navigation)
      GoRoute(
        path: Routes.transactionDetail,
        builder: (context, state) {
          final tx = state.extra as WalletTransaction;
          return TransactionDetailPage(transaction: tx);
        },
      ),

      // Checkout (without bottom navigation) - DISABLED (replaced by wishlist)
      // GoRoute(
      //   path: Routes.checkout,
      //   builder: (context, state) => const CheckoutPage(),
      // ),
    ],
  );
}
