import 'package:flutter/material.dart';

void main() {
  runApp(const BlocSkillsApp());
}

class BlocSkillsApp extends StatelessWidget {
  const BlocSkillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLoC Skills — Course Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      SkillItem(
        title: 'Cubit — The Simplified BLoC',
        subtitle: 'Methods, emit, State types, Lifecycle & Clean up',
        icon: Icons.speed,
        color: Colors.blue,
        examples: [],
      ),
      SkillItem(
        title: 'BLoC — Events & States',
        subtitle: 'Sealed classes, Event handlers, Async emit, Observer',
        icon: Icons.sync_alt,
        color: Colors.deepPurple,
        examples: [],
      ),
      SkillItem(
        title: 'BLoC Widgets',
        subtitle: 'BlocBuilder, BlocListener, BlocConsumer, MultiBloc',
        icon: Icons.widgets_outlined,
        color: Colors.teal,
        examples: [],
      ),
      SkillItem(
        title: 'BLoC Access & DI',
        subtitle: 'read, watch, select, BlocProvider.value, RepositoryProvider',
        icon: Icons.hub_outlined,
        color: Colors.orange,
        examples: [],
      ),
      SkillItem(
        title: 'State Design Patterns',
        subtitle: 'Status copyWith, Equatable equality, Sealed classes',
        icon: Icons.architecture,
        color: Colors.indigo,
        examples: [],
      ),
      SkillItem(
        title: 'Advanced BLoC Patterns',
        subtitle: 'BLoC-to-BLoC, Event Transformers, Testing, HydratedBloc',
        icon: Icons.psychology_outlined,
        color: Colors.redAccent,
        examples: [],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📘 BLoC Skills Reference',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: skills.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final skill = skills[index];
          final hasExamples = skill.examples.isNotEmpty;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: skill.color.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (!hasExamples) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${skill.title} examples coming in next commits!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SkillExamplesScreen(skill: skill),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: skill.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(skill.icon, color: skill.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skill ${index + 1}: ${skill.title}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            skill.subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      hasExamples ? Icons.arrow_forward_ios : Icons.lock_outline,
                      size: 16,
                      color: hasExamples ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SkillItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<ExampleItem> examples;

  SkillItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.examples,
  });
}

class ExampleItem {
  final String title;
  final Widget page;

  ExampleItem({required this.title, required this.page});
}

class SkillExamplesScreen extends StatelessWidget {
  final SkillItem skill;

  const SkillExamplesScreen({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(skill.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: skill.examples.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final example = skill.examples[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: skill.color,
              foregroundColor: Colors.white,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              example.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: skill.color.withValues(alpha: 0.06),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => example.page),
              );
            },
          );
        },
      ),
    );
  }
}
