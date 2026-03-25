import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../providers/auth_provider.dart';

/// Standalone OTP verification page shown after POST /register succeeds.
/// Receives the user email as [GoRouterState.extra].
/// Calls POST /otp/verify; on success redirects to /pending.
class VerifyRegisterOtpPage extends ConsumerStatefulWidget {
  const VerifyRegisterOtpPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyRegisterOtpPage> createState() =>
      _VerifyRegisterOtpPageState();
}

class _VerifyRegisterOtpPageState
    extends ConsumerState<VerifyRegisterOtpPage> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatically call POST /otp/send as soon as the page appears
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialOtp());
  }

  Future<void> _sendInitialOtp() async {
    setState(() => _isLoading = true);
    await ref
        .read(registrationProvider.notifier)
        .sendRegisterOtp(widget.email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Show error if send failed
    final err = ref.read(registrationProvider).error;
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim OTP: $err'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode OTP 6 digit terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ok = await ref
        .read(registrationProvider.notifier)
        .verifyRegisterOtp(widget.email, otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      // Reset registration state and navigate to pending
      ref.read(registrationProvider.notifier).reset();
      context.go(Routes.pending);
    } else {
      final err = ref.read(registrationProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Kode OTP tidak valid. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isLoading = true);
    await ref.read(registrationProvider.notifier).resendOtp(widget.email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode OTP telah dikirim ulang ke email Anda'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Back button — goes back to EKYC (user can retake photos)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => context.pop(),
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
            ),

            const SizedBox(height: 48),

            GlassContainer(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 28,
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Verifikasi Email',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Pendaftaran berhasil! Kode OTP telah\ndikirim ke email Anda:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 6-box OTP input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 48,
                            child: Focus(
                              onKeyEvent: (node, event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.backspace &&
                                    _otpControllers[i].text.isEmpty &&
                                    i > 0) {
                                  _otpFocusNodes[i - 1].requestFocus();
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextField(
                                controller: _otpControllers[i],
                                focusNode: _otpFocusNodes[i],
                                maxLength: 1,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      Colors.white.withOpacity(0.08),
                                ),
                                onChanged: (v) {
                                  if (v.isNotEmpty && i < 5) {
                                    _otpFocusNodes[i + 1].requestFocus();
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 36),

                      GlassButton(
                        text: 'Verifikasi OTP',
                        icon: Icons.verified_user_rounded,
                        isLoading: _isLoading,
                        onPressed: _handleVerify,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum menerima kode? ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : _handleResend,
                            child: const Text(
                              'Kirim Ulang',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.08, end: 0),

            const SizedBox(height: 24),

            GlassContainer(
              padding: const EdgeInsets.all(14),
              opacity: 0.07,
              borderRadius: 14,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Akun Anda telah dibuat dan menunggu persetujuan admin setelah verifikasi OTP.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
