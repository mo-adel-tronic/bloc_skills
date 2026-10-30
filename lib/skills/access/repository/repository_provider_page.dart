import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_repository.dart';
import 'user_profile_bloc.dart';

class RepositoryProviderPage extends StatelessWidget {
  const RepositoryProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Provide the repository at the top of the subtree
    return RepositoryProvider(
      create: (_) => UserRepository(),
      // 2. Inject the repository into the BLoC via context.read<T>()
      child: BlocProvider(
        create: (context) => UserProfileBloc(
          repository: context.read<UserRepository>(),
        ),
        child: const _RepositoryProviderView(),
      ),
    );
  }
}

class _RepositoryProviderView extends StatelessWidget {
  const _RepositoryProviderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RepositoryProvider — Service DI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
            Card(
              color: Colors.amber.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: Colors.amber.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Clean Layered Architecture',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• `RepositoryProvider`: provides non-BLoC service dependencies to widgets and BLoCs.\n'
                      '• **Layer Rule**: UI (Widgets) ──► BLoC ──► Repository ──► Data Source (API/DB).\n'
                      '• BLoCs should NEVER make raw HTTP calls or database queries directly.\n'
                      '• Makes unit testing BLoCs trivial by mocking the repository!',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live State Display Card
            BlocBuilder<UserProfileBloc, UserProfileState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (state is UserProfileLoading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Calling UserRepository.fetchUser()...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ] else if (state is UserProfileSuccess) ...[
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.amber.shade100,
                          child: Icon(Icons.person, size: 40, color: Colors.amber.shade900),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.user.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          state.user.email,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          label: Text(
                            state.user.role,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          backgroundColor: Colors.amber.shade100,
                        ),
                      ] else if (state is UserProfileError) ...[
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.error,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        const Icon(Icons.account_box_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No User Loaded',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap below to fetch data through UserRepository.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Controls
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    context.read<UserProfileBloc>().add(const FetchUserRequested('user_1'));
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Fetch Sarah (user_1)'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade900),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.read<UserProfileBloc>().add(const FetchUserRequested('user_2'));
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Fetch John (user_2)'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<UserProfileBloc>().add(const FetchUserRequested('unknown_id'));
                  },
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Simulate Error'),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    context.read<UserProfileBloc>().add(const ResetUserRequested());
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Code Display
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: const Text(
                '// 1. Inject repository above BLoC:\n'
                'RepositoryProvider(\n'
                '  create: (_) => UserRepository(),\n'
                '  child: BlocProvider(\n'
                '    create: (context) => UserProfileBloc(\n'
                '      repository: context.read<UserRepository>(),\n'
                '    ),\n'
                '    child: UserView(),\n'
                '  ),\n'
                ');',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.amberAccent,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
