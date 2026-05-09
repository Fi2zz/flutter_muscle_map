import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  test('Muscle enum has 36 values', () {
    expect(Muscle.values.length, 36);
  });

  test('Muscle display names are non-empty', () {
    for (final muscle in Muscle.values) {
      expect(muscle.displayName.isNotEmpty, true);
    }
  });

  test('BodyGender has male and female', () {
    expect(BodyGender.values.length, 2);
  });

  test('BodySide has front and back', () {
    expect(BodySide.values.length, 2);
  });
}
