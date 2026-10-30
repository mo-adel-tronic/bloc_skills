import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_cubit.dart';

class AccessPatternsPage extends StatelessWidget {
  const AccessPatternsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: const _AccessPatternsView(),
    );
  }
}

class _AccessPatternsView extends StatelessWidget {
  const _AccessPatternsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access: read vs watch vs select'),
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
                        Icon(Icons.hub_outlined, color: Colors.orange.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'BLoC Access Methods',
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
                      '• `context.read<T>()`: Retrieves BLoC once without subscribing. Use ONLY in callbacks (buttons).\n'
                      '• `context.watch<T>()`: Subscribes to the FULL state. Rebuilds on ANY change in the state object.\n'
                      '• `context.select<T, R>(selector)`: Subscribes ONLY to a specific property. Rebuilds ONLY when that property changes!',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Live Demo Comparison
            const Text(
              'Live Rebuild Counter Comparison',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 1. Full State Watcher
            const _WatchFullProfileCard(),
            const SizedBox(height: 12),

            // 2. Select Score Card
            Row(
              children: const [
                Expanded(child: _SelectScoreCard()),
                SizedBox(width: 12),
                Expanded(child: _SelectNameCard()),
              ],
            ),
            const SizedBox(height: 24),

            // Control Buttons (Using context.read)
            const Text(
              'Actions (Dispatched via context.read<T>())',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    // context.read is safe inside callbacks
                    context.read<ProfileCubit>().incrementScore();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Score (+25)'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.read<ProfileCubit>().changeName();
                  },
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Change Name'),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    context.read<ProfileCubit>().reset();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Code Snippets Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: const Text(
                '// 1. In callbacks (no rebuild subscription):\n'
                'context.read<ProfileCubit>().incrementScore();\n\n'
                '// 2. In build() — rebuilds on ANY state property change:\n'
                'final profile = context.watch<ProfileCubit>().state;\n\n'
                '// 3. In build() — rebuilds ONLY when score changes:\n'
                'final score = context.select<ProfileCubit, int>(\n'
                '  (cubit) => cubit.state.score,\n'
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

class _WatchFullProfileCard extends StatefulWidget {
  const _WatchFullProfileCard();

  @override
  State<_WatchFullProfileCard> createState() => _WatchFullProfileCardState();
}

class _WatchFullProfileCardState extends State<_WatchFullProfileCard> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _rebuilds++;
    // Subscribes to the full state
    final profile = context.watch<ProfileCubit>().state;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.shade100,
            child: const Icon(Icons.remove_red_eye, color: Colors.red),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'context.watch<ProfileCubit>()',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Name: ${profile.name} | Score: ${profile.score} (${profile.badge})',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
          Chip(
            label: Text('Rebuilds: $_rebuilds', style: const TextStyle(fontSize: 11)),
            backgroundColor: Colors.red.shade100,
          ),
        ],
      ),
    );
  }
}

class _SelectScoreCard extends StatefulWidget {
  const _SelectScoreCard();

  @override
  State<_SelectScoreCard> createState() => _SelectScoreCardState();
}

class _SelectScoreCardState extends State<_SelectScoreCard> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _rebuilds++;
    // Subscribes ONLY to score
    final score = context.select<ProfileCubit, int>((cubit) => cubit.state.score);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'context.select (Score)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '$score pts',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ignores name changes',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text('Rebuilds: $_rebuilds', style: const TextStyle(fontSize: 10)),
            backgroundColor: Colors.green.shade100,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SelectNameCard extends StatefulWidget {
  const _SelectNameCard();

  @override
  State<_SelectNameCard> createState() => _SelectNameCardState();
}

class _SelectNameCardState extends State<_SelectNameCard> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _rebuilds++;
    // Subscribes ONLY to name
    final name = context.select<ProfileCubit, String>((cubit) => cubit.state.name);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'context.select (Name)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'Ignores score changes',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text('Rebuilds: $_rebuilds', style: const TextStyle(fontSize: 10)),
            backgroundColor: Colors.blue.shade100,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
