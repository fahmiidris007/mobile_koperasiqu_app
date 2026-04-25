import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

/// Animated gradient background scaffold for all screens
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.animate = true,
  });

  final Widget child;
  final Gradient? gradient;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: gradient != null ? null : AppColors.background,
        decoration: gradient != null
            ? BoxDecoration(gradient: gradient)
            : null,
        child: Stack(
          children: [
            // Subtle decorative blobs — soft emerald tones
            if (animate) ...[
              Positioned(
                top: -80,
                right: -80,
                child: _AnimatedBlob(
                  size: 280,
                  color: AppColors.primaryLight.withOpacity(0.12),
                  duration: const Duration(seconds: 9),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -80,
                child: _AnimatedBlob(
                  size: 320,
                  color: AppColors.accent.withOpacity(0.10),
                  duration: const Duration(seconds: 11),
                  reverse: true,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.45,
                right: -40,
                child: _AnimatedBlob(
                  size: 180,
                  color: AppColors.accentLight.withOpacity(0.18),
                  duration: const Duration(seconds: 13),
                ),
              ),
            ],
            // Content
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

/// Animated floating blob decoration
class _AnimatedBlob extends StatelessWidget {
  const _AnimatedBlob({
    required this.size,
    required this.color,
    required this.duration,
    this.reverse = false,
  });

  final double size;
  final Color color;
  final Duration duration;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.2, 1.2),
          duration: duration,
          curve: Curves.easeInOut,
        )
        .moveY(
          begin: 0,
          end: reverse ? -30 : 30,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}

/// A simpler gradient background without animations (for performance)
class SimpleGradientBackground extends StatelessWidget {
  const SimpleGradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: gradient != null ? null : AppColors.background,
        decoration: gradient != null
            ? BoxDecoration(gradient: gradient)
            : null,
        child: SafeArea(child: child),
      ),
    );
  }
}
