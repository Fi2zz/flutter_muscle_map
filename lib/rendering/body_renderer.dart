import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/path_provider.dart';
import 'svg_parser.dart';
import 'muscle_semantics_region.dart';

class PathCache {
  static final Map<String, Path> _cache = {};
  static final SVGPathParser _parser = SVGPathParser();

  const PathCache();

  static int get cachedPathCount => _cache.length;

  /// Returns a mutable copy by default. Shared paths requested with
  /// `defensiveCopy: false` must not be mutated.
  Path parsePath(String d, {bool defensiveCopy = true}) {
    final path = _cache.putIfAbsent(d, () => _parser.parse(d));
    return defensiveCopy ? Path.from(path) : path;
  }

  /// Parses every body path synchronously into the cache shared by all renderers.
  void preloadArtwork() {
    for (final gender in BodyGender.values) {
      for (final side in BodySide.values) {
        for (final bodyPart in BodyPathProvider.paths(gender, side)) {
          bodyPart.allPaths.forEach(parsePath);
        }
      }
    }
  }

  void clear() => _cache.clear();
}

class BodyRenderer {
  final BodyGender gender;
  final BodySide side;
  final Map<Muscle, MuscleHighlight> highlights;
  final BodyViewStyle style;
  final Set<Muscle> selectedMuscles;
  final double selectionPulseFactor;
  final bool hideSubGroups;
  final HeatmapConfiguration? heatmapConfig;

  final PathCache _pathCache = PathCache();

  BodyRenderer({
    required this.gender,
    required this.side,
    required this.highlights,
    required this.style,
    this.selectedMuscles = const {},
    this.selectionPulseFactor = 1.0,
    this.hideSubGroups = true,
    this.heatmapConfig,
  });

  /// Compute scale and offset for fitting the body into the given size
  _TransformData _computeTransform(Size size) {
    final viewBox = BodyPathProvider.viewBox(gender, side);
    final scaleX = size.width / viewBox.size.width;
    final scaleY = size.height / viewBox.size.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - viewBox.size.width * scale) / 2 -
        viewBox.origin.dx * scale;
    final offsetY = (size.height - viewBox.size.height * scale) / 2 -
        viewBox.origin.dy * scale;

    return _TransformData(scale: scale, offsetX: offsetX, offsetY: offsetY);
  }

  void render(Canvas canvas, Size size) {
    final t = _computeTransform(size);
    final bodyParts = BodyPathProvider.paths(gender, side);

    // Save canvas state and apply global transform
    canvas.save();
    canvas.translate(t.offsetX, t.offsetY);
    canvas.scale(t.scale, t.scale);

    for (final bodyPart in bodyParts) {
      if (hideSubGroups) {
        final m = bodyPart.slug.muscle;
        if (m != null && m.isSubGroup && !m.isAlwaysVisibleSubGroup) continue;
      }

      final muscle = bodyPart.slug.muscle;
      final highlight = muscle != null ? highlights[muscle] : null;
      final selectedHost = hideSubGroups ? muscle?.defaultModeHost : null;
      final directlySelected =
          muscle != null && selectedMuscles.contains(muscle);
      final isSelected = directlySelected ||
          (selectedHost != null && selectedMuscles.contains(selectedHost));
      final hiddenOverlay = muscle?.overlayRegion == true &&
          highlight == null &&
          !directlySelected;
      if (hiddenOverlay) continue;

      final fill = _resolveFill(bodyPart.slug, highlight, isSelected);
      final highlightOpacity = highlight?.opacity ?? 1.0;
      final needsOpacityLayer = highlightOpacity < 1.0 && highlight != null;
      final needsShadow = style.shadowRadius > 0 && highlight != null;

      final allPaths = <_PathEntry>[
        ...bodyPart.common.map((p) => _PathEntry(p, MuscleSide.both)),
        ...bodyPart.left.map((p) => _PathEntry(p, MuscleSide.left)),
        ...bodyPart.right.map((p) => _PathEntry(p, MuscleSide.right)),
      ];

      for (final entry in allPaths) {
        final path = _pathCache.parsePath(entry.path, defensiveCopy: false);

        // Get bounds in SVG coordinate space for shader
        final bounds = path.getBounds();
        final boundsInView = Rect.fromLTRB(
          bounds.left * t.scale + t.offsetX,
          bounds.top * t.scale + t.offsetY,
          bounds.right * t.scale + t.offsetX,
          bounds.bottom * t.scale + t.offsetY,
        );

        final paint = Paint()..style = PaintingStyle.fill;

        final shader = fill.toShader(boundsInView);
        if (shader != null) {
          paint.shader = shader;
        } else {
          paint.color = fill.solidColor;
        }

        if (needsShadow ||
            needsOpacityLayer ||
            (isSelected && selectionPulseFactor != 1.0)) {
          canvas.saveLayer(bounds, Paint());

          if (needsShadow) {
            final shadowPaint = Paint()
              ..style = PaintingStyle.fill
              ..color = style.shadowColor
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                style.shadowRadius /
                    t.scale, // Scale shadow radius back to SVG space
              );
            canvas.save();
            canvas.translate(
              style.shadowOffset.dx / t.scale,
              style.shadowOffset.dy / t.scale,
            );
            canvas.drawPath(path, shadowPaint);
            canvas.restore();
          }

          double opacity = 1.0;
          if (needsOpacityLayer) opacity = highlightOpacity;
          if (isSelected && selectionPulseFactor != 1.0) {
            opacity *= selectionPulseFactor;
          }

          if (opacity < 1.0) {
            paint.color = paint.color.withValues(alpha: opacity);
          }

          canvas.drawPath(path, paint);
          canvas.restore();
        } else {
          if (isSelected && selectionPulseFactor != 1.0) {
            paint.color = paint.color.withValues(alpha: selectionPulseFactor);
          }
          canvas.drawPath(path, paint);
        }

        // Stroke
        if (style.strokeWidth > 0) {
          final strokePaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = style.strokeColor
            ..strokeWidth =
                style.strokeWidth / t.scale; // Scale stroke to SVG space
          canvas.drawPath(path, strokePaint);
        }

        // Selection stroke
        if (isSelected) {
          final selPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = style.selectionStrokeColor
            ..strokeWidth = style.selectionStrokeWidth / t.scale;
          canvas.drawPath(path, selPaint);
        }
      }
    }

    canvas.restore();
  }

  MuscleFill _resolveFill(
      BodySlug slug, MuscleHighlight? highlight, bool isSelected) {
    if (slug == BodySlug.hair) return SolidMuscleFill(style.hairColor);
    if (slug == BodySlug.head) return SolidMuscleFill(style.headColor);
    if (isSelected) return SolidMuscleFill(style.selectionColor);
    if (highlight != null) {
      return highlight.fill ?? SolidMuscleFill(highlight.color);
    }

    final muscle = slug.muscle;
    final host = muscle?.parentGroup ?? muscle?.regionHost;
    final parentHighlight = host != null ? highlights[host] : null;
    if (parentHighlight != null) {
      return parentHighlight.fill ?? SolidMuscleFill(parentHighlight.color);
    }

    return SolidMuscleFill(style.fillColor);
  }

  (Muscle, MuscleSide)? hitTest(Offset point, Size size) {
    final t = _computeTransform(size);
    // Transform point from view coordinates to SVG coordinates
    final svgX = (point.dx - t.offsetX) / t.scale;
    final svgY = (point.dy - t.offsetY) / t.scale;
    final svgPoint = Offset(svgX, svgY);

    final bodyParts = BodyPathProvider.paths(gender, side);

    final sortedParts = List<BodyPartPathData>.from(bodyParts)
      ..sort((a, b) {
        final aPriority = a.slug.muscle?.hitTestPriority ?? 0;
        final bPriority = b.slug.muscle?.hitTestPriority ?? 0;
        return bPriority.compareTo(aPriority);
      });

    for (final bodyPart in sortedParts) {
      final muscle = bodyPart.slug.muscle;
      if (muscle == null) continue;

      if (hideSubGroups &&
          muscle.isSubGroup &&
          !muscle.isAlwaysVisibleSubGroup) {
        continue;
      }

      final resolvedMuscle =
          hideSubGroups ? muscle.defaultModeHost ?? muscle : muscle;

      for (final pathString in bodyPart.left) {
        final path = _pathCache.parsePath(pathString, defensiveCopy: false);
        if (path.contains(svgPoint)) return (resolvedMuscle, MuscleSide.left);
      }

      for (final pathString in bodyPart.right) {
        final path = _pathCache.parsePath(pathString, defensiveCopy: false);
        if (path.contains(svgPoint)) return (resolvedMuscle, MuscleSide.right);
      }

      for (final pathString in bodyPart.common) {
        final path = _pathCache.parsePath(pathString, defensiveCopy: false);
        if (path.contains(svgPoint)) return (resolvedMuscle, MuscleSide.both);
      }
    }

    return null;
  }

  List<MuscleSemanticsRegion> semanticsRegions(Size size) {
    final transform = _computeTransform(size);
    final regions = <MuscleSemanticsRegion>[];
    for (final bodyPart in BodyPathProvider.paths(gender, side)) {
      final muscle = bodyPart.slug.muscle;
      if (muscle == null || muscle.isCosmeticPart) continue;
      if (hideSubGroups &&
          muscle.isSubGroup &&
          !muscle.isAlwaysVisibleSubGroup) {
        continue;
      }
      final selected = selectedMuscles.contains(muscle) ||
          (hideSubGroups && selectedMuscles.contains(muscle.defaultModeHost));
      if (muscle.overlayRegion &&
          !highlights.containsKey(muscle) &&
          !selectedMuscles.contains(muscle)) {
        continue;
      }
      regions.addAll(_semanticRegionsForPart(
        bodyPart,
        transform,
        selected,
      ));
    }
    return regions;
  }

  List<MuscleSemanticsRegion> _semanticRegionsForPart(
    BodyPartPathData bodyPart,
    _TransformData transform,
    bool selected,
  ) {
    final muscle = bodyPart.slug.muscle!;
    final resolved = hideSubGroups ? muscle.defaultModeHost ?? muscle : muscle;
    final entries = [
      ...bodyPart.common.map((path) => _PathEntry(path, MuscleSide.both)),
      ...bodyPart.left.map((path) => _PathEntry(path, MuscleSide.left)),
      ...bodyPart.right.map((path) => _PathEntry(path, MuscleSide.right)),
    ];
    final regions = <MuscleSemanticsRegion>[];
    for (final entry in entries) {
      final bounds = _pathBounds(entry.path, transform);
      if (bounds == null) continue;
      regions.add(MuscleSemanticsRegion(
        bounds: bounds,
        muscle: resolved,
        side: entry.side,
        selected: selected,
      ));
    }
    return regions;
  }

  Rect? _pathBounds(String pathString, _TransformData transform) {
    final bounds =
        _pathCache.parsePath(pathString, defensiveCopy: false).getBounds();
    if (bounds.isEmpty) return null;
    return Rect.fromLTRB(
      bounds.left * transform.scale + transform.offsetX,
      bounds.top * transform.scale + transform.offsetY,
      bounds.right * transform.scale + transform.offsetX,
      bounds.bottom * transform.scale + transform.offsetY,
    );
  }

  Rect? boundingRect(Muscle muscle, Size size) {
    final t = _computeTransform(size);
    final bodyParts = BodyPathProvider.paths(gender, side);
    Rect? combinedRect;

    for (final bodyPart in bodyParts) {
      if (bodyPart.slug.muscle != muscle) continue;
      for (final pathString in bodyPart.allPaths) {
        final path = _pathCache.parsePath(pathString, defensiveCopy: false);
        final rect = path.getBounds();
        if (rect.isEmpty) continue;
        // Transform rect to view coordinates
        final viewRect = Rect.fromLTRB(
          rect.left * t.scale + t.offsetX,
          rect.top * t.scale + t.offsetY,
          rect.right * t.scale + t.offsetX,
          rect.bottom * t.scale + t.offsetY,
        );
        combinedRect = combinedRect?.expandToInclude(viewRect) ?? viewRect;
      }
    }

    return combinedRect;
  }
}

class _TransformData {
  final double scale;
  final double offsetX;
  final double offsetY;
  _TransformData(
      {required this.scale, required this.offsetX, required this.offsetY});
}

class _PathEntry {
  final String path;
  final MuscleSide side;
  _PathEntry(this.path, this.side);
}

class MuscleMapPainter extends CustomPainter {
  final BodyRenderer renderer;

  MuscleMapPainter({required this.renderer});

  @override
  void paint(Canvas canvas, Size size) {
    renderer.render(canvas, size);
  }

  @override
  bool shouldRepaint(covariant MuscleMapPainter oldDelegate) => true;
}
