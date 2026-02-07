import 'package:intl/intl.dart';

/// Utility class for formatting values
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _currencyFormatCompact = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _timeFormat = DateFormat('HH:mm', 'id_ID');

  /// Format number as Indonesian Rupiah
  /// Example: 15750000 → "Rp 15.750.000"
  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount);
  }

  /// Format number as compact Indonesian Rupiah
  /// Example: 15750000 → "Rp 15,7 jt"
  static String formatCurrencyCompact(num amount) {
    return _currencyFormatCompact.format(amount);
  }

  /// Format date as Indonesian format
  /// Example: 2026-01-15 → "15 Jan 2026"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format datetime as Indonesian format
  /// Example: 2026-01-15 14:30 → "15 Jan 2026, 14:30"
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format time only
  /// Example: 14:30:00 → "14:30"
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format phone number for display
  /// Example: 081234567890 → "0812-3456-7890"
  static String formatPhoneNumber(String phone) {
    if (phone.length < 10) return phone;
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 12) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    } else if (cleaned.length == 11) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  /// Mask account number for display
  /// Example: 1234567890 → "•••• •••• 7890"
  static String maskAccountNumber(String account) {
    if (account.length < 4) return account;
    return '•••• •••• ${account.substring(account.length - 4)}';
  }

  /// Format percentage
  /// Example: 2.5 → "+2.5%"
  static String formatPercentage(double value, {bool showSign = true}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}
