import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_bloc.dart';

class BlocTestingPage extends StatefulWidget {
  const BlocTestingPage({super.key});

  @override
  State<BlocTestingPage> createState() => _BlocTestingPageState();
}

class _BlocTestingPageState extends State<BlocTestingPage> {
  bool _isRunningTests = false;
  final List<_TestResult> _testResults = [];

  Future<void> _runSimulatedTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });

    final testCases = [
      _TestResult(
        title: 'initial state is CartInitial',
        codeSnippet: 'expect(bloc.state, equals(CartInitial()));',
        durationMs: 8,
      ),
      _TestResult(
        title: 'emits [CartLoaded] when AddCartItem is added',
        codeSnippet: 'blocTest<CartBloc, CartState>(\n'
            '  "emits CartLoaded with 1 item",\n'
            '  build: () => CartBloc(),\n'
            '  act: (bloc) => bloc.add(AddCartItem(item)),\n'
            '  expect: () => [isA<CartLoaded>()],\n'
            ');',
        durationMs: 16,
      ),
      _TestResult(
        title: 'emits [CartLoaded] with updated sum when multiple items added',
        codeSnippet: 'blocTest<CartBloc, CartState>(\n'
            '  "accumulates sum properly",\n'
            '  build: () => CartBloc(),\n'
            '  act: (bloc) => bloc..add(item1)..add(item2),\n'
            '  expect: () => [CartLoaded(1, 80), CartLoaded(2, 110)],\n'
            ');',
        durationMs: 22,
      ),
      _TestResult(
        title: 'emits [CartError] when removing item from empty cart',
        codeSnippet: 'blocTest<CartBloc, CartState>(\n'
            '  "emits CartError on invalid remove",\n'
            '  build: () => CartBloc(),\n'
            '  act: (bloc) => bloc.add(RemoveCartItem("invalid")),\n'
            '  expect: () => [isA<CartError>()],\n'
            ');',
        durationMs: 14,
      ),
      _TestResult(
        title: 'emits [CartInitial] when ClearCart is dispatched',
        codeSnippet: 'blocTest<CartBloc, CartState>(\n'
            '  "resets to CartInitial",\n'
            '  build: () => CartBloc(),\n'
            '  seed: () => CartLoaded([item], 50),\n'
            '  act: (bloc) => bloc.add(ClearCart()),\n'
            '  expect: () => [CartInitial()],\n'
            ');',
        durationMs: 11,
      ),
    ];

    for (final test in testCases) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        _testResults.add(test);
      });
    }

    if (!mounted) return;
    setState(() {
      _isRunningTests = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => CartBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing BLoCs — bloc_test'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Concept Card
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.checklist, color: Colors.green.shade900),
                          const SizedBox(width: 8),
                          Text(
                            'The Anatomy of a blocTest',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Using `package:bloc_test`, BLoC testing follows a deterministic 4-stage structure:\n'
                        '1. build: Factory returning the BLoC instance under test.\n'
                        '2. seed (optional): Pre-loads an initial state before actions.\n'
                        '3. act: Callback to dispatch events or call methods.\n'
                        '4. expect: Expected chronological sequence of emitted states.',
                        style: TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: In-App Test Runner
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'In-App Test Suite Runner',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          FilledButton.icon(
                            onPressed: _isRunningTests ? null : _runSimulatedTests,
                            icon: _isRunningTests
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.play_arrow, size: 18),
                            label: Text(_isRunningTests ? 'Running...' : 'Run Test Suite'),
                            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      if (_testResults.isEmpty && !_isRunningTests)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Tap "Run Test Suite" to execute simulated blocTest assertions.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ),
                        )
                      else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _testResults.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final test = _testResults[index];
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          test.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          'Duration: ${test.durationMs}ms • Status: PASSED',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Live Cart Sandbox
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Cart Sandbox (Interactive)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Interact with the live CartBloc to observe the state transitions tested above.',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                      ),
                      const Divider(height: 20),
                      BlocConsumer<CartBloc, CartState>(
                        listener: (context, state) {
                          if (state is CartError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is CartInitial) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Cart is currently empty (CartInitial).'),
                              ),
                            );
                          } else if (state is CartLoaded) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Items (${state.items.length}):', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      'Total: \$${state.totalPrice.toStringAsFixed(0)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: state.items.map((i) {
                                    return Chip(
                                      label: Text('${i.name} (\$${i.price.toStringAsFixed(0)})'),
                                      onDeleted: () => context.read<CartBloc>().add(RemoveCartItem(i.name)),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          } else if (state is CartError) {
                            return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => context.read<CartBloc>().add(
                                      const AddCartItem(CartItem('Headphones', 80)),
                                    ),
                                icon: const Icon(Icons.headphones, size: 16),
                                label: const Text('Add Headphones (\$80)'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => context.read<CartBloc>().add(
                                      const AddCartItem(CartItem('Mouse', 30)),
                                    ),
                                icon: const Icon(Icons.mouse, size: 16),
                                label: const Text('Add Mouse (\$30)'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.read<CartBloc>().add(
                                      const RemoveCartItem('NonExistent'),
                                    ),
                                icon: const Icon(Icons.error_outline, size: 16),
                                label: const Text('Trigger Error'),
                              ),
                              IconButton.filledTonal(
                                onPressed: () => context.read<CartBloc>().add(ClearCart()),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Clear Cart',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Code Sample
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '// Example blocTest:\n'
                  'blocTest<CartBloc, CartState>(\n'
                  '  "emits [CartLoaded] when item is added",\n'
                  '  build: () => CartBloc(),\n'
                  '  act: (bloc) => bloc.add(const AddCartItem(CartItem("Book", 25))),\n'
                  '  expect: () => [\n'
                  '    const CartLoaded([CartItem("Book", 25)], 25.0),\n'
                  '  ],\n'
                  ');',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestResult {
  final String title;
  final String codeSnippet;
  final int durationMs;

  _TestResult({
    required this.title,
    required this.codeSnippet,
    required this.durationMs,
  });
}
