import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  testWidgets('paired muscles expose separate accessible actions',
      (tester) async {
    final selections = <(Muscle, MuscleSide)>[];
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 300,
        height: 500,
        child: MuscleMapView(
          onMuscleSelected: (muscle, side) {
            selections.add((muscle, side));
          },
        ),
      ),
    ));

    tester.semantics.performAction(
      find.semantics.byLabel('Biceps, Left'),
      SemanticsAction.tap,
    );
    tester.semantics.performAction(
      find.semantics.byLabel('Biceps, Right'),
      SemanticsAction.tap,
    );
    await tester.pump();

    expect(selections, [
      (Muscle.biceps, MuscleSide.left),
      (Muscle.biceps, MuscleSide.right),
    ]);
  });
}
