import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/path_provider.dart';
import 'svg_parser.dart';

class PathCache {
  final Map<String, Path> _cache = {};
  final SVGPathParser _parser = SVGPathParser();

  /// Parse path from SVG string. Paths are in original SVG coordinates.
  Path parsePath(String d) {
    if (_cache.containsKey(d)) return _cache[d]!;
    final path = _parser.parse(d);
    _cache[d] = path;
    return path;
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

    final offsetX = (size.width - viewBox.size.width * scale) / 2 - viewBox.origin.dx * scale;
    final offsetY = (size.height - viewBox.size.height * scale) / 2 - viewBox.origin.dy * scale;

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

      final isSelected = () {
        if (muscle == null) return false;
        if (selectedMuscles.contains(muscle)) return true;
        if (hideSubGroups && muscle.isAlwaysVisibleSubGroup && muscle.parentGroup != null) {
          return selectedMuscles.contains(muscle.parentGroup!);
        }
        return false;
      }();

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
        final path = _pathCache.parsePath(entry.path);

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

        if (needsShadow || needsOpacityLayer || (isSelected && selectionPulseFactor != 1.0)) {
          canvas.saveLayer(bounds, Paint());

          if (needsShadow) {
            final shadowPaint = Paint()
              ..style = PaintingStyle.fill
              ..color = style.shadowColor
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                style.shadowRadius / t.scale, // Scale shadow radius back to SVG space
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
            ..strokeWidth = style.strokeWidth / t.scale; // Scale stroke to SVG space
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

  MuscleFill _resolveFill(BodySlug slug, MuscleHighlight? highlight, bool isSelected) {
    if (slug == BodySlug.hair) return SolidMuscleFill(style.hairColor);
    if (slug == BodySlug.head) return SolidMuscleFill(style.headColor);
    if (isSelected) return SolidMuscleFill(style.selectionColor);
    if (highlight != null) return highlight.fill ?? SolidMuscleFill(highlight.color);

    // Sub-group inheritance
    final muscle = slug.muscle;
    if (muscle != null && muscle.isSubGroup && muscle.parentGroup != null) {
      final parentHighlight = highlights[muscle.parentGroup!];
      if (parentHighlight != null) {
        return parentHighlight.fill ?? SolidMuscleFill(parentHighlight.color);
      }
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

    // Test sub-groups first for priority
    final sortedParts = List<BodyPartPathData>.from(bodyParts)
      ..sort((a, b) {
        final aIsSub = a.slug.muscle?.isSubGroup ?? false;
        final bIsSub = b.slug.muscle?.isSubGroup ?? false;
        if (aIsSub != bIsSub) return aIsSub ? -1 : 1;
        return 0;
      });

    for (final bodyPart in sortedParts) {
      final muscle = bodyPart.slug.muscle;
      if (muscle == null) continue;

      if (hideSubGroups && muscle.isSubGroup && !muscle.isAlwaysVisibleSubGroup) continue;

      final resolvedMuscle = () {
        if (hideSubGroups && muscle.isAlwaysVisibleSubGroup && muscle.parentGroup != null) {
          return muscle.parentGroup!;
        }
        return muscle;
      }();

      for (final pathString in bodyPart.left) {
        final path = _pathCache.parsePath(pathString);
        if (path.contains(svgPoint)) return (resolvedMuscle, MuscleSide.left);
      }

      for (final pathString in bodyPart.right) {
        final path = _pathCache.parsePath(pathString);
        if (path.contains(svgPoint)) return (resolvedMuscle, MuscleSide.right);
      }

      for (final pathString in bodyPart.common) {
        final path = _pathCache.parsePath(pathString);
        if (path.contains(svgPoint)) return (resolvedMuscle, MuscleSide.both);
      }
    }

    return null;
  }

  Rect? boundingRect(Muscle muscle, Size size) {
    final t = _computeTransform(size);
    final bodyParts = BodyPathProvider.paths(gender, side);
    Rect? combinedRect;

    for (final bodyPart in bodyParts) {
      if (bodyPart.slug.muscle != muscle) continue;
      for (final pathString in bodyPart.allPaths) {
        final path = _pathCache.parsePath(pathString);
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
  _TransformData({required this.scale, required this.offsetX, required this.offsetY});
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
