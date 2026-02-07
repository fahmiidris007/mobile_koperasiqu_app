import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/registration_data.dart';
import '../providers/auth_provider.dart';
import '../widgets/step_indicator.dart';

/// Multi-step registration page
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Step 1 controllers
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthDate;
  Gender? _gender;

  // Step 2 controllers
  final _occupationController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  int _monthlyIncome = 0;

  // Step 3 controllers
  MaritalStatus? _maritalStatus;
  final _spouseNameController = TextEditingController();
  int _numberOfChildren = 0;
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _spouseNameController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  void _updateRegistrationData() {
    ref
        .read(registrationProvider.notifier)
        .updateData(
          RegistrationData(
            fullName: _nameController.text,
            nik: _nikController.text,
            birthDate: _birthDate,
            gender: _gender,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            occupation: _occupationController.text,
            companyName: _companyController.text,
            jobPosition: _positionController.text,
            monthlyIncome: _monthlyIncome,
            maritalStatus: _maritalStatus,
            spouseName: _spouseNameController.text,
            numberOfChildren: _numberOfChildren,
            emergencyContactName: _emergencyContactNameController.text,
            emergencyContactPhone: _emergencyContactPhoneController.text,
          ),
        );
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;

    _updateRegistrationData();

    final currentStep = ref.read(registrationProvider).data.currentStep;

    if (currentStep < 2) {
      ref.read(registrationProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last step, go to EKYC
      context.push(Routes.ekyc);
    }
  }

  void _previousStep() {
    final currentStep = ref.read(registrationProvider).data.currentStep;

    if (currentStep > 0) {
      ref.read(registrationProvider.notifier).previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              surface: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registrationProvider);
    final currentStep = regState.data.currentStep;

    return GradientBackground(
      animate: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Pendaftaran Anggota',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StepIndicator(
              currentStep: currentStep,
              steps: const ['Data Diri', 'Pekerjaan', 'Keluarga', 'Dokumen'],
            ),
          ),

          const SizedBox(height: 24),

          // Form pages
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(24),
            child: GlassButton(
              text: currentStep < 2 ? 'Lanjut' : 'Verifikasi Identitas',
              icon: currentStep < 2 ? Icons.arrow_forward : Icons.verified_user,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Diri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person, color: Colors.white70),
              ),
              validator: Validators.name,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nikController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'NIK',
                prefixIcon: Icon(Icons.badge, color: Colors.white70),
                counterText: '',
              ),
              validator: Validators.nik,
            ),
            const SizedBox(height: 16),

            // Birth date picker
            GestureDetector(
              onTap: _selectBirthDate,
              child: AbsorbPointer(
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                    ),
                    hintText: _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : 'Pilih tanggal',
                  ),
                  controller: TextEditingController(
                    text: _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : '',
                  ),
                  validator: (v) =>
                      _birthDate == null ? 'Tanggal lahir wajib diisi' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender dropdown
            DropdownButtonFormField<Gender>(
              initialValue: _gender,
              dropdownColor: const Color(0xFF1E3A5F),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                prefixIcon: Icon(Icons.wc, color: Colors.white70),
              ),
              items: Gender.values.map((g) {
                return DropdownMenuItem(value: g, child: Text(g.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _gender = v),
              validator: (v) =>
                  v == null ? 'Jenis kelamin wajib dipilih' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Colors.white70),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                prefixIcon: Icon(Icons.phone, color: Colors.white70),
              ),
              validator: Validators.phoneNumber,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: Colors.white70),
              ),
              validator: Validators.password,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pekerjaan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _occupationController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Pekerjaan',
                prefixIcon: Icon(Icons.work, color: Colors.white70),
              ),
              validator: (v) => Validators.required(v, 'Pekerjaan'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _companyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nama Perusahaan (opsional)',
                prefixIcon: Icon(Icons.business, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _positionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Jabatan (opsional)',
                prefixIcon: Icon(Icons.assignment_ind, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),

            // Income selector
            const Text(
              'Pendapatan Bulanan',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _IncomeChip(
                  label: '< 3 Juta',
                  value: 3000000,
                  isSelected: _monthlyIncome == 3000000,
                  onTap: () => setState(() => _monthlyIncome = 3000000),
                ),
                _IncomeChip(
                  label: '3-5 Juta',
                  value: 5000000,
                  isSelected: _monthlyIncome == 5000000,
                  onTap: () => setState(() => _monthlyIncome = 5000000),
                ),
                _IncomeChip(
                  label: '5-10 Juta',
                  value: 10000000,
                  isSelected: _monthlyIncome == 10000000,
                  onTap: () => setState(() => _monthlyIncome = 10000000),
                ),
                _IncomeChip(
                  label: '> 10 Juta',
                  value: 15000000,
                  isSelected: _monthlyIncome == 15000000,
                  onTap: () => setState(() => _monthlyIncome = 15000000),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Keluarga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<MaritalStatus>(
              initialValue: _maritalStatus,
              dropdownColor: const Color(0xFF1E3A5F),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Status Pernikahan',
                prefixIcon: Icon(Icons.family_restroom, color: Colors.white70),
              ),
              items: MaritalStatus.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _maritalStatus = v),
              validator: (v) =>
                  v == null ? 'Status pernikahan wajib dipilih' : null,
            ),
            const SizedBox(height: 16),

            if (_maritalStatus == MaritalStatus.married) ...[
              TextFormField(
                controller: _spouseNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nama Pasangan',
                  prefixIcon: Icon(Icons.person, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Number of children
            Row(
              children: [
                const Icon(Icons.child_care, color: Colors.white70),
                const SizedBox(width: 12),
                Text(
                  'Jumlah Anak: $_numberOfChildren',
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.white70,
                  ),
                  onPressed: _numberOfChildren > 0
                      ? () => setState(() => _numberOfChildren--)
                      : null,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white70,
                  ),
                  onPressed: () => setState(() => _numberOfChildren++),
                ),
              ],
            ),

            const Divider(color: Colors.white24, height: 32),

            const Text(
              'Kontak Darurat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emergencyContactNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nama Kontak Darurat',
                prefixIcon: Icon(Icons.contact_phone, color: Colors.white70),
              ),
              validator: (v) => Validators.required(v, 'Kontak darurat'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emergencyContactPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'No. HP Kontak Darurat',
                prefixIcon: Icon(Icons.phone, color: Colors.white70),
              ),
              validator: Validators.phoneNumber,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeChip extends StatelessWidget {
  const _IncomeChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
