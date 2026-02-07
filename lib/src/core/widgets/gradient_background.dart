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
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.liquidGlassGradient,
        ),
        child: Stack(
          children: [
            // Animated blob decorations
            if (animate) ...[
              Positioned(
                top: -100,
                right: -100,
                child: _AnimatedBlob(
                  size: 300,
                  color: AppColors.teal.withOpacity(0.3),
                  duration: const Duration(seconds: 8),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -100,
                child: _AnimatedBlob(
                  size: 350,
                  color: AppColors.purple.withOpacity(0.3),
                  duration: const Duration(seconds: 10),
                  reverse: true,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: -50,
                child: _AnimatedBlob(
                  size: 200,
                  color: AppColors.primary.withOpacity(0.2),
                  duration: const Duration(seconds: 12),
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
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.liquidGlassGradient,
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
