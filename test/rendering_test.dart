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

  Offset viewPoint(Offset svg, BodyGender gender) {
    final viewBox = BodyPathProvider.viewBox(gender, BodySide.back);
    final scale = (size.width / viewBox.size.width)
        .clamp(0.0, size.height / viewBox.size.height);
    return Offset(
      (size.width - viewBox.size.width * scale) / 2 +
          (svg.dx - viewBox.origin.dx) * scale,
      (size.height - viewBox.size.height * scale) / 2 +
          (svg.dy - viewBox.origin.dy) * scale,
    );
  }

  for (final gender in BodyGender.values) {
    final left = gender == BodyGender.male
        ? const Offset(1050, 360)
        : const Offset(1110, 350);
    final right = gender == BodyGender.male
        ? const Offset(1110, 360)
        : const Offset(1170, 350);

    for (final sample in [(left, MuscleSide.left), (right, MuscleSide.right)]) {
      test('${gender.name} ${sample.$2.name} uses independent coordinates', () {
        final point = viewPoint(sample.$1, gender);
        final visibleBody = renderer(gender, false);
        final hiddenBody = renderer(gender, true);

        expect(visibleBody.hitTest(point, size), (Muscle.rhomboids, sample.$2));
        expect(hiddenBody.hitTest(point, size), (Muscle.trapezius, sample.$2));
      });
    }
  }
}
