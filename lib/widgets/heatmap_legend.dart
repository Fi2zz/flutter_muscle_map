import 'package:flutter/material.dart';
import '../data/models.dart';

class HeatmapLegend extends StatelessWidget {
  final HeatmapColorScale colorScale;
  final InterpolationType interpolation;
  final bool vertical;
  final double barThickness;
  final double barLength;
  final String? labelMin;
  final String? labelMax;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;

  const HeatmapLegend({
    super.key,
    this.colorScale = HeatmapColorScale.workout,
    this.interpolation = InterpolationType.linear,
    this.vertical = false,
    this.barThickness = 20,
    this.barLength = 200,
    this.labelMin,
    this.labelMax,
    this.textStyle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = colorScale.colors;
    final defaultStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    final style = textStyle ?? defaultStyle;

    Widget bar;
    if (vertical) {
      bar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelMax != null)
            Text(labelMax!, style: style),
          Container(
            width: barThickness,
            height: barLength,
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors.reversed.toList(),
              ),
            ),
          ),
          if (labelMin != null)
            Text(labelMin!, style: style),
        ],
      );
    } else {
      bar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: barLength,
            height: barThickness,
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: colors,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: barLength,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (labelMin != null)
                  Text(labelMin!, style: style)
                else
                  const SizedBox.shrink(),
                if (labelMax != null)
                  Text(labelMax!, style: style)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      );
    }

    return bar;
  }
}
