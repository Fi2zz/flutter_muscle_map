import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  test('workout stepped scale applies five discrete steps by default', () {
    const config = HeatmapConfiguration(
      colorScale: HeatmapColorScale.workoutStepped,
    );

    expect(config.effectiveInterpolation, InterpolationType.stepped);
    expect(config.effectiveInterpolation.apply(0.59), 0.4);
    expect(config.effectiveInterpolation.apply(0.6), 0.6);
    expect(config.effectiveInterpolation.apply(1.0), 1.0);
  });

  test('thermal smooth scale applies ease in out by default', () {
    const config = HeatmapConfiguration(
      colorScale: HeatmapColorScale.thermalSmooth,
    );

    expect(config.effectiveInterpolation, InterpolationType.easeInOut);
    expect(config.effectiveInterpolation.apply(0.5), 0.5);
  });

  test('explicit non-linear interpolation overrides the scale', () {
    const config = HeatmapConfiguration(
      colorScale: HeatmapColorScale.workoutStepped,
      interpolation: InterpolationType.easeIn,
    );

    expect(config.effectiveInterpolation, InterpolationType.easeIn);
    expect(config.effectiveInterpolation.apply(0.5), 0.25);
  });

  testWidgets('legend samples the scale interpolation', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: HeatmapLegend(colorScale: HeatmapColorScale.workoutStepped),
    ));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    final colors = decoration.gradient!.colors;
    expect(colors.length, greaterThan(5));
    expect(colors[19], colors[0]);
    expect(colors[20], isNot(colors[0]));
    expect(colors[39], colors[20]);
  });
}
