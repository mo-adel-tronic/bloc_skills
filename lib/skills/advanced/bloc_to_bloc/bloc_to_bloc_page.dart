import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_session_cubit.dart';
import 'session_sync_bloc.dart';

class BlocToBlocPage extends StatelessWidget {
  const BlocToBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthSessionCubit(),
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (innerContext) => SessionSyncBloc(
              authSessionCubit: innerContext.read<AuthSessionCubit>(),
            ),
            child: const _BlocToBlocView(),
          );
        },
      ),
    );
  }
}

class _BlocToBlocView extends StatelessWidget {
  const _BlocToBlocView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC-to-BLoC Communication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Architectural Overview
            Card(
              color: Colors.red.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hub_outlined, color: Colors.red.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'How BLoCs Communicate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Pattern A (In BLoC): Pass the source BLoC/Cubit to the constructor and subscribe to its stream via `late final StreamSubscription sub = bloc.stream.listen(...)`.\n'
                      '• Rule: Always call `sub.cancel()` inside the `close()` method to prevent memory leaks!\n'
                      '• Pattern B (In UI): Use `BlocListener<SourceBloc, SourceState>` in the widget tree to dispatch events to the destination BLoC.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card 1: Source BLoC (AuthSessionCubit)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text(
                          'Source BLoC: AuthSessionCubit',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    BlocBuilder<AuthSessionCubit, AuthSessionState>(
                      builder: (context, authState) {
                        final isAuth = authState.status == AuthStatus.authenticated;
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isAuth ? Colors.green.shade100 : Colors.grey.shade200,
                              child: Icon(
                                isAuth ? Icons.verified_user : Icons.lock_outline,
                                color: isAuth ? Colors.green.shade800 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authState.username,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Role: ${authState.role} • Status: ${authState.status.name.toUpperCase()}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => context.read<AuthSessionCubit>().loginAsMember(),
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Login as Member'),
                        ),
                        FilledButton.icon(
                          onPressed: () => context.read<AuthSessionCubit>().loginAsAdmin(),
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: const Text('Login as Admin'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.read<AuthSessionCubit>().logout(),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Logout'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Dependent BLoC (SessionSyncBloc)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sync_alt, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Dependent BLoC: SessionSyncBloc',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    BlocBuilder<SessionSyncBloc, SessionSyncState>(
                      builder: (context, syncState) {
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: syncState.hasAccess ? Colors.teal.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: syncState.hasAccess ? Colors.teal.shade300 : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    syncState.hasAccess ? Icons.lock_open : Icons.lock,
                                    size: 18,
                                    color: syncState.hasAccess ? Colors.teal.shade900 : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    syncState.hasAccess ? 'Access Granted' : 'Access Restricted',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: syncState.hasAccess ? Colors.teal.shade900 : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                syncState.secretData,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: syncState.hasAccess ? Colors.teal.shade900 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Live Stream Subscription Logs:',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<SessionSyncBloc, SessionSyncState>(
                      builder: (context, syncState) {
                        return Container(
                          constraints: const BoxConstraints(maxHeight: 140),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: syncState.eventLog.length,
                            itemBuilder: (context, index) {
                              final log = syncState.eventLog[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  log,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

