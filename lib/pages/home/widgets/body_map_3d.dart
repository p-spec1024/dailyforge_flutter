import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactive_3d/interactive_3d.dart';

import '../../../data/muscle_groups.dart';
import '../../../utils/heatmap_color.dart';

enum BodyMapMode { muscles, flexibility }

const List<double> _bgCream = [0.98, 0.98, 0.97, 1.0];
const List<double> _selectionCoral = [0.95, 0.55, 0.40, 1.0];
const List<double> _neutralGrayRgba = [0.784, 0.784, 0.784, 1.0];

/// 3D anatomical figure with heatmap coloring and tap-to-select.
///
/// Native (Filament/SceneKit) owns selection state — the host observes via
/// [onMuscleTap] if it needs to mirror the selection into its own state.
/// The only place this widget imperatively reaches back into native is
/// `clearSelections()` on mode switch, which is an explicit user action
/// rather than reactive sync. Reactive sync fights the package's
/// architecture and stalls its input pipeline on Android (see Step 2
/// post-mortem for the symptoms).
class BodyMap3D extends StatefulWidget {
  final BodyMapMode mode;

  /// Group → 0-100 volume (e.g. 'Chest' → 72). Used in Muscles mode.
  final Map<String, int> muscleVolumes;

  /// Region → 0-100 mobility score (e.g. 'Spine' → 68). Used in Flexibility mode.
  final Map<String, int> flexibilityScores;

  /// Fires with the resolved group name on muscle tap, or `null` to deselect.
  final void Function(String? group) onMuscleTap;

  const BodyMap3D({
    super.key,
    required this.mode,
    required this.muscleVolumes,
    required this.flexibilityScores,
    required this.onMuscleTap,
  });

  @override
  State<BodyMap3D> createState() => _BodyMap3DState();
}

class _BodyMap3DState extends State<BodyMap3D> {
  final Interactive3dController _controller = Interactive3dController();
  late final Map<String, String> _meshToGroup = buildMeshToGroup();

  @override
  void didUpdateWidget(covariant BodyMap3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync to native on mode change — this is the one time we're
    // certain the user wants to wipe selection (toggle pressed).
    if (oldWidget.mode != widget.mode) {
      _controller.clearSelections();
    }
  }

  List<PatchColor> _buildPatchColors() {
    final patches = <PatchColor>[];

    if (widget.mode == BodyMapMode.muscles) {
      for (final mesh in tappableMeshes) {
        final group = _meshToGroup[mesh];
        final volume = group == null ? 0 : (widget.muscleVolumes[group] ?? 0);
        patches.add(PatchColor(name: mesh, color: heatmapRgba(volume)));
      }
    } else {
      // Flexibility: a mesh may belong to multiple regions — take MAX score.
      final meshScores = <String, int>{};
      widget.flexibilityScores.forEach((region, score) {
        final meshes = flexibilityToMeshes[region];
        if (meshes == null) return;
        for (final m in meshes) {
          meshScores[m] = math.max(meshScores[m] ?? 0, score);
        }
      });
      for (final mesh in tappableMeshes) {
        patches.add(
          PatchColor(name: mesh, color: heatmapRgba(meshScores[mesh] ?? 0)),
        );
      }
    }

    patches.add(PatchColor(name: 'base', color: _neutralGrayRgba));
    return patches;
  }

  void _handleSelection(List<EntityData> entities) {
    HapticFeedback.selectionClick();

    String? resolved;
    if (entities.isNotEmpty) {
      final meshName = entities.first.name;
      if (meshName != 'base' && tappableMeshes.contains(meshName)) {
        resolved = widget.mode == BodyMapMode.muscles
            ? _meshToGroup[meshName]
            : meshToFlexibilityRegion(meshName);
      }
    }

    // Pure observer: let native own selection state. If the tap didn't
    // resolve to a group, the card falls back to placeholder but native
    // keeps whatever highlight it considers correct.
    widget.onMuscleTap(resolved);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 420,
        child: Interactive3d(
          controller: _controller,
          modelPath: 'assets/models/male_anatomy_split.glb',
          solidBackgroundColor: _bgCream,
          selectionColor: _selectionCoral,
          defaultZoom: 2.5,
          patchColors: _buildPatchColors(),
          onSelectionChanged: _handleSelection,
        ),
      ),
    );
  }
}
