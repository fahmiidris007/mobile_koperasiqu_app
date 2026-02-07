import 'package:equatable/equatable.dart';

/// Registration data collected during the multi-step registration process
class RegistrationData extends Equatable {
  const RegistrationData({
    // Step 1: Personal Data (Data Diri)
    this.fullName = '',
    this.nik = '',
    this.birthDate,
    this.gender,
    this.email = '',
    this.phone = '',

    // Step 2: Job Info (Pekerjaan)
    this.occupation = '',
    this.companyName = '',
    this.jobPosition = '',
    this.monthlyIncome = 0,

    // Step 3: Family Info (Keluarga)
    this.maritalStatus,
    this.spouseName = '',
    this.numberOfChildren = 0,
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',

    // Step 4: Documents
    this.ktpPhotoPath = '',
    this.selfiePhotoPath = '',

    // Meta
    this.password = '',
    this.currentStep = 0,
  });

  // Step 1
  final String fullName;
  final String nik;
  final DateTime? birthDate;
  final Gender? gender;
  final String email;
  final String phone;

  // Step 2
  final String occupation;
  final String companyName;
  final String jobPosition;
  final int monthlyIncome;

  // Step 3
  final MaritalStatus? maritalStatus;
  final String spouseName;
  final int numberOfChildren;
  final String emergencyContactName;
  final String emergencyContactPhone;

  // Step 4
  final String ktpPhotoPath;
  final String selfiePhotoPath;

  // Meta
  final String password;
  final int currentStep;

  /// Check if step 1 is complete
  bool get isStep1Complete =>
      fullName.isNotEmpty &&
      nik.length == 16 &&
      birthDate != null &&
      gender != null &&
      email.isNotEmpty &&
      phone.isNotEmpty;

  /// Check if step 2 is complete
  bool get isStep2Complete => occupation.isNotEmpty && monthlyIncome > 0;

  /// Check if step 3 is complete
  bool get isStep3Complete =>
      maritalStatus != null &&
      emergencyContactName.isNotEmpty &&
      emergencyContactPhone.isNotEmpty;

  /// Check if step 4 (documents) is complete
  bool get isStep4Complete =>
      ktpPhotoPath.isNotEmpty && selfiePhotoPath.isNotEmpty;

  /// Check if all steps are complete
  bool get isComplete =>
      isStep1Complete && isStep2Complete && isStep3Complete && isStep4Complete;

  @override
  List<Object?> get props => [
    fullName,
    nik,
    birthDate,
    gender,
    email,
    phone,
    occupation,
    companyName,
    jobPosition,
    monthlyIncome,
    maritalStatus,
    spouseName,
    numberOfChildren,
    emergencyContactName,
    emergencyContactPhone,
    ktpPhotoPath,
    selfiePhotoPath,
    password,
    currentStep,
  ];

  RegistrationData copyWith({
    String? fullName,
    String? nik,
    DateTime? birthDate,
    Gender? gender,
    String? email,
    String? phone,
    String? occupation,
    String? companyName,
    String? jobPosition,
    int? monthlyIncome,
    MaritalStatus? maritalStatus,
    String? spouseName,
    int? numberOfChildren,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? ktpPhotoPath,
    String? selfiePhotoPath,
    String? password,
    int? currentStep,
  }) {
    return RegistrationData(
      fullName: fullName ?? this.fullName,
      nik: nik ?? this.nik,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      companyName: companyName ?? this.companyName,
      jobPosition: jobPosition ?? this.jobPosition,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      spouseName: spouseName ?? this.spouseName,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      ktpPhotoPath: ktpPhotoPath ?? this.ktpPhotoPath,
      selfiePhotoPath: selfiePhotoPath ?? this.selfiePhotoPath,
      password: password ?? this.password,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

enum Gender {
  male,
  female;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Laki-laki';
      case Gender.female:
        return 'Perempuan';
    }
  }
}

enum MaritalStatus {
  single,
  married,
  divorced,
  widowed;

  String get displayName {
    switch (this) {
      case MaritalStatus.single:
        return 'Belum Menikah';
      case MaritalStatus.married:
        return 'Menikah';
      case MaritalStatus.divorced:
        return 'Cerai';
      case MaritalStatus.widowed:
        return 'Duda/Janda';
    }
  }
}
