import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_cubit.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the CounterCubit to this subtree
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const _CounterView(),
    );
  }
}

class _CounterView extends StatelessWidget {
  const _CounterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit Basics — Counter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Concept Explanation Card
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Cubit Concept',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Cubit is the simplest form of BLoC.\n'
                      '• No events needed: widgets call methods directly.\n'
                      '• emit(newState) notifies BlocBuilder to rebuild.\n'
                      '• Use context.read<T>() in callbacks (buttons).\n'
                      '• Use BlocBuilder<T, S> only where rebuild is needed.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Live State Display
            const Text(
              'Current Counter State',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            BlocBuilder<CounterCubit, int>(
              builder: (context, count) {
                Color countColor = Colors.grey.shade800;
                if (count > 0) countColor = Colors.green.shade600;
                if (count < 0) countColor = Colors.red.shade600;

                return Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: countColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: countColor, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: countColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 36),

            // Interactive Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'decrement_btn',
                  onPressed: () => context.read<CounterCubit>().decrement(),
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                ),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  onPressed: () => context.read<CounterCubit>().reset(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'increment_btn',
                  onPressed: () => context.read<CounterCubit>().increment(),
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade900,
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Code snippet explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: const Text(
                '// Inside button callback:\n'
                'context.read<CounterCubit>().increment();\n\n'
                '// Inside Cubit:\n'
                'void increment() => emit(state + 1);',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
