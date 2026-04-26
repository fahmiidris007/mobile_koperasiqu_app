import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../data/datasources/user_datasource.dart';
import '../providers/user_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _occupationController;
  bool _isSaving = false;
  bool _initialized = false;
  bool _is2faEnabled = false;

  /// Dipanggil setelah userProvider selesai load
  void _initControllers(String name, String phone, String email, bool is2fa) {
    if (_initialized) return;
    _initialized = true;
    _nameController = TextEditingController(text: name);
    _phoneController = TextEditingController(text: phone);
    _emailController = TextEditingController(text: email);
    _occupationController = TextEditingController();
    _is2faEnabled = is2fa;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _occupationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      // Panggil datasource langsung — hindari autoDispose race condition
      await UserDatasource().updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        is2faEnabled: _is2faEnabled,
      );
      if (!mounted) return;
      // Invalidate agar profile page reload data terbaru
      ref.invalidate(userProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const GradientBackground(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => GradientBackground(
        child: Center(
          child: Text(
            'Gagal memuat data: $e',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
      data: (user) {
        // Isi controller dengan data user (hanya pertama kali)
        _initControllers(user.name, user.phone, user.email, user.is2faEnabled);

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
                          'Edit Profil',
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Center(
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text
                                              .split(' ')
                                              .take(2)
                                              .map((w) => w[0])
                                              .join()
                                              .toUpperCase()
                                        : user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 28),

                          // Form fields
                          GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: 20,
                            opacity: 0.12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Informasi Pribadi'),
                                const SizedBox(height: 16),
                                _ProfileField(
                                  controller: _nameController,
                                  label: 'Nama Lengkap',
                                  icon: Icons.person_outline,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  controller: _phoneController,
                                  label: 'Nomor HP',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Nomor HP tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Email tidak boleh kosong';
                                    if (!v.contains('@'))
                                      return 'Format email tidak valid';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 16),

                          GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: 20,
                            opacity: 0.12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Pekerjaan'),
                                const SizedBox(height: 16),
                                _ProfileField(
                                  controller: _occupationController,
                                  label: 'Pekerjaan',
                                  icon: Icons.work_outline,
                                ),
                              ],
                            ),
                          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 16),

                          // 2FA Toggle
                          GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: 20,
                            opacity: 0.12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('KEAMANAN AKUN'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.security_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Verifikasi Dua Langkah',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _is2faEnabled
                                                ? 'OTP wajib saat login'
                                                : 'Login langsung tanpa OTP',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _is2faEnabled,
                                      onChanged: (v) =>
                                          setState(() => _is2faEnabled = v),
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 28),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: _isSaving ? null : _saveChanges,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Simpan Perubahan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expense),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expense),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
