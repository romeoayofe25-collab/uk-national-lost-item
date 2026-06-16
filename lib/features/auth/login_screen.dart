import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    final success = await authProvider.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      _routeUser(authProvider);
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  }

  void _devLogin(String email) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(email, 'password');
    if (success && mounted) {
      _routeUser(authProvider);
    }
  }

  void _routeUser(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    if (user != null) {
      if (user.isSuspended) {
        context.go('/suspended');
      } else {
        switch (user.role) {
          case 'owner':
            context.go('/owner');
            break;
          case 'finder':
            context.go('/finder');
            break;
          case 'intermediary':
            context.go('/intermediary');
            break;
          case 'admin':
            context.go('/admin');
            break;
          default:
            context.go('/owner');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40.0),
                Text(
                  'UK National Lost-Item',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Safe, Secure, and Fair Recovery',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20.0),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'name@example.com',
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        authProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Sign In'),
                              ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Create an Account'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Text(
                  'DEVELOPER DIRECT ROLE LOGIN',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        backgroundColor: AppColors.surface,
                      ),
                      onPressed: () => _devLogin('owner@test.com'),
                      child: const Text('Owner', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        backgroundColor: AppColors.surface,
                      ),
                      onPressed: () => _devLogin('finder@test.com'),
                      child: const Text('Finder', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        backgroundColor: AppColors.surface,
                      ),
                      onPressed: () => _devLogin('intermediary@test.com'),
                      child: const Text('Intermediary', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        backgroundColor: AppColors.surface,
                      ),
                      onPressed: () => _devLogin('admin@test.com'),
                      child: const Text('Admin', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  onPressed: () => _devLogin('suspended@test.com'),
                  child: const Text('Suspended Test Account', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
