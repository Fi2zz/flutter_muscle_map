import '../data/models.dart';

Map<Muscle, MuscleHighlight> buildHeatmapHighlights({
  required Map<Muscle, double> data,
  required HeatmapConfiguration config,
  Map<Muscle, MuscleHighlight> highlights = const {},
}) {
  final result = Map<Muscle, MuscleHighlight>.of(highlights);
  for (final entry in data.entries) {
    if (entry.value < config.threshold) continue;
    final intensity = config.effectiveInterpolation.apply(entry.value);
    result[entry.key] = MuscleHighlight(
      muscle: entry.key,
      color: config.colorScale.colorForIntensity(intensity),
      opacity: 0.85,
    );
  }
  return result;
}
