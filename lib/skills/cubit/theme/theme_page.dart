import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_cubit.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: const _ThemeView(),
    );
  }
}

class _ThemeView extends StatelessWidget {
  const _ThemeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit State — Theme Toggle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Explanation Card
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
                        Icon(Icons.palette_outlined, color: Colors.purple.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Complex / Enum State',
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
                      '• Cubit state is NOT limited to primitives (int, bool).\n'
                      '• You can use Enums, custom Classes, or Collections.\n'
                      '• Here, state is ThemeMode (light, dark, system).\n'
                      '• BlocBuilder listens to ThemeMode changes to repaint the preview.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Live Theme Preview Card
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;

                final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
                final textColor = isDark ? Colors.white : Colors.black87;
                final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.purple.shade400 : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        size: 56,
                        color: isDark ? Colors.amber : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Active Theme: ${themeMode.name.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isDark
                            ? 'Dark mode active — low eye strain at night'
                            : 'Light mode active — clear daylight readability',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: subtextColor),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Control Buttons
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, currentMode) {
                return SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_brightness),
                      label: Text('System'),
                    ),
                  ],
                  selected: {currentMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    context.read<ThemeCubit>().setTheme(newSelection.first);
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Toggle Button
            FilledButton.icon(
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Toggle Light / Dark'),
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
                '// Cubit with Enum state:\n'
                'class ThemeCubit extends Cubit<ThemeMode> {\n'
                '  ThemeCubit() : super(ThemeMode.light);\n'
                '  void toggleTheme() => emit(\n'
                '    state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,\n'
                '  );\n'
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
