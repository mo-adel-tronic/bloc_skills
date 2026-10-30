import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'build_when_cubit.dart';

class BuildWhenPage extends StatelessWidget {
  const BuildWhenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuildWhenCubit(),
      child: const _BuildWhenView(),
    );
  }
}

class _BuildWhenView extends StatefulWidget {
  const _BuildWhenView();

  @override
  State<_BuildWhenView> createState() => _BuildWhenViewState();
}

class _BuildWhenViewState extends State<_BuildWhenView> {
  int _unoptimizedRebuildCount = 0;
  int _optimizedRebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocBuilder — buildWhen Optimization'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Explanation Card
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
                        Icon(Icons.tune, color: Colors.teal.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'buildWhen Optimization',
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
                      '• By default, `BlocBuilder` rebuilds on EVERY new state emitted.\n'
                      '• `buildWhen: (previous, current) => bool` acts as a guard filter.\n'
                      '• When `buildWhen` returns `false`, `builder` is SKIPPED, saving CPU & GPU redraws.\n'
                      '• Compare the two live cards below when updating "Note Only"!',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live State Note Banner
            BlocBuilder<BuildWhenCubit, CounterFilterState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Colors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Current Note: ${state.note}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Comparison: Unfiltered vs Filtered
            Row(
              children: [
                // Unoptimized Card
                Expanded(
                  child: BlocBuilder<BuildWhenCubit, CounterFilterState>(
                    builder: (context, state) {
                      _unoptimizedRebuildCount++;
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
                              'Standard Builder',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              '(No buildWhen)',
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
                                'Rebuilds: $_unoptimizedRebuildCount',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red.shade100,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Optimized Card with buildWhen
                Expanded(
                  child: BlocBuilder<BuildWhenCubit, CounterFilterState>(
                    buildWhen: (previous, current) {
                      // Only rebuild when COUNT changes; ignore note updates!
                      return previous.count != current.count;
                    },
                    builder: (context, state) {
                      _optimizedRebuildCount++;
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
                              'Optimized Builder',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              '(buildWhen: count != count)',
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
                                'Rebuilds: $_optimizedRebuildCount',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.green.shade100,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Interactive Controls
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => context.read<BuildWhenCubit>().increment(),
                  icon: const Icon(Icons.add),
                  label: const Text('Count + 1'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.read<BuildWhenCubit>().updateNoteOnly(),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Update Note Only'),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _unoptimizedRebuildCount = 0;
                      _optimizedRebuildCount = 0;
                    });
                    context.read<BuildWhenCubit>().reset();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset State & Counts',
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
                'BlocBuilder<MyCubit, MyState>(\n'
                '  // Guard condition: returns true only when rebuild is needed\n'
                '  buildWhen: (previous, current) {\n'
                '    return previous.count != current.count;\n'
                '  },\n'
                '  builder: (context, state) {\n'
                '    return Text("\${state.count}");\n'
                '  },\n'
                ');',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.tealAccent,
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
