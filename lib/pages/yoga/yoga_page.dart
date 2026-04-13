import 'package:flutter/material.dart';

class YogaPage extends StatelessWidget {
  const YogaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Yoga',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
