import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'consumer_cubit.dart';

class ConsumerPage extends StatelessWidget {
  const ConsumerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsumerCubit(),
      child: const _ConsumerView(),
    );
  }
}

class _ConsumerView extends StatelessWidget {
  const _ConsumerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocConsumer — Builder + Listener'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
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
                        Icon(Icons.merge_type, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'BlocConsumer Concept',
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
                      '• Combines `BlocBuilder` + `BlocListener` in one clean widget.\n'
                      '• `builder`: returns widgets to render (UI progress, buttons).\n'
                      '• `listener`: triggers side-effects (SnackBars, dialogs).\n'
                      '• Eliminates awkward nested `BlocListener(child: BlocBuilder(...))`.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live BlocConsumer Widget
            BlocConsumer<ConsumerCubit, TaskState>(
              listenWhen: (previous, current) {
                // Only listen on completion or failure
                return current is TaskSuccess || current is TaskFailure;
              },
              listener: (context, state) {
                if (state is TaskSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Downloaded: ${state.fileName}'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is TaskFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: ${state.error}'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
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
                      Icon(
                        state is TaskSuccess
                            ? Icons.check_circle_outline
                            : (state is TaskFailure
                                ? Icons.error_outline
                                : (state is TaskInProgress
                                    ? Icons.downloading
                                    : Icons.cloud_download_outlined)),
                        size: 56,
                        color: state is TaskSuccess
                            ? Colors.green
                            : (state is TaskFailure ? Colors.red : Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state is TaskSuccess
                            ? 'Download Completed!'
                            : (state is TaskFailure
                                ? 'Download Failed'
                                : (state is TaskInProgress
                                    ? 'Downloading File...'
                                    : 'Ready to Download')),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (state is TaskInProgress) ...[
                        LinearProgressIndicator(
                          value: state.progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(state.progress * 100).toInt()}% completed',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ] else if (state is TaskSuccess) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            state.fileName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (state is TaskFailure) ...[
                        Text(
                          state.error,
                          style: const TextStyle(fontSize: 13, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        const Text(
                          'File: flutter_bloc_guide.pdf (2.4 MB)',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Controls
            BlocBuilder<ConsumerCubit, TaskState>(
              builder: (context, state) {
                final isInProgress = state is TaskInProgress;

                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: isInProgress
                          ? null
                          : () => context.read<ConsumerCubit>().startDownload(),
                      icon: const Icon(Icons.download),
                      label: const Text('Download (Success)'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isInProgress
                          ? null
                          : () => context.read<ConsumerCubit>().startDownload(shouldFail: true),
                      icon: const Icon(Icons.signal_wifi_bad),
                      label: const Text('Simulate Failure'),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.read<ConsumerCubit>().reset(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset',
                    ),
                  ],
                );
              },
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
                'BlocConsumer<TaskCubit, TaskState>(\n'
                '  // 1. listener handles side-effects (SnackBars, dialogs)\n'
                '  listener: (context, state) {\n'
                '    if (state is TaskSuccess) showSnackBar("Success!");\n'
                '  },\n'
                '  // 2. builder returns UI to render\n'
                '  builder: (context, state) {\n'
                '    return ProgressCard(state);\n'
                '  },\n'
                ');',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.lightBlueAccent,
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
