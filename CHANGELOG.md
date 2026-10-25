# Changelog

## 1.1.0

- Sync cross-platform updates from upstream MuscleMap 1.7.0–1.9.0
- Add real artwork for rhomboids, rotator cuff, rear deltoid, upper/lower trapezius, and female back ankles
- Redraw front sub-groups from their parent muscle outlines
- Share parsed paths across renderers and support preloading all artwork
- Add `drawable` and `drawableFor` muscle mapping queries
- Add stepped workout and smooth thermal heatmap scales with correct interpolation precedence
- Preserve host highlighting and tap fallback for carved and overlay regions
- Add interaction tests and golden coverage for all body models

## 1.0.0

- Initial release
- SVG-based interactive human body muscle map rendering
- 36 muscle groups (22 base + 14 sub-groups) with left/right detection
- 4 body models: Male/Female x Front/Back
- Muscle highlighting: solid colors, linear gradients, radial gradients
- Heatmap with 4 color scales: workout, thermal, medical, neon
- 4 visual styles: default, minimal, neon, medical
- Gesture support: tap, long-press, drag-to-select, pinch-to-zoom
- Smooth transition and pulse animations
- Custom tooltip builder for selected muscles
- Sub-group support with parent/child inheritance
- Full-featured example app with 9 demo tabs
