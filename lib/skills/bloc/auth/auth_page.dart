import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final _emailController = TextEditingController(text: 'admin@flutter.dev');
  final _passwordController = TextEditingController(text: 'flutter123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC Async Handlers — Loading & Errors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Concept card
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.indigo.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hourglass_top, color: Colors.indigo.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Async Event Handlers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Handlers are declared `async`: `Future<void> _handler(event, emit) async`.\n'
                      '• Emit `AuthLoading()` first to render a progress spinner.\n'
                      '• `await` your async repository/network service.\n'
                      '• Emit `AuthAuthenticated` on success, or `AuthFailure` on error.\n'
                      '• Always guard with `try/catch` to avoid uncaught exceptions.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Fill Presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Try: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ActionChip(
                    label: const Text('Valid Admin'),
                    avatar: const Icon(Icons.check, size: 16, color: Colors.green),
                    onPressed: () {
                      _emailController.text = 'admin@flutter.dev';
                      _passwordController.text = 'flutter123';
                      context.read<AuthBloc>().add(const AuthResetRequested());
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Invalid Creds'),
                    avatar: const Icon(Icons.close, size: 16, color: Colors.orange),
                    onPressed: () {
                      _emailController.text = 'wrong@flutter.dev';
                      _passwordController.text = 'badpass';
                      context.read<AuthBloc>().add(const AuthResetRequested());
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Server Error'),
                    avatar: const Icon(Icons.warning, size: 16, color: Colors.red),
                    onPressed: () {
                      _emailController.text = 'error@server.com';
                      _passwordController.text = '123456';
                      context.read<AuthBloc>().add(const AuthResetRequested());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reactive State UI
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return switch (state) {
                  AuthInitial() => _buildLoginForm(context, isLoading: false),
                  AuthLoading() => _buildLoginForm(context, isLoading: true),
                  AuthAuthenticated(:final username) => _buildSuccessCard(context, username),
                  AuthFailure(:final errorMessage) => _buildErrorCard(context, errorMessage),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, {required bool isLoading}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Async Authentication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              enabled: !isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(
                            LoginSubmitted(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            ),
                          );
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.login),
              label: Text(isLoading ? 'Authenticating...' : 'Sign In (Async Handler)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context, String username) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user, color: Colors.green, size: 56),
          const SizedBox(height: 12),
          Text(
            'Welcome, $username!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Async authentication completed successfully.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out (LogoutRequested)'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 56),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthResetRequested());
            },
            icon: const Icon(Icons.replay),
            label: const Text('Try Again (AuthResetRequested)'),
          ),
        ],
      ),
    );
  }
}
