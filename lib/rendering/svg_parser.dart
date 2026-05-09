import 'dart:math';
import 'package:flutter/material.dart';

/// SVG Path command types
enum _SVGCommandType {
  moveTo,
  lineTo,
  horizontalLineTo,
  verticalLineTo,
  curveTo,
  smoothCurveTo,
  quadraticCurveTo,
  smoothQuadraticCurveTo,
  arcTo,
  closePath,
}

class _SVGCommand {
  final _SVGCommandType type;
  final List<double> values;
  final bool relative;

  const _SVGCommand(this.type, this.values, {this.relative = false});
}

/// Robust SVG path parser that properly handles implicit commands
/// and tightly packed numbers (e.g., "100-50" means "100, -50")
class SVGPathParser {
  Path parse(String d) {
    final commands = _parseCommands(d);
    return _buildPath(commands);
  }

  List<_SVGCommand> _parseCommands(String pathString) {
    final commands = <_SVGCommand>[];
    var index = 0;
    var currentCommand = 'M';

    void skipWhitespaceAndCommas() {
      while (index < pathString.length) {
        final char = pathString[index];
        if (char == ' ' || char == ',' || char == '\n' || char == '\t') {
          index++;
        } else {
          break;
        }
      }
    }

    double? parseNumber() {
      skipWhitespaceAndCommas();
      if (index >= pathString.length) return null;

      var start = index;
      var hasDecimal = false;
      var hasExponent = false;

      // Handle sign
      if (pathString[index] == '-' || pathString[index] == '+') {
        index++;
      }

      while (index < pathString.length) {
        final char = pathString[index];

        if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
          // digit
          index++;
        } else if (char == '.' && !hasDecimal && !hasExponent) {
          hasDecimal = true;
          index++;
        } else if ((char == 'e' || char == 'E') && !hasExponent) {
          hasExponent = true;
          index++;
          // Handle exponent sign
          if (index < pathString.length &&
              (pathString[index] == '-' || pathString[index] == '+')) {
            index++;
          }
        } else {
          break;
        }
      }

      if (start == index) return null;
      final numStr = pathString.substring(start, index);
      return double.tryParse(numStr);
    }

    bool? parseFlag() {
      skipWhitespaceAndCommas();
      if (index >= pathString.length) return null;
      final char = pathString[index];
      if (char == '0' || char == '1') {
        index++;
        return char == '1';
      }
      return null;
    }

    while (index < pathString.length) {
      skipWhitespaceAndCommas();
      if (index >= pathString.length) break;

      final char = pathString[index];

      // Check if this is a command letter (not 'e'/'E' which are part of scientific notation)
      if (_isCommandLetter(char, index, pathString)) {
        currentCommand = char;
        index++;
      }

      final isRelative = currentCommand == currentCommand.toLowerCase();
      final cmd = currentCommand.toUpperCase();

      switch (cmd) {
        case 'M':
          final x = parseNumber();
          final y = parseNumber();
          if (x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.moveTo, [x, y],
                relative: isRelative));
            // After M, subsequent coordinate pairs are implicit lineTo
            currentCommand = isRelative ? 'l' : 'L';
          }
          break;

        case 'L':
          final x = parseNumber();
          final y = parseNumber();
          if (x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.lineTo, [x, y],
                relative: isRelative));
          }
          break;

        case 'H':
          final x = parseNumber();
          if (x != null) {
            commands.add(_SVGCommand(_SVGCommandType.horizontalLineTo, [x],
                relative: isRelative));
          }
          break;

        case 'V':
          final y = parseNumber();
          if (y != null) {
            commands.add(_SVGCommand(_SVGCommandType.verticalLineTo, [y],
                relative: isRelative));
          }
          break;

        case 'C':
          final x1 = parseNumber(), y1 = parseNumber();
          final x2 = parseNumber(), y2 = parseNumber();
          final x = parseNumber(), y = parseNumber();
          if (x1 != null && y1 != null && x2 != null && y2 != null && x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.curveTo,
                [x1, y1, x2, y2, x, y],
                relative: isRelative));
          }
          break;

        case 'S':
          final x2 = parseNumber(), y2 = parseNumber();
          final x = parseNumber(), y = parseNumber();
          if (x2 != null && y2 != null && x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.smoothCurveTo,
                [x2, y2, x, y],
                relative: isRelative));
          }
          break;

        case 'Q':
          final x1 = parseNumber(), y1 = parseNumber();
          final x = parseNumber(), y = parseNumber();
          if (x1 != null && y1 != null && x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.quadraticCurveTo,
                [x1, y1, x, y],
                relative: isRelative));
          }
          break;

        case 'T':
          final x = parseNumber();
          final y = parseNumber();
          if (x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.smoothQuadraticCurveTo,
                [x, y],
                relative: isRelative));
          }
          break;

        case 'A':
          final rx = parseNumber(), ry = parseNumber();
          final angle = parseNumber();
          final largeArc = parseFlag();
          final sweep = parseFlag();
          final x = parseNumber(), y = parseNumber();
          if (rx != null && ry != null && angle != null &&
              largeArc != null && sweep != null && x != null && y != null) {
            commands.add(_SVGCommand(_SVGCommandType.arcTo,
                [rx, ry, angle, largeArc ? 1.0 : 0.0, sweep ? 1.0 : 0.0, x, y],
                relative: isRelative));
          }
          break;

        case 'Z':
          commands.add(const _SVGCommand(_SVGCommandType.closePath, []));
          break;

        default:
          index++;
          break;
      }
    }

    return commands;
  }

  bool _isCommandLetter(String char, int pos, String str) {
    if (char.length != 1) return false;
    final code = char.codeUnitAt(0);
    // Check if it's a letter but not 'e'/'E' (used in scientific notation)
    if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
      if (char == 'e' || char == 'E') {
        // 'e'/'E' is a command letter only if it's not part of a number
        // Check if previous character could be part of a number
        if (pos > 0) {
          final prev = str[pos - 1];
          final prevCode = prev.codeUnitAt(0);
          if ((prevCode >= 48 && prevCode <= 57) || prev == '.') {
            return false; // Part of scientific notation
          }
        }
      }
      return true;
    }
    return false;
  }

  Path _buildPath(List<_SVGCommand> commands) {
    final path = Path();
    double lastX = 0, lastY = 0;
    double? lastCpx1, lastCpy1; // Last control point for cubic bezier
    double? lastQpx1, lastQpy1; // Last control point for quadratic bezier
    double? subpathStartX, subpathStartY;

    for (final cmd in commands) {
      switch (cmd.type) {
        case _SVGCommandType.moveTo:
          final x = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          final y = cmd.relative ? lastY + cmd.values[1] : cmd.values[1];
          path.moveTo(x, y);
          lastX = x;
          lastY = y;
          subpathStartX = x;
          subpathStartY = y;
          lastCpx1 = null;
          lastCpy1 = null;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.lineTo:
          final x = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          final y = cmd.relative ? lastY + cmd.values[1] : cmd.values[1];
          path.lineTo(x, y);
          lastX = x;
          lastY = y;
          lastCpx1 = null;
          lastCpy1 = null;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.horizontalLineTo:
          final x = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          path.lineTo(x, lastY);
          lastX = x;
          lastCpx1 = null;
          lastCpy1 = null;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.verticalLineTo:
          final y = cmd.relative ? lastY + cmd.values[0] : cmd.values[0];
          path.lineTo(lastX, y);
          lastY = y;
          lastCpx1 = null;
          lastCpy1 = null;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.curveTo:
          final x1 = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          final y1 = cmd.relative ? lastY + cmd.values[1] : cmd.values[1];
          final x2 = cmd.relative ? lastX + cmd.values[2] : cmd.values[2];
          final y2 = cmd.relative ? lastY + cmd.values[3] : cmd.values[3];
          final x = cmd.relative ? lastX + cmd.values[4] : cmd.values[4];
          final y = cmd.relative ? lastY + cmd.values[5] : cmd.values[5];
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCpx1 = x2;
          lastCpy1 = y2;
          lastX = x;
          lastY = y;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.smoothCurveTo:
          final x1 = lastCpx1 != null ? 2 * lastX - lastCpx1! : lastX;
          final y1 = lastCpy1 != null ? 2 * lastY - lastCpy1! : lastY;
          final x2 = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          final y2 = cmd.relative ? lastY + cmd.values[1] : cmd.values[1];
          final x = cmd.relative ? lastX + cmd.values[2] : cmd.values[2];
          final y = cmd.relative ? lastY + cmd.values[3] : cmd.values[3];
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCpx1 = x2;
          lastCpy1 = y2;
          lastX = x;
          lastY = y;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.quadraticCurveTo:
          final x1 = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          final y1 = cmd.relative ? lastY + cmd.values[1] : cmd.values[1];
          final x = cmd.relative ? lastX + cmd.values[2] : cmd.values[2];
          final y = cmd.relative ? lastY + cmd.values[3] : cmd.values[3];
          path.quadraticBezierTo(x1, y1, x, y);
          lastQpx1 = x1;
          lastQpy1 = y1;
          lastX = x;
          lastY = y;
          lastCpx1 = null;
          lastCpy1 = null;
          break;

        case _SVGCommandType.smoothQuadraticCurveTo:
          final x1 = lastQpx1 != null ? 2 * lastX - lastQpx1! : lastX;
          final y1 = lastQpy1 != null ? 2 * lastY - lastQpy1! : lastY;
          final x = cmd.relative ? lastX + cmd.values[0] : cmd.values[0];
          final y = cmd.relative ? lastY + cmd.values[1] : cmd.values[1];
          path.quadraticBezierTo(x1, y1, x, y);
          lastQpx1 = x1;
          lastQpy1 = y1;
          lastX = x;
          lastY = y;
          lastCpx1 = null;
          lastCpy1 = null;
          break;

        case _SVGCommandType.arcTo:
          // Approximate arc with cubic bezier
          final rx = cmd.values[0];
          final ry = cmd.values[1];
          final phi = cmd.values[2] * 3.141592653589793 / 180.0;
          final largeArc = cmd.values[3] > 0.5;
          final sweep = cmd.values[4] > 0.5;
          final x2 = cmd.relative ? lastX + cmd.values[5] : cmd.values[5];
          final y2 = cmd.relative ? lastY + cmd.values[6] : cmd.values[6];

          _arcToBezier(path, lastX, lastY, rx, ry, phi, largeArc, sweep, x2, y2);

          lastX = x2;
          lastY = y2;
          lastCpx1 = null;
          lastCpy1 = null;
          lastQpx1 = null;
          lastQpy1 = null;
          break;

        case _SVGCommandType.closePath:
          path.close();
          if (subpathStartX != null && subpathStartY != null) {
            lastX = subpathStartX;
            lastY = subpathStartY;
          }
          lastCpx1 = null;
          lastCpy1 = null;
          lastQpx1 = null;
          lastQpy1 = null;
          break;
      }
    }

    return path;
  }

  /// Convert SVG arc to cubic bezier curves
  void _arcToBezier(Path path, double x1, double y1, double rx, double ry,
      double phi, bool largeArc, bool sweep, double x2, double y2) {
    if (x1 == x2 && y1 == y2) return;
    if (rx == 0 || ry == 0) {
      path.lineTo(x2, y2);
      return;
    }

    rx = rx.abs();
    ry = ry.abs();

    final cosPhi = cos(phi);
    final sinPhi = sin(phi);

    final dx2 = (x1 - x2) / 2.0;
    final dy2 = (y1 - y2) / 2.0;

    final x1p = cosPhi * dx2 + sinPhi * dy2;
    final y1p = -sinPhi * dx2 + cosPhi * dy2;

    var lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
    if (lambda > 1) {
      final sqrtLambda = sqrt(lambda);
      rx *= sqrtLambda;
      ry *= sqrtLambda;
      lambda = 1;
    }

    final factor = sqrt((1.0 / lambda - 1.0).clamp(0.0, double.infinity));
    var cxp = factor * rx * y1p / ry;
    var cyp = -factor * ry * x1p / rx;

    if (largeArc == sweep) {
      cxp = -cxp;
      cyp = -cyp;
    }

    final cx = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2.0;
    final cy = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2.0;

    final theta1 = _atan2(y1p - cyp, x1p - cxp);
    var deltaTheta = _atan2(-y1p - cyp, -x1p - cxp) - theta1;

    if (!sweep && deltaTheta > 0) {
      deltaTheta -= 2 * 3.141592653589793;
    } else if (sweep && deltaTheta < 0) {
      deltaTheta += 2 * 3.141592653589793;
    }

    // Split arc into segments if needed (max 90 degrees per segment)
    final numSegments = (deltaTheta.abs() / (3.141592653589793 / 2.0)).ceil().clamp(1, 4);
    final etaStep = deltaTheta / numSegments;

    final cosEta = cos(etaStep);
    final sinEta = sin(etaStep);
    var cosTheta = cos(theta1);
    var sinTheta = sin(theta1);

    for (int i = 0; i < numSegments; i++) {
      final nextCosTheta = cosTheta * cosEta - sinTheta * sinEta;
      final nextSinTheta = sinTheta * cosEta + cosTheta * sinEta;

      final epx = cx + rx * cosTheta;
      final epy = cy + ry * sinTheta;
      final eqx = cx + rx * nextCosTheta;
      final eqy = cy + ry * nextSinTheta;

      final alpha = sin(etaStep) * (sqrt(4.0 + 3.0 * tan(etaStep / 2.0) * tan(etaStep / 2.0)) - 1.0) / 3.0;

      final c1x = epx - alpha * rx * sinTheta;
      final c1y = epy + alpha * ry * cosTheta;
      final c2x = eqx + alpha * rx * nextSinTheta;
      final c2y = eqy - alpha * ry * nextCosTheta;

      path.cubicTo(c1x, c1y, c2x, c2y, eqx, eqy);

      cosTheta = nextCosTheta;
      sinTheta = nextSinTheta;
    }
  }

  double _atan2(double y, double x) {
    return atan2(y, x);
  }
}
