# Demo Recording

This directory contains the demo recording file: `demo_recording.mp4`

## Recording Content

The demo recording shows:
1. App loading with skeleton UI
2. Range switching (90d → 30d → 7d)
3. Pan & zoom interactions across charts
4. Synchronized tooltip behavior when hovering over charts
5. Journal annotation markers (colored vertical lines)
6. Error handling with retry functionality
7. Large dataset toggle and performance demonstration

## Recording Instructions

To create the demo recording:

1. Run the app: `flutter run -d chrome`
2. Use screen recording software (QuickTime on macOS, OBS, etc.)
3. Follow the demo flow outlined above
4. Keep recording under 2 minutes
5. Save as `demo_recording.mp4` in this directory

## Demo Flow Checklist

- [ ] Show app loading (skeleton UI appears)
- [ ] Switch from 90d to 30d range
- [ ] Switch from 30d to 7d range  
- [ ] Hover over charts to show synchronized tooltips
- [ ] Pan and zoom on charts
- [ ] Point out journal annotation markers
- [ ] Toggle large dataset mode
- [ ] Trigger error (refresh until 10% failure occurs)
- [ ] Click retry button
- [ ] Show smooth performance with large dataset
