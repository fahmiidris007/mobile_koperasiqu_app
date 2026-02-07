/// Form validation utilities
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validate Indonesian phone number
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    // Remove non-digits
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Nomor HP harus 10-13 digit';
    }
    if (!cleaned.startsWith('0') && !cleaned.startsWith('62')) {
      return 'Nomor HP harus dimulai dengan 0 atau 62';
    }
    return null;
  }

  /// Validate NIK (16 digits)
  static String? nik(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK wajib diisi';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'NIK hanya boleh berisi angka';
    }
    return null;
  }

  /// Validate password (min 6 chars)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Validate minimum amount
  static String? minAmount(String? value, int minAmount) {
    if (value == null || value.isEmpty) {
      return 'Jumlah wajib diisi';
    }
    final amount = int.tryParse(value.replaceAll(RegExp(r'\D'), ''));
    if (amount == null || amount < minAmount) {
      return 'Minimal Rp ${minAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
    return null;
  }

  /// Validate name (no special chars)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }
}
