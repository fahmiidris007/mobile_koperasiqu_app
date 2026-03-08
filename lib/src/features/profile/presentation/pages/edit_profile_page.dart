import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final data = ref.read(registrationProvider).data;
    _nameController = TextEditingController(
      text: data.fullName.isNotEmpty ? data.fullName : 'Ahmad Fahmi',
    );
    _phoneController = TextEditingController(
      text: data.phone.isNotEmpty ? data.phone : '081234567890',
    );
    _emailController = TextEditingController(
      text: data.email.isNotEmpty ? data.email : 'ahmad@email.com',
    );
    _occupationController = TextEditingController(
      text: data.occupation.isNotEmpty ? data.occupation : '',
    );
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
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
                        color: Colors.white,
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
                                    : 'AF',
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
                              color: AppColors.teal,
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

                      const SizedBox(height: 28),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _isSaving ? null : _saveChanges,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.55),
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal),
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
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
