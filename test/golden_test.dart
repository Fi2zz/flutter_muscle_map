import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  Muscle highlightedMuscle(BodySide side) {
    return side == BodySide.front ? Muscle.chest : Muscle.upperBack;
  }

  Map<Muscle, MuscleHighlight> regionHighlights() {
    const muscles = [
      Muscle.upperTrapezius,
      Muscle.rhomboids,
      Muscle.lowerTrapezius,
      Muscle.rearDeltoid,
      Muscle.rotatorCuff,
    ];
    return {
      for (var index = 0; index < muscles.length; index++)
        muscles[index]: MuscleHighlight(
          muscle: muscles[index],
          color: Colors.primaries[index],
        ),
    };
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
          hideSubGroups: variant != 'subgroups' && variant != 'regions',
          highlights: switch (variant) {
            'body' => {
                muscle: MuscleHighlight(muscle: muscle, color: Colors.red),
              },
            'regions' => regionHighlights(),
            'hostHighlight' => {
                Muscle.upperBack: const MuscleHighlight(
                  muscle: Muscle.upperBack,
                  color: Colors.red,
                ),
              },
            _ => const {},
          },
          selectedMuscles:
              variant == 'hostSelection' ? {Muscle.upperBack} : const {},
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
      for (final variant in ['default', 'body', 'heatmap', 'subgroups']) {
        testWidgets('${gender.name} ${side.name} $variant', (tester) async {
          await tester.pumpWidget(buildMap(gender, side, variant));

          await expectLater(
            find.byType(RepaintBoundary),
            matchesGoldenFile(
                'goldens/${gender.name}_${side.name}_$variant.png'),
          );
        });
      }
      if (side == BodySide.back) {
        for (final variant in ['regions', 'hostHighlight', 'hostSelection']) {
          testWidgets('${gender.name} back $variant', (tester) async {
            await tester.pumpWidget(buildMap(gender, side, variant));

            await expectLater(
              find.byType(RepaintBoundary),
              matchesGoldenFile('goldens/${gender.name}_back_$variant.png'),
            );
          });
        }
      }
    }
  }
}
