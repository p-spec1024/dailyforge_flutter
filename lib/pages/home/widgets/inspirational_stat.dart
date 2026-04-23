import 'package:flutter/material.dart';

import '../../../data/mock_body_map_data.dart';
import '_tokens.dart';

class InspirationalStat extends StatelessWidget {
  const InspirationalStat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48, bottom: 32),
      child: Center(
        child: Text(
          mockInspirationalStat,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
            color: kDeepCoral,
          ),
        ),
      ),
    );
  }
}
