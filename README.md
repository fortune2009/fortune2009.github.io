# Wear Data Dashboard

A Flutter Web application for visualizing wearable biometrics and journaling data with synchronized charts, interactive tooltips, and performance-optimized rendering.

## 🚀 Live Demo

**[View Live Demo](https://yourusername.github.io/wear-data/)**

## 📹 Demo Recording

See the complete app demonstration at: `/demo/demo_recording.mp4`

The recording shows:
- App loading with skeleton UI
- Range switching (90d → 30d → 7d)
- Pan & zoom interactions
- Synchronized tooltip behavior across charts
- Journal annotation interactions
- Error handling with retry functionality
- Large dataset performance demonstration

## 🏗️ Setup & Development

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Chrome browser for web development

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/wear-data.git
cd wear-data

# Install dependencies
flutter pub get

# Run the app in Chrome
flutter run -d chrome

# Or run in debug mode with hot reload
flutter run -d chrome --debug
```

### Build & Deploy

```bash
# Build for production
flutter build web --release

# The built files will be in build/web/
# Deploy these files to your preferred hosting service
```

## 📚 Library Choices & Rationale

### FL Chart
- **Why**: Mature Flutter charting library with excellent performance and customization
- **Alternatives considered**: Syncfusion (more features but larger bundle size)
- **Benefits**: Native Flutter widgets, good touch interactions, extensive customization

### Riverpod
- **Why**: Modern state management with better developer experience than Provider
- **Benefits**: Compile-time safety, automatic disposal, excellent testing support
- **Use cases**: Managing app state, data loading, tooltip synchronization

### Intl
- **Why**: Standard internationalization package for date formatting
- **Usage**: Consistent date display across the application

## 🔧 Decimation Algorithm

### LTTB (Largest Triangle Three Buckets)
The app uses the LTTB algorithm for downsampling large datasets while preserving visual fidelity:

**How it works:**
1. Divides data into buckets based on target output size
2. For each bucket, finds the point that creates the largest triangle area with neighboring points
3. Preserves global min/max values to maintain data integrity
4. Maintains chronological order for time-series data

**Benefits:**
- Preserves important peaks and valleys
- Maintains visual shape of the original data
- Reduces rendering overhead for large datasets
- Configurable target size based on screen resolution

**Implementation:** See `lib/utils/decimator.dart`

## ⚡ Performance Optimization

### Metrics & Results
- **Target**: <16ms frame time for 60fps
- **Large dataset (10k+ points)**: Decimated to ~100 points for smooth interaction
- **Memory usage**: Efficient with lazy loading and data filtering
- **Bundle size**: ~2.1MB gzipped (optimized for web)

### Optimization Strategies
1. **Data Decimation**: LTTB algorithm reduces visual complexity
2. **Lazy Loading**: Charts only render visible data ranges
3. **Efficient State Management**: Riverpod prevents unnecessary rebuilds
4. **Widget Optimization**: Const constructors and selective rebuilds
5. **Asset Optimization**: Compressed JSON data files

### Performance Testing
```bash
# Run performance tests
flutter test test/unit/data_decimator_test.dart

# Profile the app (development mode)
flutter run --profile -d chrome
```

## 🏛️ Architecture Summary

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget with theming
├── screens/
│   └── biometrics_dashboard_screen.dart  # Main dashboard
├── models/
│   ├── biometric_entry.dart  # Data model for biometrics
│   └── journal_entry.dart    # Data model for journal entries
├── services/
│   └── data_service.dart     # Data loading with simulated latency/failures
├── widgets/
│   ├── biometrics_charts.dart    # Main chart widgets with sync
│   ├── chart_container.dart      # Chart wrapper component
│   ├── range_selector.dart       # Date range controls
│   ├── loading_view.dart         # Loading skeleton UI
│   └── error_view.dart           # Error state with retry
└── utils/
    ├── decimator.dart        # LTTB decimation algorithm
    └── rolling_stats.dart    # 7-day rolling statistics
```

### Key Features
- **Synchronized Tooltips**: Shared state provider coordinates tooltip display across all charts
- **Responsive Design**: Adapts to different screen sizes (minimum 375px width)
- **Dark Mode Support**: Automatic theme switching based on system preference
- **Error Handling**: Graceful degradation with retry mechanisms
- **Performance Monitoring**: Built-in decimation for large datasets

### Data Flow
1. **Data Service** loads JSON assets with simulated latency/failures
2. **Riverpod Providers** manage state and cache data
3. **Charts Widget** processes and renders data with decimation
4. **Tooltip Provider** synchronizes interactions across charts
5. **Range Selector** filters data and triggers re-renders

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/unit/
flutter test test/widget/
```

### Test Coverage
- **Unit Tests**: Decimation algorithm validation
- **Widget Tests**: Range switching and tooltip synchronization
- **Integration**: Data loading and error handling

## 🚀 Deployment

### Automatic Deployment
The project includes GitHub Actions workflow that:
1. Runs tests on every push
2. Builds the web app
3. Deploys to GitHub Pages on main branch

### Manual Deployment Options

#### GitHub Pages
```bash
flutter build web --base-href /wear-data/
# Upload build/web/ contents to gh-pages branch
```

#### Vercel
```bash
flutter build web
# Connect repository to Vercel
# Build command: flutter build web
# Output directory: build/web
```

#### Netlify
```bash
flutter build web
# Drag build/web/ folder to Netlify deploy
# Or connect repository with build command: flutter build web
```

## 🔧 Development Commands

```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Run with hot reload
flutter run -d chrome

# Build for production
flutter build web --release

# Analyze code quality
flutter analyze

# Format code
dart format .
```

## 📱 Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details
