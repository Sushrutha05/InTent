import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email and password')),
      );
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmail(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) {
        debugPrint('Auth error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch state to show loading spinner
    final authState = ref.watch(authProvider);

    final isLoading = authState.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Decorative Logo element
              Center(
                child: Hero(
                  tag: 'app_logo',
                  child: Image(
                    image: AssetImage('lib/images/Intent_logo.png'),
                    height: 88,
                    width: 88,
                  ),
                ),
              ),
              const SizedBox(height: 0),

              Text(
                'Intent',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 48),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Connections that mean something.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'University Email (.edu / .ac.in)',
                  hintStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.school, color: AppTheme.textPrimary),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(
                    Icons.lock_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text('Sign In'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: const Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy. Mutual trust is our core principle.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
