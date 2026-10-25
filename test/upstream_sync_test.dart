import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  group('upstream artwork', () {
    final expectedBackMuscles = [
      Muscle.rhomboids,
      Muscle.rotatorCuff,
      Muscle.rearDeltoid,
      Muscle.upperTrapezius,
      Muscle.lowerTrapezius,
    ];

    for (final gender in BodyGender.values) {
      test('${gender.name} back draws all added regions', () {
        for (final muscle in expectedBackMuscles) {
          expect(muscle.drawableFor(gender, BodySide.back), isTrue,
              reason: '${muscle.name} must have artwork');
        }
      });
    }

    test('male front draws upper trapezius', () {
      expect(Muscle.upperTrapezius.drawableFor(BodyGender.male, BodySide.front),
          isTrue);
    });

    test('female front draws upper trapezius', () {
      expect(
          Muscle.upperTrapezius.drawableFor(BodyGender.female, BodySide.front),
          isTrue);
    });

    test('female back draws ankles', () {
      expect(
          Muscle.ankles.drawableFor(BodyGender.female, BodySide.back), isTrue);
    });

    test('female back does not expose a head beneath hair', () {
      expect(
          Muscle.head.drawableFor(BodyGender.female, BodySide.back), isFalse);
    });

    test('drawable reports whether any view contains the muscle', () {
      expect(Muscle.rhomboids.drawable, isTrue);
      expect(Muscle.values.every((muscle) => muscle.drawable), isTrue);
    });
  });
}
