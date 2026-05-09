import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../rendering/body_renderer.dart';

class MuscleMapView extends StatefulWidget {
  final BodyGender gender;
  final BodySide side;
  final BodyViewStyle style;
  final Map<Muscle, MuscleHighlight> highlights;
  final Set<Muscle> selectedMuscles;
  final bool isAnimated;
  final Duration animationDuration;
  final bool isPulseEnabled;
  final double pulseSpeed;
  final double pulseMin;
  final double pulseMax;
  final bool isZoomEnabled;
  final double minZoomScale;
  final double maxZoomScale;
  final bool hideSubGroups;
  final HeatmapConfiguration? heatmapConfig;
  final Map<Muscle, double>? heatmapData;
  final SelectionHistory? selectionHistory;
  final Widget Function(Muscle, MuscleSide)? tooltipBuilder;

  final void Function(Muscle muscle, MuscleSide side)? onMuscleSelected;
  final void Function(Muscle muscle, MuscleSide side)? onMuscleLongPressed;
  final void Function(Muscle muscle, MuscleSide side)? onMuscleDragged;
  final VoidCallback? onMuscleDragEnded;
  final Duration longPressDuration;

  const MuscleMapView({
    super.key,
    this.gender = BodyGender.male,
    this.side = BodySide.front,
    this.style = BodyViewStyle.defaults,
    this.highlights = const {},
    this.selectedMuscles = const {},
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isPulseEnabled = false,
    this.pulseSpeed = 1.5,
    this.pulseMin = 0.6,
    this.pulseMax = 1.0,
    this.isZoomEnabled = false,
    this.minZoomScale = 1.0,
    this.maxZoomScale = 4.0,
    this.hideSubGroups = true,
    this.heatmapConfig,
    this.heatmapData,
    this.selectionHistory,
    this.tooltipBuilder,
    this.onMuscleSelected,
    this.onMuscleLongPressed,
    this.onMuscleDragged,
    this.onMuscleDragEnded,
    this.longPressDuration = const Duration(milliseconds: 500),
  });

  MuscleMapView copyWith({
    BodyGender? gender,
    BodySide? side,
    BodyViewStyle? style,
    Map<Muscle, MuscleHighlight>? highlights,
    Set<Muscle>? selectedMuscles,
    bool? isAnimated,
    Duration? animationDuration,
    bool? isPulseEnabled,
    double? pulseSpeed,
    double? pulseMin,
    double? pulseMax,
    bool? isZoomEnabled,
    double? minZoomScale,
    double? maxZoomScale,
    bool? hideSubGroups,
    HeatmapConfiguration? heatmapConfig,
    Map<Muscle, double>? heatmapData,
    SelectionHistory? selectionHistory,
    Widget Function(Muscle, MuscleSide)? tooltipBuilder,
    void Function(Muscle, MuscleSide)? onMuscleSelected,
    void Function(Muscle, MuscleSide)? onMuscleLongPressed,
    void Function(Muscle, MuscleSide)? onMuscleDragged,
    VoidCallback? onMuscleDragEnded,
    Duration? longPressDuration,
  }) {
    return MuscleMapView(
      gender: gender ?? this.gender,
      side: side ?? this.side,
      style: style ?? this.style,
      highlights: highlights ?? Map.unmodifiable(Map.of(this.highlights)),
      selectedMuscles: selectedMuscles ?? this.selectedMuscles,
      isAnimated: isAnimated ?? this.isAnimated,
      animationDuration: animationDuration ?? this.animationDuration,
      isPulseEnabled: isPulseEnabled ?? this.isPulseEnabled,
      pulseSpeed: pulseSpeed ?? this.pulseSpeed,
      pulseMin: pulseMin ?? this.pulseMin,
      pulseMax: pulseMax ?? this.pulseMax,
      isZoomEnabled: isZoomEnabled ?? this.isZoomEnabled,
      minZoomScale: minZoomScale ?? this.minZoomScale,
      maxZoomScale: maxZoomScale ?? this.maxZoomScale,
      hideSubGroups: hideSubGroups ?? this.hideSubGroups,
      heatmapConfig: heatmapConfig ?? this.heatmapConfig,
      heatmapData: heatmapData ?? this.heatmapData,
      selectionHistory: selectionHistory ?? this.selectionHistory,
      tooltipBuilder: tooltipBuilder ?? this.tooltipBuilder,
      onMuscleSelected: onMuscleSelected ?? this.onMuscleSelected,
      onMuscleLongPressed: onMuscleLongPressed ?? this.onMuscleLongPressed,
      onMuscleDragged: onMuscleDragged ?? this.onMuscleDragged,
      onMuscleDragEnded: onMuscleDragEnded ?? this.onMuscleDragEnded,
      longPressDuration: longPressDuration ?? this.longPressDuration,
    );
  }

  @override
  State<MuscleMapView> createState() => _MuscleMapViewState();
}

class _MuscleMapViewState extends State<MuscleMapView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _longPressTimer;
  bool _isLongPress = false;
  Offset? _lastTapPosition;
  MuscleSide? _lastSide;
  Muscle? _lastMuscle;

  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  Offset _startOffset = Offset.zero;
  double _startScale = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: (1000 / widget.pulseSpeed).round()),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: widget.pulseMin,
      end: widget.pulseMax,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant MuscleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseSpeed != widget.pulseSpeed) {
      _pulseController.duration =
          Duration(milliseconds: (1000 / widget.pulseSpeed).round());
    }
    if (widget.isPulseEnabled && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPulseEnabled && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  Map<Muscle, MuscleHighlight> get _effectiveHighlights {
    if (widget.heatmapData == null || widget.heatmapData!.isEmpty) {
      return widget.highlights;
    }

    final config = widget.heatmapConfig ?? const HeatmapConfiguration();
    final result = Map<Muscle, MuscleHighlight>.of(widget.highlights);

    for (final entry in widget.heatmapData!.entries) {
      final intensity = config.interpolation.apply(
        entry.value.clamp(0.0, 1.0),
      );

      if (intensity < config.threshold) continue;

      final color = config.colorScale.colorForIntensity(intensity);
      result[entry.key] = MuscleHighlight(
        muscle: entry.key,
        color: color,
        opacity: 0.85,
      );
    }

    return result;
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    _isLongPress = false;
    final renderer = _createRenderer(pulseFactor: 1.0);
    final result = renderer.hitTest(details.localPosition, size);

    if (result != null) {
      _lastMuscle = result.$1;
      _lastSide = result.$2;
      _lastTapPosition = details.localPosition;

      if (widget.onMuscleLongPressed != null) {
        _longPressTimer?.cancel();
        _longPressTimer = Timer(widget.longPressDuration, () {
          _isLongPress = true;
          widget.onMuscleLongPressed!(_lastMuscle!, _lastSide!);
        });
      }
    }
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    _longPressTimer?.cancel();
    if (!_isLongPress && _lastMuscle != null && _lastSide != null) {
      widget.onMuscleSelected?.call(_lastMuscle!, _lastSide!);
    }
    _lastMuscle = null;
    _lastSide = null;
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    final renderer = _createRenderer(pulseFactor: 1.0);
    final result = renderer.hitTest(details.localPosition, size);
    if (result != null) {
      _lastMuscle = result.$1;
      _lastSide = result.$2;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (widget.onMuscleDragged != null) {
      final renderer = _createRenderer(pulseFactor: 1.0);
      final result = renderer.hitTest(details.localPosition, size);
      if (result != null) {
        _lastMuscle = result.$1;
        _lastSide = result.$2;
        widget.onMuscleDragged!(result.$1, result.$2);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    widget.onMuscleDragEnded?.call();
  }

  BodyRenderer _createRenderer({required double pulseFactor}) {
    return BodyRenderer(
      gender: widget.gender,
      side: widget.side,
      highlights: _effectiveHighlights,
      style: widget.style,
      selectedMuscles: widget.selectedMuscles,
      selectionPulseFactor: widget.isPulseEnabled ? pulseFactor : 1.0,
      hideSubGroups: widget.hideSubGroups,
      heatmapConfig: widget.heatmapConfig,
    );
  }

  Widget _buildBody(Size size, double pulseFactor) {
    final renderer = _createRenderer(pulseFactor: pulseFactor);
    return CustomPaint(
      size: size,
      painter: MuscleMapPainter(renderer: renderer),
    );
  }

  Widget _buildInteractiveBody(Size size) {
    Widget body = GestureDetector(
      onTapDown: (d) => _handleTapDown(d, size),
      onTapUp: (d) => _handleTapUp(d, size),
      onTapCancel: () => _longPressTimer?.cancel(),
      onPanStart: widget.onMuscleDragged != null ? (d) => _handlePanStart(d, size) : null,
      onPanUpdate: widget.onMuscleDragged != null ? (d) => _handlePanUpdate(d, size) : null,
      onPanEnd: widget.onMuscleDragged != null ? _handlePanEnd : null,
      child: widget.isPulseEnabled
          ? AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return _buildBody(size, _pulseAnimation.value);
              },
            )
          : _buildBody(size, 1.0),
    );

    if (widget.isZoomEnabled) {
      body = GestureDetector(
        onScaleStart: (details) {
          _startFocalPoint = details.focalPoint;
          _startOffset = _offset;
          _startScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_startScale * details.scale).clamp(
              widget.minZoomScale,
              widget.maxZoomScale,
            );
            final delta = details.focalPoint - _startFocalPoint;
            _offset = _startOffset + delta;
          });
        },
        child: Transform.scale(
          scale: _scale,
          child: Transform.translate(
            offset: _offset,
            child: body,
          ),
        ),
      );
    }

    // Tooltip overlay
    if (widget.tooltipBuilder != null && widget.selectedMuscles.isNotEmpty) {
      body = Stack(
        children: [
          body,
          ...widget.selectedMuscles.map((muscle) {
            final renderer = _createRenderer(pulseFactor: 1.0);
            final rect = renderer.boundingRect(muscle, size);
            if (rect == null) return const SizedBox.shrink();
            return Positioned(
              left: rect.center.dx - 40,
              top: rect.top - 30,
              child: widget.tooltipBuilder!(muscle, MuscleSide.both),
            );
          }),
        ],
      );
    }

    return body;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (widget.isAnimated) {
          return AnimatedSwitcher(
            duration: widget.animationDuration,
            child: _buildInteractiveBody(size),
          );
        }
        return _buildInteractiveBody(size);
      },
    );
  }
}
