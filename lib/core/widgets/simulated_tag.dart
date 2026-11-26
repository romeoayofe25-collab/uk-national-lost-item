import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Small marker placed next to anything this prototype only pretends to do,
/// such as the identity scan, QR codes, payments or police checks.
class SimulatedTag extends StatelessWidget {
  const SimulatedTag({super.key, this.label = 'SIMULATED'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Simulated in this prototype',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.science_outlined, size: 12, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
