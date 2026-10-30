import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'weather_bloc.dart';

class SealedClassesPage extends StatelessWidget {
  const SealedClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherBloc(),
      child: const _SealedClassesView(),
    );
  }
}

class _SealedClassesView extends StatelessWidget {
  const _SealedClassesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Design — Sealed Classes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
            Card(
              color: Colors.cyan.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.cyan.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_reset, color: Colors.cyan.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Dart 3 Sealed Classes Pattern',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• `sealed` classes enable **exhaustive pattern matching** at compile time.\n'
                      '• In Dart 3, `switch (state)` warns or errors if you forget a state case.\n'
                      '• Supports elegant field destructuring: `WeatherSuccess(:final data)`.\n'
                      '• Best when states carry distinct, mutually exclusive data sets.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live State Rendered via Exhaustive Pattern Matching
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                // Dart 3 exhaustive switch expression
                return switch (state) {
                  WeatherInitial() => _buildInitialCard(),
                  WeatherLoading() => _buildLoadingCard(),
                  WeatherSuccess(:final data) => _buildSuccessCard(data),
                  WeatherError(:final message) => _buildErrorCard(message),
                };
              },
            ),
            const SizedBox(height: 24),

            // Interactive Buttons
            const Text(
              'Select City to Fetch Weather:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => context.read<WeatherBloc>().add(const FetchWeather('Tokyo')),
                  child: const Text('☀️ Tokyo'),
                ),
                FilledButton.tonal(
                  onPressed: () => context.read<WeatherBloc>().add(const FetchWeather('London')),
                  child: const Text('🌧️ London'),
                ),
                FilledButton.tonal(
                  onPressed: () => context.read<WeatherBloc>().add(const FetchWeather('Cairo')),
                  child: const Text('🌤️ Cairo'),
                ),
                OutlinedButton(
                  onPressed: () => context.read<WeatherBloc>().add(const FetchWeather('Atlantis')),
                  child: const Text('⚠️ Invalid City'),
                ),
                IconButton.filledTonal(
                  onPressed: () => context.read<WeatherBloc>().add(const ResetWeather()),
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
                '// Dart 3 Exhaustive Pattern Matching in builder:\n'
                'builder: (context, state) {\n'
                '  return switch (state) {\n'
                '    WeatherInitial() => const SearchPrompt(),\n'
                '    WeatherLoading() => const LoadingSpinner(),\n'
                '    WeatherSuccess(:final data) => WeatherCard(data),\n'
                '    WeatherError(:final message) => ErrorCard(message),\n'
                '  };\n'
                '};',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.cyanAccent,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.wb_sunny_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'WeatherInitial State',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Select a city button below to dispatch FetchWeather.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Column(
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'WeatherLoading State...',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(WeatherData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.shade300),
      ),
      child: Column(
        children: [
          Text(data.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            data.city,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${data.tempCelsius}°C — ${data.condition}',
            style: TextStyle(fontSize: 16, color: Colors.cyan.shade900, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 44),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

