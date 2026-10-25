import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  setUp(() => PathCache().clear());

  test('path instances are shared across renderer caches', () {
    const cache = PathCache();
    final path = BodyPathProvider.paths(BodyGender.male, BodySide.front)
        .first
        .allPaths
        .first;

    expect(identical(cache.parsePath(path), const PathCache().parsePath(path)),
        isTrue);
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
