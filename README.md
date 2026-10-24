# Travelin Mobile

Travelin Mobile is a Flutter application for travel and transport operators. It provides a mobile interface for day-to-day operations such as reservations, vehicles, users, payments, and operational reports. The app communicates with the Travelin REST API; it does not connect directly to the database.

## Features

- Sign-in and account registration
- Reservation and trip-planning workflows
- Vehicle, user, and owner management screens
- Payment, transaction, and withdrawal workflows
- Transaction and monthly reporting screens
- Indonesian-localized dates and currency formatting

Available screens and permissions depend on the account role and the API configuration.

## Architecture

```text
Flutter mobile app
       │ HTTP / JSON
       ▼
Travelin REST API (Express)
       │ Sequelize
       ▼
   PostgreSQL
```

The Flutter client keeps API calls in `lib/services/`, response models in `lib/models/`, and screens in `lib/pages/`. API URL construction is centralized in `lib/config/api_config.dart`.

## Technology

- Flutter and Dart
- REST API over HTTP/JSON
- `http` for network requests
- `shared_preferences` for local preferences
- `flutter_dotenv` for environment-based API URLs

## Requirements

- Flutter SDK compatible with Dart 3.7 or later
- A running Travelin API instance
- Android Studio/Xcode or another configured Flutter target

## Run locally

1. Clone this repository and install Flutter dependencies:

   ```bash
   git clone https://github.com/agunglaksonoputra/PJ4-travelin-mobile.git
   cd PJ4-travelin-mobile
   flutter pub get
   ```

2. Create a `.env` file in the repository root. Set each URL to the API host **without** the `/api/v1` path; the app adds the API version path itself.

   ```dotenv
   API_DEV_URL=http://10.0.2.2:3000
   API_PROD_URL=https://your-api-host.example
   ```

   For Android Emulator, `10.0.2.2` points to the development machine. For a physical device, use a host reachable on the same network. Keep real credentials and private URLs out of Git.

3. Start the app:

   ```bash
   flutter run
   ```

The API must be configured and running separately. See the [Travelin API repository](https://github.com/agunglaksonoputra/PJ4-travelin-api) for its setup instructions.

## Repository layout

```text
lib/
├── config/       # API configuration
├── helper/       # App-level helpers
├── models/       # API response and domain models
├── pages/        # Application screens
├── services/     # API clients and service methods
├── utils/        # Formatting, validation, and logging helpers
└── widgets/      # Reusable UI components
```
