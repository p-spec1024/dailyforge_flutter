import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BreathworkTimerPage extends StatelessWidget {
  final int techniqueId;
  const BreathworkTimerPage({super.key, required this.techniqueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Breathwork'),
      ),
      body: Center(child: Text('Timer for technique $techniqueId')),
    );
  }
}
