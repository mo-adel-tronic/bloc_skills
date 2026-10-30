import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'equatable_cubit.dart';

class EquatableEqualityPage extends StatelessWidget {
  const EquatableEqualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RawCubit()),
        BlocProvider(create: (_) => EquatableDemoCubit()),
      ],
      child: const _EquatableEqualityView(),
    );
  }
}

class _EquatableEqualityView extends StatelessWidget {
  const _EquatableEqualityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equatable — Value Equality'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
            Card(
              color: Colors.purple.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.compare_arrows, color: Colors.purple.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Why Equatable is Essential',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• By default, Dart compares class instances by memory reference (identical(a, b)).\n'
                      '• Without Equatable, emitting identical values creates new instances (old != new), triggering redundant rebuilds!\n'
                      '• With Equatable, BLoC checks props => [fields]. If fields are identical, BLoC skips the rebuild automatically.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Demo Comparison
            const Text(
              'Tap "Emit Same Value (5)" to see the difference:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(child: _RawComparisonCard()),
                SizedBox(width: 14),
                Expanded(child: _EquatableComparisonCard()),
              ],
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
                    // Emit same value (5) in both
                    context.read<RawCubit>().emitSameValue();
                    context.read<EquatableDemoCubit>().emitSameValue();
                  },
                  icon: const Icon(Icons.repeat),
                  label: const Text('Emit Same Value (5)'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.purple.shade800),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.read<RawCubit>().increment();
                    context.read<EquatableDemoCubit>().increment();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Increment Both (+1)'),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    context.read<RawCubit>().reset();
                    context.read<EquatableDemoCubit>().reset();
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
                '// With Equatable — BLoC skips redraw if values match:\n'
                'class MyState extends Equatable {\n'
                '  final int count;\n'
                '  const MyState(this.count);\n\n'
                '  @override\n'
                '  List<Object?> get props => [count]; // Compare by value\n'
                '}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.purpleAccent,
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

class _RawComparisonCard extends StatefulWidget {
  const _RawComparisonCard();

  @override
  State<_RawComparisonCard> createState() => _RawComparisonCardState();
}

class _RawComparisonCardState extends State<_RawComparisonCard> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RawCubit, RawState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        _rebuilds++;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Column(
            children: [
              const Text(
                'Without Equatable',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Text(
                '(Reference Equality)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                '${state.count}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Chip(
                label: Text(
                  'Raw Rebuilds: $_rebuilds',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red.shade100,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EquatableComparisonCard extends StatefulWidget {
  const _EquatableComparisonCard();

  @override
  State<_EquatableComparisonCard> createState() => _EquatableComparisonCardState();
}

class _EquatableComparisonCardState extends State<_EquatableComparisonCard> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EquatableDemoCubit, EquatableState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        _rebuilds++;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Column(
            children: [
              const Text(
                'With Equatable',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Text(
                '(Value Equality)',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Text(
                '${state.count}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Chip(
                label: Text(
                  'Equatable Rebuilds: $_rebuilds',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green.shade100,
              ),
            ],
          ),
        );
      },
    );
  }
}
