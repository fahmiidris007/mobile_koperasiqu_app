/// All API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String verifyLoginOtp = '/login/verify-otp';
  static const String logout = '/logout';

  // OTP (register verification)
  static const String sendOtp = '/otp/send';
  static const String verifyOtp = '/otp/verify';
  static const String resendOtp = '/otp/resend';

  // User
  static const String user = '/user';
  static const String userStats = '/user/stats';

  // Password reset
  static const String forgotPassword = '/password/forgot';
  static const String resetPassword = '/password/reset';
}
