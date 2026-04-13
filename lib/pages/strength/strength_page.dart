import 'package:flutter/material.dart';

class StrengthPage extends StatelessWidget {
  const StrengthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Strength',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
