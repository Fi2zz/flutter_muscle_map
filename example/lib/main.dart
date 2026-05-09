import 'package:flutter/material.dart';
import 'package:muscle_map/muscle_map.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleMap Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _items = [
    _NavItem('Highlight', Icons.fitness_center, 0),
    _NavItem('Heatmap', Icons.local_fire_department, 1),
    _NavItem('Interactive', Icons.touch_app, 2),
    _NavItem('Styles', Icons.brush, 3),
    _NavItem('Gradient', Icons.gradient, 4),
    _NavItem('Animation', Icons.animation, 5),
    _NavItem('Gestures', Icons.pan_tool, 6),
    _NavItem('Heatmap V2', Icons.bar_chart, 7),
    _NavItem('Sub-Groups', Icons.grid_view, 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HighlightDemo(),
          HeatmapDemo(),
          InteractiveDemo(),
          StyleDemo(),
          GradientDemo(),
          AnimationDemo(),
          GestureDemo(),
          HeatmapV2Demo(),
          SubGroupsDemo(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _items
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final int index;
  _NavItem(this.label, this.icon, this.index);
}

// ============== Highlight Demo ==============
class HighlightDemo extends StatelessWidget {
  const HighlightDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Highlight Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Male - Front & Back'),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 350,
                    child: MuscleMapView(
                      gender: BodyGender.male,
                      side: BodySide.front,
                      highlights: {
                        Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.red),
                        Muscle.biceps: const MuscleHighlight(muscle: Muscle.biceps, color: Colors.orange, opacity: 0.8),
                        Muscle.abs: const MuscleHighlight(muscle: Muscle.abs, color: Colors.yellow, opacity: 0.6),
                        Muscle.quadriceps: const MuscleHighlight(muscle: Muscle.quadriceps, color: Colors.red),
                        Muscle.deltoids: const MuscleHighlight(muscle: Muscle.deltoids, color: Colors.orange),
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 350,
                    child: MuscleMapView(
                      gender: BodyGender.male,
                      side: BodySide.back,
                      highlights: {
                        Muscle.trapezius: const MuscleHighlight(muscle: Muscle.trapezius, color: Colors.orange),
                        Muscle.upperBack: const MuscleHighlight(muscle: Muscle.upperBack, color: Colors.red),
                        Muscle.lowerBack: const MuscleHighlight(muscle: Muscle.lowerBack, color: Colors.yellow),
                        Muscle.hamstring: const MuscleHighlight(muscle: Muscle.hamstring, color: Colors.red),
                        Muscle.gluteal: const MuscleHighlight(muscle: Muscle.gluteal, color: Colors.orange),
                      },
                    ),
                  ),
                ),
              ],
            ),
            _sectionTitle('Female - Front & Back'),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 350,
                    child: MuscleMapView(
                      gender: BodyGender.female,
                      side: BodySide.front,
                      highlights: {
                        Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.pink),
                        Muscle.abs: const MuscleHighlight(muscle: Muscle.abs, color: Colors.orange),
                        Muscle.quadriceps: const MuscleHighlight(muscle: Muscle.quadriceps, color: Colors.red),
                        Muscle.calves: const MuscleHighlight(muscle: Muscle.calves, color: Colors.yellow),
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 350,
                    child: MuscleMapView(
                      gender: BodyGender.female,
                      side: BodySide.back,
                      highlights: {
                        Muscle.gluteal: const MuscleHighlight(muscle: Muscle.gluteal, color: Colors.pink),
                        Muscle.hamstring: const MuscleHighlight(muscle: Muscle.hamstring, color: Colors.red),
                        Muscle.upperBack: const MuscleHighlight(muscle: Muscle.upperBack, color: Colors.orange),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============== Heatmap Demo ==============
class HeatmapDemo extends StatelessWidget {
  const HeatmapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Workout Intensity (0-4)'),
            SizedBox(
              height: 400,
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.front,
                heatmapData: {
                  Muscle.chest: 1.0,
                  Muscle.biceps: 0.75,
                  Muscle.abs: 0.5,
                  Muscle.quadriceps: 1.0,
                  Muscle.deltoids: 0.75,
                  Muscle.forearm: 0.25,
                  Muscle.obliques: 0.5,
                  Muscle.triceps: 0.5,
                },
                heatmapConfig: const HeatmapConfiguration(
                  colorScale: HeatmapColorScale.workout,
                ),
              ),
            ),
            _sectionTitle('Thermal Scale'),
            SizedBox(
              height: 400,
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.back,
                heatmapData: {
                  Muscle.trapezius: 0.75,
                  Muscle.upperBack: 1.0,
                  Muscle.lowerBack: 0.5,
                  Muscle.hamstring: 0.75,
                  Muscle.gluteal: 1.0,
                  Muscle.calves: 0.25,
                  Muscle.triceps: 0.5,
                },
                heatmapConfig: const HeatmapConfiguration(
                  colorScale: HeatmapColorScale.thermal,
                ),
              ),
            ),
            _sectionTitle('Medical Scale'),
            SizedBox(
              height: 400,
              child: MuscleMapView(
                gender: BodyGender.female,
                side: BodySide.front,
                heatmapData: {
                  Muscle.chest: 0.9,
                  Muscle.deltoids: 0.7,
                  Muscle.biceps: 0.5,
                  Muscle.abs: 0.3,
                  Muscle.quadriceps: 0.6,
                },
                heatmapConfig: const HeatmapConfiguration(
                  colorScale: HeatmapColorScale.medical,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== Interactive Demo ==============
class InteractiveDemo extends StatefulWidget {
  const InteractiveDemo({super.key});

  @override
  State<InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<InteractiveDemo> {
  Muscle? _selectedMuscle;
  MuscleSide _selectedSide = MuscleSide.both;
  BodyGender _gender = BodyGender.male;
  BodySide _bodySide = BodySide.front;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<BodyGender>(
                    segments: const [
                      ButtonSegment(value: BodyGender.male, label: Text('Male')),
                      ButtonSegment(value: BodyGender.female, label: Text('Female')),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) setState(() => _gender = set.first);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<BodySide>(
                    segments: const [
                      ButtonSegment(value: BodySide.front, label: Text('Front')),
                      ButtonSegment(value: BodySide.back, label: Text('Back')),
                    ],
                    selected: {_bodySide},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) setState(() => _bodySide = set.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMuscle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_selectedMuscle!.displayName} (${_selectedSide.displayName})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            )
          else
            const Text('Tap a muscle', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MuscleMapView(
                gender: _gender,
                side: _bodySide,
                selectedMuscles: _selectedMuscle != null ? {_selectedMuscle!} : const {},
                isPulseEnabled: _selectedMuscle != null,
                pulseSpeed: 1.2,
                onMuscleSelected: (muscle, side) {
                  setState(() {
                    _selectedMuscle = muscle.parentGroup ?? muscle;
                    _selectedSide = side;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Style Demo ==============
class StyleDemo extends StatelessWidget {
  const StyleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _styleCard('Default', BodyViewStyle.defaults, Colors.transparent),
            _styleCard('Minimal', BodyViewStyle.minimal, Colors.transparent),
            _styleCard('Neon', BodyViewStyle.neon, Colors.black),
            _styleCard('Medical', BodyViewStyle.medical, Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _styleCard(String name, BodyViewStyle style, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MuscleMapView(
              gender: BodyGender.male,
              side: BodySide.front,
              style: style,
              highlights: {
                Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.red),
                Muscle.biceps: const MuscleHighlight(muscle: Muscle.biceps, color: Colors.orange),
                Muscle.quadriceps: const MuscleHighlight(muscle: Muscle.quadriceps, color: Colors.red),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Gradient Demo ==============
class GradientDemo extends StatelessWidget {
  const GradientDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gradient Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Linear Gradient'),
            SizedBox(
              height: 400,
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.front,
                highlights: {
                  Muscle.chest: MuscleHighlight(
                    muscle: Muscle.chest,
                    fill: LinearGradientMuscleFill(
                      colors: [Colors.red, Colors.orange.shade300],
                    ),
                  ),
                  Muscle.biceps: MuscleHighlight(
                    muscle: Muscle.biceps,
                    fill: LinearGradientMuscleFill(
                      colors: [Colors.blue, Colors.cyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  Muscle.abs: MuscleHighlight(
                    muscle: Muscle.abs,
                    fill: LinearGradientMuscleFill(
                      colors: [Colors.yellow, Colors.orange, Colors.red],
                    ),
                  ),
                  Muscle.quadriceps: MuscleHighlight(
                    muscle: Muscle.quadriceps,
                    fill: LinearGradientMuscleFill(
                      colors: [Colors.purple, Colors.pink],
                    ),
                  ),
                },
              ),
            ),
            _sectionTitle('Radial Gradient'),
            SizedBox(
              height: 400,
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.front,
                highlights: {
                  Muscle.chest: MuscleHighlight(
                    muscle: Muscle.chest,
                    fill: RadialGradientMuscleFill(
                      colors: [Colors.white, Colors.red, Colors.red.shade900],
                    ),
                  ),
                  Muscle.biceps: MuscleHighlight(
                    muscle: Muscle.biceps,
                    fill: RadialGradientMuscleFill(
                      colors: [Colors.cyan, Colors.blue.shade900],
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== Animation Demo ==============
class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  int _demoStep = 0;

  final List<Map<Muscle, MuscleHighlight>> _highlightSets = [
    {
      Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.red),
      Muscle.biceps: const MuscleHighlight(muscle: Muscle.biceps, color: Colors.orange),
    },
    {
      Muscle.abs: const MuscleHighlight(muscle: Muscle.abs, color: Colors.yellow),
      Muscle.quadriceps: const MuscleHighlight(muscle: Muscle.quadriceps, color: Colors.red),
      Muscle.deltoids: const MuscleHighlight(muscle: Muscle.deltoids, color: Colors.orange),
    },
    {
      Muscle.trapezius: const MuscleHighlight(muscle: Muscle.trapezius, color: Colors.purple),
      Muscle.upperBack: const MuscleHighlight(muscle: Muscle.upperBack, color: Colors.blue),
      Muscle.lowerBack: const MuscleHighlight(muscle: Muscle.lowerBack, color: Colors.cyan),
      Muscle.gluteal: const MuscleHighlight(muscle: Muscle.gluteal, color: Colors.pink),
      Muscle.hamstring: const MuscleHighlight(muscle: Muscle.hamstring, color: Colors.red),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _demoStep = (_demoStep - 1) % _highlightSets.length),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 16),
                Text('Step ${_demoStep + 1}/${_highlightSets.length}'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _demoStep = (_demoStep + 1) % _highlightSets.length),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MuscleMapView(
                gender: BodyGender.male,
                side: _demoStep < 2 ? BodySide.front : BodySide.back,
                highlights: _highlightSets[_demoStep],
                isAnimated: true,
                animationDuration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Gesture Demo ==============
class GestureDemo extends StatefulWidget {
  const GestureDemo({super.key});

  @override
  State<GestureDemo> createState() => _GestureDemoState();
}

class _GestureDemoState extends State<GestureDemo> {
  final Set<Muscle> _selectedMuscles = {};
  String? _lastAction;
  Muscle? _lastMuscle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (_lastAction != null)
                      Chip(
                        label: Text('$_lastAction: ${_lastMuscle?.displayName ?? ""}'),
                        backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      ),
                    Chip(label: Text('Selected: ${_selectedMuscles.length}')),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => setState(_selectedMuscles.clear),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.front,
                selectedMuscles: _selectedMuscles,
                isZoomEnabled: true,
                minZoomScale: 1.0,
                maxZoomScale: 4.0,
                tooltipBuilder: (muscle, side) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    muscle.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                onMuscleSelected: (muscle, side) {
                  setState(() {
                    _lastAction = 'Tap';
                    _lastMuscle = muscle;
                    if (_selectedMuscles.contains(muscle)) {
                      _selectedMuscles.remove(muscle);
                    } else {
                      _selectedMuscles.add(muscle);
                    }
                  });
                },
                onMuscleLongPressed: (muscle, side) {
                  setState(() {
                    _lastAction = 'Long Press';
                    _lastMuscle = muscle;
                  });
                },
                onMuscleDragged: (muscle, side) {
                  setState(() {
                    _lastAction = 'Drag';
                    _lastMuscle = muscle;
                    _selectedMuscles.add(muscle);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Heatmap V2 Demo ==============
class HeatmapV2Demo extends StatefulWidget {
  const HeatmapV2Demo({super.key});

  @override
  State<HeatmapV2Demo> createState() => _HeatmapV2DemoState();
}

class _HeatmapV2DemoState extends State<HeatmapV2Demo> {
  HeatmapColorScale _scale = HeatmapColorScale.workout;
  final InterpolationType _interp = InterpolationType.easeInOut;
  double _threshold = 0.1;

  final Map<Muscle, double> _data = {
    Muscle.chest: 0.95,
    Muscle.biceps: 0.7,
    Muscle.triceps: 0.6,
    Muscle.abs: 0.85,
    Muscle.obliques: 0.5,
    Muscle.deltoids: 0.8,
    Muscle.quadriceps: 0.9,
    Muscle.calves: 0.4,
    Muscle.forearm: 0.3,
    Muscle.upperBack: 0.75,
    Muscle.lowerBack: 0.55,
    Muscle.gluteal: 0.65,
    Muscle.hamstring: 0.7,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap V2 Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<HeatmapColorScale>(
                  segments: const [
                    ButtonSegment(value: HeatmapColorScale.workout, label: Text('Workout')),
                    ButtonSegment(value: HeatmapColorScale.thermal, label: Text('Thermal')),
                    ButtonSegment(value: HeatmapColorScale.medical, label: Text('Medical')),
                    ButtonSegment(value: HeatmapColorScale.neon, label: Text('Neon')),
                  ],
                  selected: {_scale},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) setState(() => _scale = set.first);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Threshold:'),
                    Expanded(
                      child: Slider(
                        value: _threshold,
                        min: 0.0,
                        max: 0.5,
                        onChanged: (v) => setState(() => _threshold = v),
                      ),
                    ),
                    Text(_threshold.toStringAsFixed(2)),
                  ],
                ),
                HeatmapLegend(
                  colorScale: _scale,
                  interpolation: _interp,
                  labelMin: 'Low',
                  labelMax: 'High',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.front,
                heatmapData: _data,
                heatmapConfig: HeatmapConfiguration(
                  colorScale: _scale,
                  interpolation: _interp,
                  threshold: _threshold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Sub-Groups Demo ==============
class SubGroupsDemo extends StatefulWidget {
  const SubGroupsDemo({super.key});

  @override
  State<SubGroupsDemo> createState() => _SubGroupsDemoState();
}

class _SubGroupsDemoState extends State<SubGroupsDemo> {
  bool _hideSubGroups = false;
  Muscle? _selectedMuscle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sub-Groups Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Show Sub-Groups:'),
                Switch(
                  value: !_hideSubGroups,
                  onChanged: (v) => setState(() => _hideSubGroups = !v),
                ),
              ],
            ),
          ),
          if (_selectedMuscle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _selectedMuscle!.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedMuscle!.subGroups.isNotEmpty)
                    Text(
                      'Sub-groups: ${_selectedMuscle!.subGroups.map((s) => s.displayName).join(", ")}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MuscleMapView(
                gender: BodyGender.male,
                side: BodySide.front,
                hideSubGroups: _hideSubGroups,
                selectedMuscles: _selectedMuscle != null ? {_selectedMuscle!} : const {},
                onMuscleSelected: (muscle, side) {
                  setState(() => _selectedMuscle = muscle);
                },
                highlights: {
                  Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.red, opacity: 0.5),
                  Muscle.quadriceps: const MuscleHighlight(muscle: Muscle.quadriceps, color: Colors.orange, opacity: 0.5),
                  Muscle.abs: const MuscleHighlight(muscle: Muscle.abs, color: Colors.yellow, opacity: 0.5),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}
