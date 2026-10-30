import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transformers_bloc.dart';

class EventTransformersPage extends StatelessWidget {
  const EventTransformersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PaymentBloc()),
        BlocProvider(create: (_) => LiveSearchBloc()),
      ],
      child: const _EventTransformersView(),
    );
  }
}

class _EventTransformersView extends StatelessWidget {
  const _EventTransformersView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Transformers — bloc_concurrency'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
            Card(
              color: Colors.orange.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.orange.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: Colors.orange.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Why Event Transformers Matter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'By default, BLoC processes events sequentially (FIFO). Using `bloc_concurrency`, you can change event handling strategies:\n'
                      '• droppable(): Ignores new incoming events while the current event is processing (prevents double submits).\n'
                      '• restartable(): Cancels the active event and starts the latest one (ideal for search autocomplete).\n'
                      '• concurrent(): Handles multiple events in parallel simultaneously.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Demo 1: droppable()
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
                        const Icon(Icons.shield_outlined, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '1. droppable() — Payment Button',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Spam the button rapidly. The transformer processes only the first click and DROPS all subsequent clicks until complete.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                    const Divider(height: 20),
                    BlocBuilder<PaymentBloc, PaymentState>(
                      builder: (context, paymentState) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: paymentState.status == PaymentStatus.processing
                                    ? Colors.amber.shade50
                                    : (paymentState.status == PaymentStatus.completed
                                        ? Colors.green.shade50
                                        : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  if (paymentState.status == PaymentStatus.processing)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    Icon(
                                      paymentState.status == PaymentStatus.completed
                                          ? Icons.check_circle
                                          : Icons.info_outline,
                                      color: paymentState.status == PaymentStatus.completed
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      paymentState.message,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatChip(
                                  label: 'Taps',
                                  value: '${paymentState.tapsCount}',
                                  color: Colors.blue,
                                ),
                                _StatChip(
                                  label: 'Processed',
                                  value: '${paymentState.processedCount}',
                                  color: Colors.green,
                                ),
                                _StatChip(
                                  label: 'Dropped',
                                  value: '${paymentState.droppedCount}',
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              final bloc = context.read<PaymentBloc>();
                              bloc.add(RegisterTapEvent());
                              bloc.add(const SubmitPaymentEvent(100));
                            },
                            icon: const Icon(Icons.touch_app),
                            label: const Text('Process Payment (\$100)'),
                            style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () => context.read<PaymentBloc>().add(ResetPaymentEvent()),
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset Stats',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Demo 2: restartable()
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
                        const Icon(Icons.search, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '2. restartable() — Live Search Autocomplete',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tapping quick queries immediately cancels any in-flight query and switches to the latest search query.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                    const Divider(height: 20),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.search, size: 16),
                          label: const Text('Flutter'),
                          onPressed: () => context.read<LiveSearchBloc>().add(const QueryChangedEvent('Flutter')),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.search, size: 16),
                          label: const Text('BLoC'),
                          onPressed: () => context.read<LiveSearchBloc>().add(const QueryChangedEvent('BLoC')),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.search, size: 16),
                          label: const Text('Dart'),
                          onPressed: () => context.read<LiveSearchBloc>().add(const QueryChangedEvent('Dart')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Type to search topics...',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (text) => context.read<LiveSearchBloc>().add(QueryChangedEvent(text)),
                    ),
                    const SizedBox(height: 14),
                    BlocBuilder<LiveSearchBloc, SearchState>(
                      builder: (context, searchState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (searchState.isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Fetching latest matches...', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            if (searchState.results.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: searchState.results.map((r) {
                                  return Chip(
                                    label: Text(r, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: Colors.blue.shade50,
                                  );
                                }).toList(),
                              )
                            else if (!searchState.isLoading && searchState.currentQuery.isNotEmpty)
                              const Text('No matches found.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 10),
                            Text('Cancellation Log:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 110),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: searchState.cancelLog.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                    searchState.cancelLog[index],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Colors.lightBlueAccent,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final MaterialColor color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color.shade800, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.shade900)),
        ],
      ),
    );
  }
}
