// MuscleMap Flutter - Core Data Models
import 'package:flutter/material.dart';

enum Muscle {
  abs,
  biceps,
  calves,
  chest,
  deltoids,
  feet,
  forearm,
  gluteal,
  hamstring,
  hands,
  head,
  knees,
  lowerBack,
  obliques,
  quadriceps,
  tibialis,
  trapezius,
  triceps,
  upperBack,
  rotatorCuff,
  serratus,
  rhomboids,
  // Sub-groups
  ankles,
  adductors,
  neck,
  hipFlexors,
  upperChest,
  lowerChest,
  innerQuad,
  outerQuad,
  upperAbs,
  lowerAbs,
  frontDeltoid,
  rearDeltoid,
  upperTrapezius,
  lowerTrapezius,
}

extension MuscleX on Muscle {
  String get rawValue {
    switch (this) {
      case Muscle.lowerBack: return 'lower-back';
      case Muscle.upperBack: return 'upper-back';
      case Muscle.rotatorCuff: return 'rotator-cuff';
      case Muscle.hipFlexors: return 'hip-flexors';
      case Muscle.upperChest: return 'upper-chest';
      case Muscle.lowerChest: return 'lower-chest';
      case Muscle.innerQuad: return 'inner-quad';
      case Muscle.outerQuad: return 'outer-quad';
      case Muscle.upperAbs: return 'upper-abs';
      case Muscle.lowerAbs: return 'lower-abs';
      case Muscle.frontDeltoid: return 'front-deltoid';
      case Muscle.rearDeltoid: return 'rear-deltoid';
      case Muscle.upperTrapezius: return 'upper-trapezius';
      case Muscle.lowerTrapezius: return 'lower-trapezius';
      default: return name;
    }
  }

  String get displayName {
    switch (this) {
      case Muscle.abs: return 'Abs';
      case Muscle.biceps: return 'Biceps';
      case Muscle.calves: return 'Calves';
      case Muscle.chest: return 'Chest';
      case Muscle.deltoids: return 'Deltoids';
      case Muscle.feet: return 'Feet';
      case Muscle.forearm: return 'Forearm';
      case Muscle.gluteal: return 'Gluteal';
      case Muscle.hamstring: return 'Hamstring';
      case Muscle.hands: return 'Hands';
      case Muscle.head: return 'Head';
      case Muscle.knees: return 'Knees';
      case Muscle.lowerBack: return 'Lower Back';
      case Muscle.obliques: return 'Obliques';
      case Muscle.quadriceps: return 'Quadriceps';
      case Muscle.tibialis: return 'Tibialis';
      case Muscle.trapezius: return 'Trapezius';
      case Muscle.triceps: return 'Triceps';
      case Muscle.upperBack: return 'Upper Back';
      case Muscle.rotatorCuff: return 'Rotator Cuff';
      case Muscle.serratus: return 'Serratus';
      case Muscle.rhomboids: return 'Rhomboids';
      case Muscle.ankles: return 'Ankles';
      case Muscle.adductors: return 'Adductors';
      case Muscle.neck: return 'Neck';
      case Muscle.hipFlexors: return 'Hip Flexors';
      case Muscle.upperChest: return 'Upper Chest';
      case Muscle.lowerChest: return 'Lower Chest';
      case Muscle.innerQuad: return 'Inner Quad';
      case Muscle.outerQuad: return 'Outer Quad';
      case Muscle.upperAbs: return 'Upper Abs';
      case Muscle.lowerAbs: return 'Lower Abs';
      case Muscle.frontDeltoid: return 'Front Deltoid';
      case Muscle.rearDeltoid: return 'Rear Deltoid';
      case Muscle.upperTrapezius: return 'Upper Trapezius';
      case Muscle.lowerTrapezius: return 'Lower Trapezius';
    }
  }

  bool get isCosmeticPart => this == Muscle.head;

  List<Muscle> get subGroups {
    switch (this) {
      case Muscle.chest: return [Muscle.upperChest, Muscle.lowerChest];
      case Muscle.quadriceps: return [Muscle.innerQuad, Muscle.outerQuad, Muscle.hipFlexors];
      case Muscle.abs: return [Muscle.upperAbs, Muscle.lowerAbs];
      case Muscle.deltoids: return [Muscle.frontDeltoid, Muscle.rearDeltoid];
      case Muscle.trapezius: return [Muscle.upperTrapezius, Muscle.lowerTrapezius];
      case Muscle.obliques: return [Muscle.serratus];
      case Muscle.feet: return [Muscle.ankles];
      case Muscle.hamstring: return [Muscle.adductors];
      case Muscle.head: return [Muscle.neck];
      default: return [];
    }
  }

  Muscle? get parentGroup {
    switch (this) {
      case Muscle.upperChest:
      case Muscle.lowerChest:
        return Muscle.chest;
      case Muscle.innerQuad:
      case Muscle.outerQuad:
      case Muscle.hipFlexors:
        return Muscle.quadriceps;
      case Muscle.upperAbs:
      case Muscle.lowerAbs:
        return Muscle.abs;
      case Muscle.frontDeltoid:
      case Muscle.rearDeltoid:
        return Muscle.deltoids;
      case Muscle.upperTrapezius:
      case Muscle.lowerTrapezius:
        return Muscle.trapezius;
      case Muscle.serratus:
        return Muscle.obliques;
      case Muscle.ankles:
        return Muscle.feet;
      case Muscle.adductors:
        return Muscle.hamstring;
      case Muscle.neck:
        return Muscle.head;
      default:
        return null;
    }
  }

  bool get isSubGroup => parentGroup != null;

  bool get isAlwaysVisibleSubGroup {
    switch (this) {
      case Muscle.ankles:
      case Muscle.adductors:
      case Muscle.neck:
        return true;
      default:
        return false;
    }
  }
}

enum BodySlug {
  abs,
  biceps,
  calves,
  chest,
  deltoids,
  feet,
  forearm,
  gluteal,
  hamstring,
  hands,
  hair,
  head,
  knees,
  lowerBack,
  obliques,
  quadriceps,
  tibialis,
  trapezius,
  triceps,
  upperBack,
  rotatorCuff,
  serratus,
  rhomboids,
  ankles,
  adductors,
  neck,
  hipFlexors,
  upperChest,
  lowerChest,
  innerQuad,
  outerQuad,
  upperAbs,
  lowerAbs,
  frontDeltoid,
  rearDeltoid,
  upperTrapezius,
  lowerTrapezius,
}

extension BodySlugX on BodySlug {
  Muscle? get muscle {
    if (this == BodySlug.hair) return null;
    switch (this) {
      case BodySlug.abs: return Muscle.abs;
      case BodySlug.biceps: return Muscle.biceps;
      case BodySlug.calves: return Muscle.calves;
      case BodySlug.chest: return Muscle.chest;
      case BodySlug.deltoids: return Muscle.deltoids;
      case BodySlug.feet: return Muscle.feet;
      case BodySlug.forearm: return Muscle.forearm;
      case BodySlug.gluteal: return Muscle.gluteal;
      case BodySlug.hamstring: return Muscle.hamstring;
      case BodySlug.hands: return Muscle.hands;
      case BodySlug.head: return Muscle.head;
      case BodySlug.knees: return Muscle.knees;
      case BodySlug.lowerBack: return Muscle.lowerBack;
      case BodySlug.obliques: return Muscle.obliques;
      case BodySlug.quadriceps: return Muscle.quadriceps;
      case BodySlug.tibialis: return Muscle.tibialis;
      case BodySlug.trapezius: return Muscle.trapezius;
      case BodySlug.triceps: return Muscle.triceps;
      case BodySlug.upperBack: return Muscle.upperBack;
      case BodySlug.rotatorCuff: return Muscle.rotatorCuff;
      case BodySlug.serratus: return Muscle.serratus;
      case BodySlug.rhomboids: return Muscle.rhomboids;
      case BodySlug.ankles: return Muscle.ankles;
      case BodySlug.adductors: return Muscle.adductors;
      case BodySlug.neck: return Muscle.neck;
      case BodySlug.hipFlexors: return Muscle.hipFlexors;
      case BodySlug.upperChest: return Muscle.upperChest;
      case BodySlug.lowerChest: return Muscle.lowerChest;
      case BodySlug.innerQuad: return Muscle.innerQuad;
      case BodySlug.outerQuad: return Muscle.outerQuad;
      case BodySlug.upperAbs: return Muscle.upperAbs;
      case BodySlug.lowerAbs: return Muscle.lowerAbs;
      case BodySlug.frontDeltoid: return Muscle.frontDeltoid;
      case BodySlug.rearDeltoid: return Muscle.rearDeltoid;
      case BodySlug.upperTrapezius: return Muscle.upperTrapezius;
      case BodySlug.lowerTrapezius: return Muscle.lowerTrapezius;
      default: return null;
    }
  }
}

enum BodyGender { male, female }

extension BodyGenderX on BodyGender {
  String get displayName {
    switch (this) {
      case BodyGender.male: return 'Male';
      case BodyGender.female: return 'Female';
    }
  }
}

enum BodySide { front, back }

extension BodySideX on BodySide {
  String get displayName {
    switch (this) {
      case BodySide.front: return 'Front';
      case BodySide.back: return 'Back';
    }
  }
}

enum MuscleSide { left, right, both }

extension MuscleSideX on MuscleSide {
  String get displayName {
    switch (this) {
      case MuscleSide.left: return 'Left';
      case MuscleSide.right: return 'Right';
      case MuscleSide.both: return 'Both';
    }
  }
}

class BodyPartPathData {
  final BodySlug slug;
  final List<String> common;
  final List<String> left;
  final List<String> right;

  const BodyPartPathData({
    required this.slug,
    this.common = const [],
    this.left = const [],
    this.right = const [],
  });

  List<String> get allPaths => [...common, ...left, ...right];
}

class BodyViewBox {
  final Offset origin;
  final Size size;

  const BodyViewBox({required this.origin, required this.size});

  Rect get rect => origin & size;

  static const maleFront = BodyViewBox(
    origin: Offset(0, 95),
    size: Size(727, 1280),
  );

  static const maleBack = BodyViewBox(
    origin: Offset(718, 95),
    size: Size(727, 1280),
  );

  static const femaleFront = BodyViewBox(
    origin: Offset(0, 0),
    size: Size(650, 1450),
  );

  static const femaleBack = BodyViewBox(
    origin: Offset(823, 0),
    size: Size(650, 1450),
  );
}

class MuscleHighlight {
  final Muscle muscle;
  final Color color;
  final double opacity;
  final MuscleFill? fill;

  const MuscleHighlight({
    required this.muscle,
    this.color = Colors.red,
    this.opacity = 1.0,
    this.fill,
  });
}

abstract class MuscleFill {
  const MuscleFill();
  Shader? toShader(Rect rect);
  Color get solidColor;
}

class SolidMuscleFill extends MuscleFill {
  final Color color;
  const SolidMuscleFill(this.color);

  @override
  Shader? toShader(Rect rect) => null;

  @override
  Color get solidColor => color;
}

class LinearGradientMuscleFill extends MuscleFill {
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  const LinearGradientMuscleFill({
    required this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Shader? toShader(Rect rect) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    ).createShader(rect);
  }

  @override
  Color get solidColor => colors.first;
}

class RadialGradientMuscleFill extends MuscleFill {
  final List<Color> colors;
  final Alignment center;
  final double radius;

  const RadialGradientMuscleFill({
    required this.colors,
    this.center = Alignment.center,
    this.radius = 0.5,
  });

  @override
  Shader? toShader(Rect rect) {
    final maxRadius = radius * rect.shortestSide;
    return RadialGradient(
      colors: colors,
      center: center,
      radius: radius,
    ).createShader(rect);
  }

  @override
  Color get solidColor => colors.first;
}

class MuscleIntensity {
  final Muscle muscle;
  final double intensity;

  const MuscleIntensity({required this.muscle, required this.intensity});

  MuscleIntensity.fromInt({required this.muscle, required int value})
      : intensity = (value / 4.0).clamp(0.0, 1.0);
}

enum HeatmapColorScale {
  workout,
  thermal,
  medical,
  neon,
}

extension HeatmapColorScaleX on HeatmapColorScale {
  List<Color> get colors {
    switch (this) {
      case HeatmapColorScale.workout:
        return [
          const Color(0xFFE8F5E9),
          const Color(0xFF81C784),
          const Color(0xFFFFB74D),
          const Color(0xFFE57373),
          const Color(0xFFB71C1C),
        ];
      case HeatmapColorScale.thermal:
        return [
          const Color(0xFF0D47A1),
          const Color(0xFF00BCD4),
          const Color(0xFF8BC34A),
          const Color(0xFFFF9800),
          const Color(0xFFF44336),
        ];
      case HeatmapColorScale.medical:
        return [
          const Color(0xFFE3F2FD),
          const Color(0xFF90CAF9),
          const Color(0xFF42A5F5),
          const Color(0xFF1E88E5),
          const Color(0xFF0D47A1),
        ];
      case HeatmapColorScale.neon:
        return [
          const Color(0xFF00FF00),
          const Color(0xFFFFFF00),
          const Color(0xFFFFA500),
          const Color(0xFFFF00FF),
          const Color(0xFF00FFFF),
        ];
    }
  }

  Color colorForIntensity(double intensity) {
    final vals = colors;
    if (intensity <= 0) return vals.first;
    if (intensity >= 1) return vals.last;
    final pos = intensity * (vals.length - 1);
    final idx = pos.floor();
    final t = pos - idx;
    if (idx >= vals.length - 1) return vals.last;
    return Color.lerp(vals[idx], vals[idx + 1], t) ?? vals[idx];
  }
}

enum InterpolationType { linear, easeIn, easeOut, easeInOut }

extension InterpolationTypeX on InterpolationType {
  double apply(double t) {
    switch (this) {
      case InterpolationType.linear: return t;
      case InterpolationType.easeIn: return t * t;
      case InterpolationType.easeOut: return 1 - (1 - t) * (1 - t);
      case InterpolationType.easeInOut:
        return t < 0.5 ? 2 * t * t : 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2;
    }
  }
}

class HeatmapConfiguration {
  final HeatmapColorScale colorScale;
  final InterpolationType interpolation;
  final double threshold;
  final bool isGradientFillEnabled;
  final GradientDirection gradientDirection;
  final double gradientLowIntensityFactor;

  const HeatmapConfiguration({
    this.colorScale = HeatmapColorScale.workout,
    this.interpolation = InterpolationType.linear,
    this.threshold = 0.0,
    this.isGradientFillEnabled = false,
    this.gradientDirection = GradientDirection.topToBottom,
    this.gradientLowIntensityFactor = 0.3,
  });

  static const defaults = HeatmapConfiguration();
}

enum GradientDirection {
  topToBottom,
  bottomToTop,
  leftToRight,
  rightToLeft,
}

class BodyViewStyle {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final Color selectionColor;
  final double selectionStrokeWidth;
  final Color selectionStrokeColor;
  final Color shadowColor;
  final double shadowRadius;
  final Offset shadowOffset;
  final Color hairColor;
  final Color headColor;
  final double unhighlightedOpacity;

  const BodyViewStyle({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.selectionColor,
    required this.selectionStrokeWidth,
    required this.selectionStrokeColor,
    required this.shadowColor,
    required this.shadowRadius,
    required this.shadowOffset,
    required this.hairColor,
    required this.headColor,
    required this.unhighlightedOpacity,
  });

  static const defaults = BodyViewStyle(
    fillColor: Color(0xFFD0D0D0),
    strokeColor: Color(0xFF808080),
    strokeWidth: 0.5,
    selectionColor: Color(0xFFFF6B6B),
    selectionStrokeWidth: 2.0,
    selectionStrokeColor: Color(0xFFFFFFFF),
    shadowColor: Color(0x40000000),
    shadowRadius: 4.0,
    shadowOffset: Offset(2, 2),
    hairColor: Color(0xFF5A3A1A),
    headColor: Color(0xFFFFE0BD),
    unhighlightedOpacity: 0.3,
  );

  static const minimal = BodyViewStyle(
    fillColor: Color(0xFFF0F0F0),
    strokeColor: Color(0xFFCCCCCC),
    strokeWidth: 0.3,
    selectionColor: Color(0xFF333333),
    selectionStrokeWidth: 1.5,
    selectionStrokeColor: Color(0xFF000000),
    shadowColor: Color(0x00000000),
    shadowRadius: 0.0,
    shadowOffset: Offset.zero,
    hairColor: Color(0xFF888888),
    headColor: Color(0xFFEEEEEE),
    unhighlightedOpacity: 0.5,
  );

  static const neon = BodyViewStyle(
    fillColor: Color(0xFF0A0A0A),
    strokeColor: Color(0xFF00FFCC),
    strokeWidth: 1.0,
    selectionColor: Color(0xFFFF00FF),
    selectionStrokeWidth: 2.5,
    selectionStrokeColor: Color(0xFF00FFFF),
    shadowColor: Color(0xCC00FFCC),
    shadowRadius: 8.0,
    shadowOffset: Offset(0, 0),
    hairColor: Color(0xFF1A1A1A),
    headColor: Color(0xFF111111),
    unhighlightedOpacity: 0.15,
  );

  static const medical = BodyViewStyle(
    fillColor: Color(0xFFE8F4F8),
    strokeColor: Color(0xFF90A4AE),
    strokeWidth: 0.8,
    selectionColor: Color(0xFFE53935),
    selectionStrokeWidth: 2.0,
    selectionStrokeColor: Color(0xFFFFFFFF),
    shadowColor: Color(0x20000000),
    shadowRadius: 3.0,
    shadowOffset: Offset(1, 1),
    hairColor: Color(0xFF546E7A),
    headColor: Color(0xFFFFF3E0),
    unhighlightedOpacity: 0.4,
  );
}

class SelectionHistory {
  final List<Set<Muscle>> _history = [];
  int _index = -1;

  void push(Set<Muscle> selection) {
    while (_history.length > _index + 1) {
      _history.removeLast();
    }
    _history.add(Set.of(selection));
    _index++;
  }

  Set<Muscle>? undo() {
    if (_index > 0) {
      _index--;
      return Set.of(_history[_index]);
    }
    return null;
  }

  Set<Muscle>? redo() {
    if (_index < _history.length - 1) {
      _index++;
      return Set.of(_history[_index]);
    }
    return null;
  }

  bool get canUndo => _index > 0;
  bool get canRedo => _index < _history.length - 1;
}
