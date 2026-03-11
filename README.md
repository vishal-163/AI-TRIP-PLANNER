# AI Trip Planner

A Flutter mobile application that generates personalized travel itineraries using Gemini AI or OpenRouter API and provides expense tracking features.

## Features

- AI-powered trip planning using Gemini API or OpenRouter API
- Interactive map view with Google Maps
- Expense tracking and splitting system
- Light and dark themes
- Responsive design for phones and tablets
- City autocomplete for origin and destination fields
- Switch between AI providers in settings

## Screenshots

![Trip Input](assets/images/screenshot1.png)
![Itinerary](assets/images/screenshot2.png)
![Map View](assets/images/screenshot3.png)
![Expense Tracker](assets/images/screenshot4.png)

## Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio or VS Code
- Gemini API key or OpenRouter API key
- Google Maps API key

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ai-trip-planner.git
   ```

2. Navigate to the project directory:
   ```bash
   cd ai_trip_planner
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Set up API keys:
   
   #### Getting your Gemini API Key:
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Create API key"
   - Copy the generated API key
   
   #### Getting your OpenRouter API Key:
   - Go to [OpenRouter](https://openrouter.ai/)
   - Sign up for an account
   - Navigate to API keys section
   - Create a new API key
   - Copy the generated API key
   
   #### Getting your Google Maps API Key:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Maps SDK for Android and/or iOS
   - Go to "Credentials" and create an API key
   - Copy the generated API key
   
   #### Adding API keys to the project:
   - Update the `.env` file in the root directory:
     ```env
     GEMINI_API_KEY=your_actual_gemini_api_key_here
     OPENROUTER_API_KEY=your_actual_openrouter_api_key_here
     GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
     ```
   - For iOS, update `ios/Runner/Info.plist` with your Google Maps API key:
     ```xml
     <key>io.flutter.embedded_views_preview</key>
     <true/>
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>This app needs location access to show your position on the map.</string>
     ```
   - For Android, update `android/app/src/main/AndroidManifest.xml` with your Google Maps API key:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="your_actual_google_maps_api_key_here" />
     ```

5. Generate the model files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── src/
│   ├── app.dart
│   ├── core/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── router/
│   │   ├── services/
│   │   └── theme/
│   └── features/
│       ├── expenses/
│       ├── map_view/
│       ├── settings/
│       └── trip_generation/
└── assets/
    ├── fonts/
    ├── icons/
    └── images/
```

## Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation
- `google_maps_flutter` - Map integration
- `http` - HTTP client for API requests
- `json_annotation` - JSON serialization
- `shared_preferences` - Local data storage
- `pdf` - PDF generation
- `path_provider` - File system access
- `equatable` - Value equality
- `intl` - Internationalization
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching
- `geolocator` - Location services
- `geocoding` - Geocoding services
- `url_launcher` - URL launching
- `flutter_markdown` - Markdown rendering

## AI Service Integration

The app supports two AI services for generating personalized travel itineraries:

### Gemini API
The app uses the Gemini API to generate personalized travel itineraries. The integration is handled through the [GeminiService](lib/src/core/services/gemini_service.dart) which formats the user's trip preferences into a prompt and sends it to the Gemini API.

Example prompt structure:
```
Generate a detailed travel itinerary in JSON format for a trip with the following details:
- Origin: [user input]
- Destinations: [user input]
- Start Date: [user input]
- End Date: [user input]
- Budget Level: [user input]
- Number of Travelers: [user input]
- Interests: [user input]
- Special Constraints: [user input]
```

### OpenRouter API
The app previously supported OpenRouter API which provided access to multiple AI models. This integration has been removed to focus solely on the Gemini API for better reliability and performance.

## Map Integration

The app uses Google Maps Flutter SDK to display points of interest from the generated itinerary. To set up Google Maps:

1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the Maps SDK for Android and/or iOS
3. Add the API key to your platform-specific configuration files

## Expense Tracking

The expense tracking feature allows users to:
- Add expenses with details (title, amount, category, payer)
- View expense summaries
- Split expenses between travelers
- Generate settlement reports
- Export expense summaries as PDF

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to Google for the Gemini API
- Thanks to the Flutter community for the amazing packages