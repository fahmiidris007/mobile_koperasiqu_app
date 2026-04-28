import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/validators.dart';
import '../../data/datasources/password_datasource.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  bool _biometricEnabled = false;
  bool _loginNotifEnabled = true;
  bool _transactionNotifEnabled = true;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Keamanan Akun',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Security score card
                    // GlassContainer(
                    //   padding: const EdgeInsets.all(20),
                    //   borderRadius: 20,
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         width: 56,
                    //         height: 56,
                    //         decoration: BoxDecoration(
                    //           gradient: AppColors.primaryGradient,
                    //           borderRadius: BorderRadius.circular(16),
                    //         ),
                    //         child: const Icon(
                    //           Icons.shield_rounded,
                    //           color: Colors.white,
                    //           size: 28,
                    //         ),
                    //       ),
                    //       const SizedBox(width: 16),
                    //       Expanded(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             const Text(
                    //               'Keamanan Sedang',
                    //               style: TextStyle(
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(
                    //               'Aktifkan biometrik untuk keamanan lebih baik',
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Colors.white.withOpacity(0.6),
                    //               ),
                    //             ),
                    //             const SizedBox(height: 8),
                    //             ClipRRect(
                    //               borderRadius: BorderRadius.circular(4),
                    //               child: LinearProgressIndicator(
                    //                 value: 0.6,
                    //                 backgroundColor: Colors.white.withOpacity(
                    //                   0.1,
                    //                 ),
                    //                 valueColor: AlwaysStoppedAnimation<Color>(
                    //                   AppColors.warning,
                    //                 ),
                    //                 minHeight: 6,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ).animate().fadeIn(duration: 400.ms),
                    // const SizedBox(height: 20),

                    // Password section
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      borderRadius: 20,
                      opacity: 0.12,
                      child: Column(
                        children: [
                          _SecurityAction(
                            icon: Icons.lock_outline,
                            iconColor: Colors.blue,
                            title: 'Ubah Password',
                            subtitle: 'Ganti password akun Anda',
                            onTap: () => _showChangePasswordSheet(context),
                          ),
                          _Divider(),
                          _SecurityAction(
                            icon: Icons.security_rounded,
                            iconColor: AppColors.primary,
                            title: 'Verifikasi Dua Langkah (2FA)',
                            subtitle: 'Kelola keamanan login dengan OTP',
                            onTap: () => context.push(Routes.twoFactorAuth),
                          ),
                          // _Divider(),
                          // _SecurityAction(
                          //   icon: Icons.pin_outlined,
                          //   iconColor: Colors.purple,
                          //   title: 'Ubah M-PIN',
                          //   subtitle: 'PIN transaksi 6 digit',
                          //   onTap: () => _showChangePinSheet(context),
                          // ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 16),

                    // Biometric & notifications section
                    // GlassContainer(
                    //   padding: const EdgeInsets.symmetric(vertical: 8),
                    //   borderRadius: 20,
                    //   opacity: 0.12,
                    //   child: Column(
                    //     children: [
                    //       _SecurityToggle(
                    //         icon: Icons.fingerprint,
                    //         iconColor: AppColors.success,
                    //         title: 'Login Biometrik',
                    //         subtitle: 'Gunakan sidik jari / Face ID',
                    //         value: _biometricEnabled,
                    //         onChanged: (v) =>
                    //             setState(() => _biometricEnabled = v),
                    //       ),
                    //       _Divider(),
                    //       _SecurityToggle(
                    //         icon: Icons.notifications_active_outlined,
                    //         iconColor: Colors.orange,
                    //         title: 'Notif Login Baru',
                    //         subtitle:
                    //             'Notifikasi saat ada login dari perangkat baru',
                    //         value: _loginNotifEnabled,
                    //         onChanged: (v) =>
                    //             setState(() => _loginNotifEnabled = v),
                    //       ),
                    //       _Divider(),
                    //       _SecurityToggle(
                    //         icon: Icons.receipt_long_outlined,
                    //         iconColor: Colors.teal,
                    //         title: 'Notif Transaksi',
                    //         subtitle: 'Notifikasi setiap transaksi berhasil',
                    //         value: _transactionNotifEnabled,
                    //         onChanged: (v) =>
                    //             setState(() => _transactionNotifEnabled = v),
                    //       ),
                    //     ],
                    //   ),
                    // ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                    // const SizedBox(height: 16),

                    // Danger zone
                    // GlassContainer(
                    //   padding: const EdgeInsets.symmetric(vertical: 8),
                    //   borderRadius: 20,
                    //   opacity: 0.12,
                    //   child: Column(
                    //     children: [
                    //       // _SecurityAction(
                    //       //   icon: Icons.devices_outlined,
                    //       //   iconColor: Colors.blue,
                    //       //   title: 'Kelola Perangkat',
                    //       //   subtitle: '1 perangkat aktif',
                    //       //   onTap: () => _showSnack('Fitur segera hadir'),
                    //       // ),
                    //       // _Divider(),
                    //       // _SecurityAction(
                    //       //   icon: Icons.history_toggle_off,
                    //       //   iconColor: Colors.orange,
                    //       //   title: 'Riwayat Login',
                    //       //   subtitle: 'Lihat aktivitas login terakhir',
                    //       //   onTap: () => _showSnack('Fitur segera hadir'),
                    //       // ),
                    //       // _Divider(),
                    //       _SecurityAction(
                    //         icon: Icons.block_outlined,
                    //         iconColor: AppColors.expense,
                    //         title: 'Nonaktifkan Akun',
                    //         subtitle: 'Akun tidak dapat digunakan sementara',
                    //         onTap: () => _showDeactivateDialog(context),
                    //       ),
                    //     ],
                    //   ),
                    // ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _PasswordSheet(
        title: 'Ubah Password',
        currentCtrl: currentCtrl,
        newCtrl: newCtrl,
        confirmCtrl: confirmCtrl,
        onSave: () async {
          if (newCtrl.text != confirmCtrl.text) {
            ScaffoldMessenger.of(sheetCtx).showSnackBar(
              const SnackBar(
                content: Text('Konfirmasi password tidak cocok'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          try {
            await PasswordDatasource().changePassword(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
              newPasswordConfirmation: confirmCtrl.text,
            );
            if (!context.mounted) return;
            Navigator.pop(sheetCtx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password berhasil diubah'),
                backgroundColor: AppColors.success,
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(sheetCtx).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showChangePinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PinSheet(
        onSave: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('M-PIN berhasil diubah'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nonaktifkan Akun?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Akun Anda akan dinonaktifkan sementara. Anda tidak dapat melakukan transaksi sampai akun diaktifkan kembali.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Fitur segera hadir');
            },
            child: const Text(
              'Nonaktifkan',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: AppColors.accentLight,
    );
  }
}

class _SecurityAction extends StatelessWidget {
  const _SecurityAction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityToggle extends StatelessWidget {
  const _SecurityToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.accentLight,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Bottom sheets ---

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet({
    required this.title,
    required this.currentCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.onSave,
  });

  final String title;
  final TextEditingController currentCtrl;
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;
  final VoidCallback onSave;

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(
            controller: widget.currentCtrl,
            label: 'Password Saat Ini',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: widget.newCtrl,
            label: 'Password Baru',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: widget.confirmCtrl,
            label: 'Konfirmasi Password Baru',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: widget.onSave,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.backgroundAlt,
      ),
    );
  }
}

class _PinSheet extends StatefulWidget {
  const _PinSheet({required this.onSave});
  final VoidCallback onSave;

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _currentPin = List.generate(6, (_) => TextEditingController());
  final _newPin = List.generate(6, (_) => TextEditingController());
  int _step = 0; // 0=current, 1=new

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _step == 0 ? 'Masukkan PIN Saat Ini' : 'Masukkan PIN Baru',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PIN 6 digit untuk transaksi',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (i) {
              final ctrl = _step == 0 ? _currentPin[i] : _newPin[i];
              return SizedBox(
                width: 44,
                child: TextField(
                  controller: ctrl,
                  obscureText: true,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.accentLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundAlt,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                if (_step == 0) {
                  setState(() => _step = 1);
                } else {
                  widget.onSave();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _step == 0 ? 'Lanjut' : 'Simpan PIN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
