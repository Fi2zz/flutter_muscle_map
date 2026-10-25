import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';
import 'package:muscle_map/widgets/heatmap_mapper.dart';

void main() {
  test('stepped heatmap applies threshold before interpolation', () {
    const config = HeatmapConfiguration(
      colorScale: HeatmapColorScale.workoutStepped,
      threshold: 0.5,
    );

    final highlights = buildHeatmapHighlights(
      data: const {Muscle.chest: 0.59},
      config: config,
    );

    expect(highlights[Muscle.chest], isNotNull);
    expect(
      highlights[Muscle.chest]!.color,
      HeatmapColorScale.workoutStepped.colorForIntensity(0.4),
    );
  });

  test('ease out cannot promote raw values past the threshold', () {
    const config = HeatmapConfiguration(
      colorScale: HeatmapColorScale.thermal,
      interpolation: InterpolationType.easeOut,
      threshold: 0.5,
    );

    final highlights = buildHeatmapHighlights(
      data: const {Muscle.chest: 0.49, Muscle.abs: 0.5},
      config: config,
    );

    expect(highlights.containsKey(Muscle.chest), isFalse);
    expect(highlights.containsKey(Muscle.abs), isTrue);
  });
}
