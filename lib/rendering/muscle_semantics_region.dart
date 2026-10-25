import 'package:flutter/material.dart';
import '../data/models.dart';

class MuscleSemanticsRegion {
  final Rect bounds;
  final Muscle muscle;
  final MuscleSide side;
  final bool selected;

  const MuscleSemanticsRegion({
    required this.bounds,
    required this.muscle,
    required this.side,
    required this.selected,
  });

  String get label {
    if (side == MuscleSide.both) return muscle.displayName;
    return '${muscle.displayName}, ${side.displayName}';
  }
}
