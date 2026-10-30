import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_value_cubit.dart';

class ProviderValuePage extends StatelessWidget {
  const ProviderValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initial creation with BlocProvider(create: ...)
    return BlocProvider(
      create: (_) => CounterValueCubit(),
      child: const _ProviderValueHomeView(),
    );
  }
}

class _ProviderValueHomeView extends StatelessWidget {
  const _ProviderValueHomeView();

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterValueCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocProvider.value — Route Passing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
            Card(
              color: Colors.deepOrange.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.deepOrange.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alt_route_outlined, color: Colors.deepOrange.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Passing BLoC to New Routes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• `Navigator.push` pushes a new route into a separate widget subtree.\n'
                      '• Standard `context.read<T>()` won\'t be found in the new route without providing it!\n'
                      '• **Rule**: Use `BlocProvider.value(value: ...)` to share an EXISTING instance.\n'
                      '• `BlocProvider(create: ...)` automatically calls `close()`. If used for an existing instance, it would close the BLoC when the new route pops!',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live State Display (Screen A)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Screen A (Parent Route)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => context.read<CounterValueCubit>().decrement(),
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: () => context.read<CounterValueCubit>().increment(),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Button
            FilledButton.icon(
              onPressed: () {
                // Pass the existing cubit instance to the new route using BlocProvider.value
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CounterValueCubit>(),
                      child: const _DetailValueView(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Screen B with BlocProvider.value'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
                '// Passing existing BLoC instance to a new route:\n'
                'Navigator.push(\n'
                '  context,\n'
                '  MaterialPageRoute(\n'
                '    builder: (_) => BlocProvider.value(\n'
                '      value: context.read<MyBloc>(), // Reuse existing instance\n'
                '      child: const DetailScreen(),   // Won\'t close on pop!\n'
                '    ),\n'
                '  ),\n'
                ');',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.orangeAccent,
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

class _DetailValueView extends StatelessWidget {
  const _DetailValueView();

  @override
  Widget build(BuildContext context) {
    // Reads the same shared instance passed via BlocProvider.value
    final count = context.watch<CounterValueCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen B (Child Route)'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 54),
              const SizedBox(height: 12),
              const Text(
                'Shared Instance in Screen B',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Changes here are reflected in Screen A because both routes share the exact same Cubit instance.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade800,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'detail_dec',
                    onPressed: () => context.read<CounterValueCubit>().decrement(),
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrement'),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton.extended(
                    heroTag: 'detail_inc',
                    onPressed: () => context.read<CounterValueCubit>().increment(),
                    icon: const Icon(Icons.add),
                    label: const Text('Increment'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to Screen A (Instance Kept Alive)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
