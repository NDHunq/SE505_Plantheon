# Plantheon

A comprehensive mobile application for plant disease detection and agricultural management, powered by artificial intelligence and computer vision.

<img width="200" height="200" alt="logo" src="https://github.com/user-attachments/assets/d004e0e8-95bc-48d2-9b6b-ae217ff88dec" />

## Overview

Plantheon is an intelligent farming assistant that helps farmers and plant enthusiasts identify plant diseases, manage their agricultural activities, and connect with a community of growers. The application leverages deep learning models to provide accurate disease detection and offers personalized recommendations for treatment and prevention.

## Key Features

### 🔍 AI-Powered Disease Detection
- Real-time plant disease identification using advanced computer vision
- Multi-stage detection pipeline with YOLOv8 and EfficientNet-B4
- Confidence scoring and detailed disease information
- Historical scan tracking and analysis
- Image comparison with reference disease samples

### 📱 Smart Agricultural Management
- **Digital Farming Diary**: Track daily activities, expenses, and sales
- **Activity Logging**: Record planting, harvesting, fertilizing, and other farm operations
- **Financial Tracking**: Monitor expenses and revenue from product sales
- **Calendar Integration**: Organize and visualize farming schedules

### 🌤️ Weather Integration
- Location-based weather forecasts
- Real-time weather data for informed decision-making
- Weather-aware farming recommendations

### 👥 Community Features
- Share experiences and knowledge with other farmers
- Post updates and farming tips
- User profiles and activity feeds
- Community-driven learning

### 📰 Agricultural News & Guides
- Curated farming guides and best practices
- Latest agricultural news and updates
- Expert tips and recommendations

### 🔔 Smart Notifications
- Push notifications for important updates
- Firebase Cloud Messaging integration
- Customizable notification preferences

## Technical Architecture

### Frontend (Mobile Application)
- **Framework**: Flutter 3.9.0
- **State Management**: BLoC (Business Logic Component) pattern
- **Architecture**: Clean Architecture with separation of concerns
  - **Presentation Layer**: UI components, screens, and BLoC
  - **Domain Layer**: Business logic, entities, and use cases
  - **Data Layer**: Models, repositories, and data sources

### Backend Services
- **Main API Server**: RESTful API for data management
- **AI Prediction Server**: Dedicated server for ML inference
- **Database**: Supabase (PostgreSQL)
- **Authentication**: JWT-based authentication
- **Storage**: Firebase Storage for media files

### AI/ML Models
- **YOLOv8**: Object detection for plant identification
- **EfficientNet-B4**: Disease classification model
- **Two-stage pipeline**: Enhanced accuracy with pre-filtering

## Project Structure

```
lib/
├── core/                    # Core utilities and configurations
│   ├── configs/            # App configurations and constants
│   ├── services/           # Shared services (Firebase, Supabase, etc.)
│   └── utils/              # Helper functions and utilities
├── data/                    # Data layer
│   ├── datasources/        # Remote and local data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business use cases
└── presentation/            # Presentation layer
    ├── bloc/               # BLoC state management
    ├── screens/            # UI screens
    └── widgets/            # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- Firebase account
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/SE505_Plantheon.git
   cd SE505_Plantheon
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Copy the example environment file and fill in your credentials:
   ```bash
   cp .env.example .env
   ```
   
   Update the `.env` file with your Firebase and Supabase credentials:
   - Firebase API keys (Web, Android, iOS)
   - Supabase URL and anonymous key

4. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

5. **Run the application**
   ```bash
   flutter run
   ```

## Configuration

### Firebase Setup
The application uses Firebase for:
- Push notifications (Firebase Cloud Messaging)
- Analytics (Firebase Analytics)
- Dynamic links for content sharing

### Supabase Setup
Supabase is used for:
- User authentication
- Database storage
- Real-time data synchronization

### API Configuration
Update the API endpoints in `lib/core/configs/constants/api_constants.dart` to point to your backend servers.

## Key Dependencies

- **flutter_bloc**: State management
- **supabase_flutter**: Backend integration
- **firebase_core**: Firebase services
- **camera**: Camera access for scanning
- **image_picker**: Image selection
- **geolocator**: Location services
- **cached_network_image**: Image caching
- **flutter_tts**: Text-to-speech functionality
- **lottie & rive**: Advanced animations
- **share_plus**: Content sharing
- **app_links**: Deep linking support

## Development

### Code Style
The project follows Flutter's official style guide and uses `flutter_lints` for code analysis.

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Features in Detail

### Disease Detection Flow
1. User captures or selects a plant image
2. Image is sent to the AI prediction server
3. YOLOv8 detects and validates plant presence
4. EfficientNet-B4 classifies the disease
5. Results are displayed with confidence scores
6. Detailed disease information and treatment recommendations
7. Scan history is saved for future reference

### Complaint System
Users can report incorrect disease predictions to help improve the AI model accuracy. The system tracks:
- Predicted disease vs. actual disease
- User feedback and suggestions
- Confidence scores for analysis

### Deep Linking
The application supports deep links for sharing scan results and navigating directly to specific content within the app.

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is developed as part of the SE505 course. All rights reserved.

## Contact

For questions or support, please contact the development team.

## Acknowledgments

- Flutter team for the excellent framework
- Firebase and Supabase for backend services
- The open-source community for various packages and tools
- Agricultural experts for domain knowledge and guidance
