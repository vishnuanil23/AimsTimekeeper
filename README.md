# AimsTimekeeper

AimsTimekeeper is a production-ready Flutter application designed for attendance management. It features a robust architecture, beautiful UI, and integrated geo-location tracking for attendance accuracy.

## Architecture

The project follows a modular architecture leveraged by the **GetX** ecosystem for state management, dependency injection, and routing. It emphasizes a clean separation of concerns using a **VM-B-V** (ViewModel-Binding-View) pattern within each feature.

### Project Structure

```text
lib/
├── main.dart
├── core/
│   ├── network/          # API handlers and networking logic
│   ├── routes/           # App navigation definitions (AppPages, AppRoutes)
│   └── services/         # Persistent application-level services
├── data/
│   ├── models/           # Global data entities
│   └── repositories/     # Data source abstractions and business logic
├── features/             # Feature-specific modules
│   ├── splash/           # Initial loading and routing logic
│   ├── login/            # Authentication flow
│   └── home/             # Main dashboard and attendance actions
│       ├── bindings/     # Dependency injection setup
│       ├── viewmodels/   # Business logic using GetxController
│       └── views/        # UI layer
└── utils/                # Global constants, colors, and date-time helpers
```

## Key Features

- **MVVM with GetX**: Clean, reactive state management and navigation.
- **Attendance Management**: Single-button toggle for Punch-In/Out.
- **Reverse Geocoding (OSM)**: Integrates OpenStreetMap's Nominatim API to resolve GPS coordinates into human-readable locations (Area, State, Country).
- **Location Caching**: Persistent caching of resolved locations in `SharedPreferences` to ensure immediate display on app launch.
- **Enhanced UI**: Custom date formatting (e.g., "16th Feb 2026") and dynamic header displaying current recorded location.
- **Robust Repository Pattern**: Decentralized logic with dedicated `AttendanceRepository` and `LocationRepository`.

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.0)
- Android Studio / VS Code
- Dart SDK (^3.7.0)

### Installation

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Configure the `baseUrl` in `lib/utils/constants.dart`.
4. Run the app using `flutter run`.

## Dependencies

- `get`: State management & routing.
- `http`: Networking.
- `geolocator`: GPS location access.
- `intl`: Date and time formatting.
- `shared_preferences`: Local storage.

---
*Built with Flutter and productivity in mind.*
