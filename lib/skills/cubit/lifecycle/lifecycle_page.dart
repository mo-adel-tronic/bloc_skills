import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lifecycle_cubit.dart';

class LifecyclePage extends StatelessWidget {
  const LifecyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LifecycleCubit(),
      child: const _LifecycleView(),
    );
  }
}

class _LifecycleView extends StatelessWidget {
  const _LifecycleView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit Lifecycle — onChange & close()'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Explanation Card
            Card(
              color: Colors.teal.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.teal.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_toggle_off, color: Colors.teal.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Cubit Lifecycle & Memory Safety',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• `onChange(change)`: fires right before state updates.\n'
                      '• Access `change.currentState` and `change.nextState`.\n'
                      '• `close()`: automatic cleanup when widget unmounts.\n'
                      '• Always cancel Timers and StreamSubscriptions in `close()` to prevent memory leaks!',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Timer Display
            BlocBuilder<LifecycleCubit, TimerState>(
              builder: (context, state) {
                final isRunning = state.status == TimerStatus.running;
                final minutes = (state.seconds ~/ 60).toString().padLeft(2, '0');
                final secs = (state.seconds % 60).toString().padLeft(2, '0');

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                      decoration: BoxDecoration(
                        color: isRunning ? Colors.teal.shade700 : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$minutes:$secs',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(
                        'Status: ${state.status.name.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isRunning
                          ? Colors.teal.shade100
                          : Colors.grey.shade200,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Timer Controls
            BlocBuilder<LifecycleCubit, TimerState>(
              builder: (context, state) {
                final isRunning = state.status == TimerStatus.running;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isRunning)
                      FilledButton.icon(
                        onPressed: () => context.read<LifecycleCubit>().start(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => context.read<LifecycleCubit>().pause(),
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.read<LifecycleCubit>().reset(),
                      icon: const Icon(Icons.replay),
                      label: const Text('Reset'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Live onChange Log Viewer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lifecycle onChange Logs',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.read<LifecycleCubit>().clearLogs(),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<LifecycleCubit, TimerState>(
              builder: (context, state) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: state.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet. Tap Start/Pause to trigger state changes.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: state.logs.length,
                          itemBuilder: (context, index) {
                            final log = state.logs[state.logs.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                log,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Colors.tealAccent,
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
    );
  }
}
