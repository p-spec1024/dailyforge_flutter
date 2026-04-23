import 'package:flutter/material.dart';

/// Locked heatmap ramp for the 3D body map (S10-T5a). Volume is 0-100.
///
/// 0-20   Fresh   #C8C8C8 neutral gray
/// 20-40  Light   #F5C4B3
/// 40-60  Medium  #F0997B
/// 60-80  Heavy   #D85A30 coral
/// 80-100 Max     #993C1D deep coral
Color heatmapColor(int volume) {
  if (volume < 20) return const Color(0xFFC8C8C8);
  if (volume < 40) return const Color(0xFFF5C4B3);
  if (volume < 60) return const Color(0xFFF0997B);
  if (volume < 80) return const Color(0xFFD85A30);
  return const Color(0xFF993C1D);
}

/// Converts a Flutter [Color] to `[r, g, b, a]` floats in 0.0-1.0 range,
/// the format expected by `interactive_3d`'s PatchColor.color.
List<double> toRgbaList(Color c) => [c.r, c.g, c.b, c.a];

List<double> heatmapRgba(int volume) => toRgbaList(heatmapColor(volume));
