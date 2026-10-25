import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  const size = Size(300, 500);

  BodyRenderer renderer(BodyGender gender, bool hideSubGroups) {
    return BodyRenderer(
      gender: gender,
      side: BodySide.back,
      highlights: const {},
      style: BodyViewStyle.defaults,
      hideSubGroups: hideSubGroups,
    );
  }

  Offset findPoint(BodyRenderer body, Muscle muscle) {
    final bounds = body.boundingRect(muscle, size)!;
    for (var x = bounds.left; x < bounds.right; x += 2) {
      for (var y = bounds.top; y < bounds.bottom; y += 2) {
        final point = Offset(x, y);
        if (body.hitTest(point, size)?.$1 == muscle) return point;
      }
    }
    throw StateError('No point inside ${muscle.name}');
  }

  for (final gender in BodyGender.values) {
    test('${gender.name} hidden regions resolve taps to their hosts', () {
      final visibleBody = renderer(gender, false);
      final hiddenBody = renderer(gender, true);
      final rhomboidsPoint = findPoint(visibleBody, Muscle.rhomboids);
      final rotatorPoint = findPoint(visibleBody, Muscle.rotatorCuff);

      expect(hiddenBody.hitTest(rhomboidsPoint, size)?.$1, Muscle.trapezius);
      expect(hiddenBody.hitTest(rotatorPoint, size)?.$1, Muscle.upperBack);
    });
  }
}
