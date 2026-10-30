import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'listener_cubit.dart';

class ListenerPage extends StatelessWidget {
  const ListenerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListenerCubit(),
      child: const _ListenerView(),
    );
  }
}

class _ListenerView extends StatefulWidget {
  const _ListenerView();

  @override
  State<_ListenerView> createState() => _ListenerViewState();
}

class _ListenerViewState extends State<_ListenerView> {
  final List<String> _notifications = [];

  void _showWarningDialog(BuildContext context, int balance) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Overdraft Alert!'),
        content: Text(
          'Your account balance has dropped below zero: \$$balance!\n'
          'This dialog was triggered by BlocListener as a side effect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocListener — Side Effects & Dialogs'),
      ),
      // BlocListener handles side effects without touching UI rebuilds
      body: BlocListener<ListenerCubit, WalletState>(
        listenWhen: (previous, current) {
          // Trigger listener on significant milestones:
          // 1. Drops below 0
          // 2. Crosses 100
          // 3. Reaches exact 0
          return (current.balance < 0 && previous.balance >= 0) ||
              (current.balance >= 100 && previous.balance < 100) ||
              current.balance == 0;
        },
        listener: (context, state) {
          if (state.balance < 0) {
            _showWarningDialog(context, state.balance);
            setState(() {
              _notifications.insert(0, '🚨 Dialog shown: Overdraft balance (\$$state.balance)');
            });
          } else if (state.balance >= 100) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 High Balance Achieved: \$${state.balance}!'),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
            setState(() {
              _notifications.insert(0, '🎉 SnackBar shown: High balance (\$$state.balance)');
            });
          } else if (state.balance == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('ℹ️ Balance is exactly zero.'),
                backgroundColor: Colors.orange.shade800,
                duration: const Duration(seconds: 2),
              ),
            );
            setState(() {
              _notifications.insert(0, 'ℹ️ SnackBar shown: Balance reached \$0');
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Concept Card
              Card(
                color: Colors.amber.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.amber.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active_outlined, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Text(
                            'BlocListener Concept',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• `BlocListener` executes a callback in response to state changes.\n'
                        '• It does NOT rebuild its child widget!\n'
                        '• Perfect for: SnackBars, Dialogs, BottomSheets, and Navigation.\n'
                        '• `listenWhen: (previous, current)` guards when the listener fires.',
                        style: TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Balance Display
              BlocBuilder<ListenerCubit, WalletState>(
                builder: (context, state) {
                  final isNegative = state.balance < 0;
                  final isHigh = state.balance >= 100;
                  final color = isNegative
                      ? Colors.red
                      : (isHigh ? Colors.green.shade700 : Colors.teal.shade800);

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Wallet Balance',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${state.balance}',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.lastAction,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Action buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => context.read<ListenerCubit>().deposit(30),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Deposit +\$30'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.read<ListenerCubit>().withdraw(30),
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Withdraw -\$30'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.read<ListenerCubit>().withdraw(60),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Withdraw -\$60 (Overdraft)'),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      context.read<ListenerCubit>().reset();
                      setState(() => _notifications.clear());
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Log of Side Effects Triggered
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Side Effects Triggered by BlocListener',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '(${_notifications.length} events)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'No side effects yet. Tap buttons to trigger milestones!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _notifications[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.amberAccent,
                            ),
                          ),
                        );
                      },
                    ),
              ),
              const SizedBox(height: 24),

              // Code Snippet
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: const Text(
                  'BlocListener<WalletCubit, WalletState>(\n'
                  '  listenWhen: (previous, current) => current.balance < 0,\n'
                  '  listener: (context, state) {\n'
                  '    // Side effect without rebuilding child!\n'
                  '    showDialog(context: context, ...);\n'
                  '  },\n'
                  '  child: WalletView(),\n'
                  ');',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.amberAccent,
                    fontSize: 12,
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
