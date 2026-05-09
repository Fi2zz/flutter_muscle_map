# MuscleMap Flutter

A Flutter SDK for rendering interactive human body muscle maps with highlights, heatmaps, gestures, and animations. Supports male & female body models with front & back views.

Ported from the original [MuscleMap SwiftUI SDK](https://github.com/melihcolpan/MuscleMap).

## Features

| Feature | Description |
|---------|-------------|
| **SVG Rendering** | High-quality vector-based body maps via CustomPainter |
| **36 Muscle Groups** | 22 base + 14 sub-groups with left/right detection |
| **4 Body Models** | Male/Female x Front/Back views |
| **Muscle Highlighting** | Solid colors, linear gradients, radial gradients |
| **Heatmap** | 4 color scales (workout, thermal, medical, neon) |
| **4 Visual Styles** | Default, minimal, neon, medical |
| **Gestures** | Tap selection, long-press, drag-to-select, pinch-to-zoom |
| **Animations** | Smooth transition and pulse effects |
| **Tooltips** | Custom tooltip builder for selected muscles |
| **Sub-Groups** | Parent/child inheritance with priority hit testing |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  muscle_map:
    git:
      url: https://github.com/Fi2zz/flutter_muscle_map.git
```

Or for a local path:

```yaml
dependencies:
  muscle_map:
    path: /path/to/muscle_map
```

## Quick Start

```dart
import 'package:muscle_map/muscle_map.dart';

// Basic highlighting
MuscleMapView(
  gender: BodyGender.male,
  side: BodySide.front,
  highlights: {
    Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.red),
    Muscle.biceps: const MuscleHighlight(muscle: Muscle.biceps, color: Colors.orange),
  },
)

// Interactive with tap callback
MuscleMapView(
  gender: BodyGender.female,
  side: BodySide.back,
  onMuscleSelected: (muscle, side) {
    debugPrint('${muscle.displayName} (${side.displayName})');
  },
)

// Heatmap
MuscleMapView(
  gender: BodyGender.male,
  side: BodySide.front,
  heatmapData: {
    Muscle.chest: 0.95,
    Muscle.biceps: 0.7,
    Muscle.abs: 0.85,
  },
  heatmapConfig: const HeatmapConfiguration(
    colorScale: HeatmapColorScale.workout,
  ),
)
```

## API Reference

### MuscleMapView

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `gender` | `BodyGender` | `male` | Body model gender |
| `side` | `BodySide` | `front` | Body view side |
| `style` | `BodyViewStyle` | `defaults` | Visual style |
| `highlights` | `Map<Muscle, MuscleHighlight>` | `{}` | Muscle highlight colors |
| `selectedMuscles` | `Set<Muscle>` | `{}` | Selected muscle set |
| `heatmapData` | `Map<Muscle, double>` | `null` | Intensity data (0.0-1.0) |
| `heatmapConfig` | `HeatmapConfiguration` | `null` | Heatmap configuration |
| `isAnimated` | `bool` | `false` | Enable transition animation |
| `isPulseEnabled` | `bool` | `false` | Enable pulse animation |
| `isZoomEnabled` | `bool` | `false` | Enable pinch-to-zoom |
| `hideSubGroups` | `bool` | `true` | Hide sub-group muscles |
| `onMuscleSelected` | `Function(Muscle, MuscleSide)` | `null` | Tap callback |
| `onMuscleLongPressed` | `Function(Muscle, MuscleSide)` | `null` | Long-press callback |
| `onMuscleDragged` | `Function(Muscle, MuscleSide)` | `null` | Drag callback |
| `tooltipBuilder` | `Widget Function(Muscle, MuscleSide)` | `null` | Tooltip builder |

### BodyViewStyle Presets

- `BodyViewStyle.defaults` - Standard style
- `BodyViewStyle.minimal` - Clean minimal look
- `BodyViewStyle.neon` - Dark background with neon glow
- `BodyViewStyle.medical` - Clinical blue tone

### HeatmapColorScale

- `HeatmapColorScale.workout` - Green to Red
- `HeatmapColorScale.thermal` - Blue to Red
- `HeatmapColorScale.medical` - Light to Dark blue
- `HeatmapColorScale.neon` - Neon colors on dark background

### Muscle Enum

22 base muscles: `abs`, `biceps`, `calves`, `chest`, `deltoids`, `feet`, `forearm`, `gluteal`, `hamstring`, `hands`, `head`, `knees`, `lowerBack`, `obliques`, `quadriceps`, `tibialis`, `trapezius`, `triceps`, `upperBack`, `rotatorCuff`, `serratus`, `rhomboids`

14 sub-groups: `upperChest`, `lowerChest`, `innerQuad`, `outerQuad`, `upperAbs`, `lowerAbs`, `frontDeltoid`, `rearDeltoid`, `upperTrapezius`, `lowerTrapezius`, `hipFlexors`, `ankles`, `adductors`, `neck`

## Example App

The `example/` directory contains a full-featured demo app with 9 showcase tabs (highlight, heatmap, interactive, styles, gradient, animation, gestures, heatmap v2, sub-groups).

```bash
cd example
flutter run
```

## License

MIT License

---

## 中文

用于渲染交互式人体肌肉解剖图的 Flutter SDK，支持高亮、热力图、手势和动画效果。支持男性/女性身体模型的正面/背面视图。

### 功能特性

| 特性 | 说明 |
|------|------|
| **SVG 渲染** | 基于 CustomPainter 的高质量矢量身体图 |
| **36 个肌肉组** | 22 个基础 + 14 个子肌群，支持左右检测 |
| **4 种身体模型** | 男性/女性 x 正面/背面 |
| **肌肉高亮** | 纯色、线性渐变、径向渐变 |
| **热力图** | 4 种配色方案（运动、热力、医学、霓虹） |
| **4 种视觉风格** | 默认、极简、霓虹、医学 |
| **手势交互** | 点击选择、长按、拖拽多选、捏合缩放 |
| **动画效果** | 平滑过渡和脉冲发光效果 |
| **工具提示** | 自定义选中肌肉提示框 |
| **子肌群** | 父子继承关系与优先级命中检测 |

### 安装

```yaml
dependencies:
  muscle_map:
    git:
      url: https://github.com/Fi2zz/flutter_muscle_map.git
```

### 快速开始

```dart
import 'package:muscle_map/muscle_map.dart';

MuscleMapView(
  gender: BodyGender.male,
  side: BodySide.front,
  highlights: {
    Muscle.chest: const MuscleHighlight(muscle: Muscle.chest, color: Colors.red),
    Muscle.biceps: const MuscleHighlight(muscle: Muscle.biceps, color: Colors.orange),
  },
)
```

### 开源协议

MIT 许可证
