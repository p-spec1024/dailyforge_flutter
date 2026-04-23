import 'package:flutter/material.dart';

// Design tokens local to the S10-T5a home page (light aesthetic only).
// Other pages keep using the app-wide dark theme.

const Color kCream = Color(0xFFFAFAF7);
const Color kCardBg = Colors.white;
const Color kCardBorder = Color(0xFFEEEEEE);

const Color kCoral = Color(0xFFD85A30);
const Color kDeepCoral = Color(0xFF8A3410);

const Color kPrimaryText = Color(0xFF1A1A1A);
const Color kSecondaryText = Color(0xFF6B6B6B);

// Heatmap reference colors (mirror of lib/utils/heatmap_color.dart ramp,
// kept as Color here for use in gradients/legends).
const Color kHeatmapFresh = Color(0xFFC8C8C8);
const Color kHeatmapLight = Color(0xFFF5C4B3);
const Color kHeatmapMedium = Color(0xFFF0997B);
const Color kHeatmapHeavy = Color(0xFFD85A30);
const Color kHeatmapMax = Color(0xFF993C1D);

// Stacked chart colors
const Color kChartStrength = Color(0xFFD85A30);
const Color kChartYoga = Color(0xFF14B8A6);
const Color kChartBreath = Color(0xFF3B82F6);

// Recent wins accent colors
const Color kTrophyGold = Color(0xFFF59E0B);
const Color kStarBlue = Color(0xFF3B82F6);

const double kCardRadius = 20;

const BoxShadow kCardShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 12,
  offset: Offset(0, 2),
);

BoxDecoration kCardDecoration() => BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(kCardRadius),
      boxShadow: const [kCardShadow],
    );

const TextStyle kSectionLabel = TextStyle(
  fontSize: 12,
  letterSpacing: 1.5,
  fontWeight: FontWeight.w600,
  color: kSecondaryText,
);
