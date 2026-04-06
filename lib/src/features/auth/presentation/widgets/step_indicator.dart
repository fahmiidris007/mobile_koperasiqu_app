import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

/// Step indicator for multi-step forms
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isEven) {
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.accentLight,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: stepIndex < currentStep
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[stepIndex],
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        } else {
          // Connector line
          final prevStepIndex = index ~/ 2;
          final isActive = prevStepIndex < currentStep;

          return Container(
            height: 2,
            width: 20,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: isActive
                  ? AppColors.primaryGradient
                  : null,
              color: isActive ? null : AppColors.accentLight,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }
      }),
    );
  }
}
