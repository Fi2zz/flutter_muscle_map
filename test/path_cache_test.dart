import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  setUp(() => PathCache().clear());

  test('renderers share paths without exposing mutable cache entries', () {
    const cache = PathCache();
    final source = BodyPathProvider.paths(BodyGender.male, BodySide.front)
        .first
        .allPaths
        .first;

    final shared = cache.parsePath(source);
    expect(identical(shared, const PathCache().parsePath(source)), isFalse);

    final bounds = shared.getBounds();
    shared.reset();
    final subsequent = cache.parsePath(source, defensiveCopy: false);
    expect(subsequent.getBounds(), bounds);
  });

  test('preloadArtwork parses every body path', () {
    const cache = PathCache();
    final pathCount = BodyGender.values
        .expand((gender) {
          return BodySide.values.expand((side) {
            return BodyPathProvider.paths(gender, side)
                .expand((bodyPart) => bodyPart.allPaths);
          });
        })
        .toSet()
        .length;

    expect(PathCache.cachedPathCount, 0);
    cache.preloadArtwork();
    expect(PathCache.cachedPathCount, pathCount);
  });
}
