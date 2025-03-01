# Workout Exporter Development Guide

## Build & Run Commands
- Build and run on device: `./start.sh` (requires `.env` file with TARGET_DEVICE_UUID)
- Run tests: `xcodebuild test -scheme "Workout Exporter" -destination "platform=iOS Simulator,name=iPhone 15"`
- Run single test: `xcodebuild test -scheme "Workout Exporter" -destination "platform=iOS Simulator,name=iPhone 15" -only-testing:Workout_ExporterTests/SpecificTestClass/testMethodName`

## Code Style Guidelines
- **Architecture**: MVVM pattern with SwiftUI views
- **Naming**: PascalCase for types (e.g., `WorkoutExporterView`), camelCase for functions/properties
- **File Structure**: 
  - Views in `*View.swift`
  - ViewModels in `*ViewModel.swift`
  - Models as separate types
- **Imports**: Standard Swift imports at top of file
- **Error Handling**: Use Swift's Result type and async/await pattern
- **Singletons**: Use shared instance pattern for services (e.g., `HealthKitManager.shared`)
- **Comments**: File headers with filename and creation date
- **Feature Organization**: Group related files in feature folders (e.g., Exports, WorkoutChooser)
- **Commit Messages**: Follows Conventional Commit format
