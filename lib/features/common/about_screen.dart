import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/simulated_tag.dart';

/// Explains what this prototype is and what it only simulates.
/// Reachable from the sign-in screen and the profile screen.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<String> paragraphs = [
    'UK National Lost-Item is a portfolio prototype by Martin Adegbola Traore. '
        'It shows how a lost-property recovery service could work when the owner '
        'and the finder never deal with each other directly.',
    'Nothing here is live. All accounts, items, partner desks, messages and rewards '
        'are demo data held in memory, and they reset when the app restarts.',
    'The identity scan, map, QR scan, photo upload, payments and police checks are '
        'simulations. No camera, location, payment or outside system is used, and no '
        'personal data is collected.',
    'This project is independent. It is not affiliated with any police force, '
        'government body, transport operator or retailer. Real place names appear '
        'only as example locations.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About this prototype')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SimulatedTag(label: 'PORTFOLIO PROTOTYPE'),
              const SizedBox(height: 20),
              for (final text in paragraphs) ...[
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
