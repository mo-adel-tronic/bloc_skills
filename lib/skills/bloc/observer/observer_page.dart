import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/counter/counter_cubit.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import 'app_bloc_observer.dart';

class ObserverPage extends StatelessWidget {
  const ObserverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit()),
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: const _ObserverView(),
    );
  }
}

class _ObserverView extends StatelessWidget {
  const _ObserverView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBlocObserver — Global Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Observer Logs',
            onPressed: () => AppBlocObserver.clearLogs(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept card
            Card(
              color: Colors.blueGrey.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blueGrey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart_outlined, color: Colors.blueGrey.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Global BlocObserver',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• `BlocObserver` is a singleton registered in `main()` with `Bloc.observer = ...`.\n'
                      '• Catches ALL events, transitions, changes, and errors globally.\n'
                      '• Used in production for analytics, crash reporting (Firebase / Sentry), and debug logging.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Trigger Actions Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trigger Actions from 2 Different Blocs',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text('CounterCubit.increment()'),
                          onPressed: () => context.read<CounterCubit>().increment(),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.remove, size: 16),
                          label: const Text('CounterCubit.decrement()'),
                          onPressed: () => context.read<CounterCubit>().decrement(),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.login, size: 16),
                          label: const Text('AuthBloc: Login Event'),
                          onPressed: () => context.read<AuthBloc>().add(
                                const LoginSubmitted(
                                  email: 'admin@flutter.dev',
                                  password: 'flutter123',
                                ),
                              ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.logout, size: 16),
                          label: const Text('AuthBloc: Logout Event'),
                          onPressed: () => context.read<AuthBloc>().add(
                                const LogoutRequested(),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Observer Feed
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Observer Log Stream',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '(Auto-captures all BLoCs)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ValueListenableBuilder<List<ObserverLogEntry>>(
              valueListenable: AppBlocObserver.logsNotifier,
              builder: (context, logs, child) {
                if (logs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tap any button above to see AppBlocObserver intercept it live!',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    reverse: true,
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade800, height: 12),
                    itemBuilder: (context, index) {
                      final entry = logs[logs.length - 1 - index];

                      Color badgeColor;
                      switch (entry.type) {
                        case LogType.event:
                          badgeColor = Colors.cyan;
                          break;
                        case LogType.change:
                          badgeColor = Colors.amber;
                          break;
                        case LogType.transition:
                          badgeColor = Colors.lightGreenAccent;
                          break;
                        case LogType.error:
                          badgeColor = Colors.redAccent;
                          break;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: badgeColor, width: 0.8),
                                ),
                                child: Text(
                                  entry.type.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.blocName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.details,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
