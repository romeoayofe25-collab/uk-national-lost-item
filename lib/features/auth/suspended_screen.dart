import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_provider.dart';

class SuspendedScreen extends StatelessWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_person,
                color: AppColors.danger,
                size: 96.0,
              ),
              const SizedBox(height: 24.0),
              Text(
                'ACCOUNT SUSPENDED',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.danger,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Card(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.danger, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Your account has been automatically suspended by the system security protocols or the Administration Board.\n\n'
                    'This suspension occurs due to repeated failed claim verifications, suspicious geofence activity, or billing discrepancies.\n\n'
                    'Only Admin Board staff have the authority to review logs and re-activate your profile status.',
                    style: TextStyle(height: 1.5, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Return to Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
