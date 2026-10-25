import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  Muscle highlightedMuscle(BodySide side) {
    return side == BodySide.front ? Muscle.chest : Muscle.upperBack;
  }

  Widget buildMap(BodyGender gender, BodySide side, String variant) {
    final muscle = highlightedMuscle(side);
    return RepaintBoundary(
      child: SizedBox(
        width: 300,
        height: 500,
        child: MuscleMapView(
          gender: gender,
          side: side,
          isAnimated: true,
          hideSubGroups: variant != 'subgroups',
          highlights: variant == 'body'
              ? {muscle: MuscleHighlight(muscle: muscle, color: Colors.red)}
              : const {},
          heatmapData: variant == 'heatmap' ? {muscle: 0.59} : null,
          heatmapConfig: variant == 'heatmap'
              ? const HeatmapConfiguration(
                  colorScale: HeatmapColorScale.workoutStepped,
                )
              : null,
        ),
      ),
    );
  }

  for (final gender in BodyGender.values) {
    for (final side in BodySide.values) {
      for (final variant in ['body', 'heatmap', 'subgroups']) {
        testWidgets('${gender.name} ${side.name} $variant', (tester) async {
          await tester.pumpWidget(buildMap(gender, side, variant));
          await tester.pump();

          await expectLater(
            find.byType(RepaintBoundary),
            matchesGoldenFile(
                'goldens/${gender.name}_${side.name}_$variant.png'),
          );
        });
      }
    }
  }
}
