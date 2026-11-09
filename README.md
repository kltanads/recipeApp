# Recipe App

A Flutter-based recipe management application developed as part of the Flutter Application Developer Take-Home Assignment.

The application allows users to manage recipes locally, filter recipes by category, import recipes from a remote API, and sign in using a demo authentication service.

## Features

### Recipe Management
- View a list of saved recipes.
- View recipe details, including ingredients and preparation steps.
- Create, edit, and delete recipes.
- Select a recipe category.
- Add recipe images from the device.
- Filter recipes by recipe type.
- Persist recipe data locally using SQLite.

### Recipe Categories
Recipe categories are loaded from the local `assets/data/recipetypes.json` file rather than hardcoded in the UI.

### Remote Recipe Import
- Fetch recipes from the DummyJSON Recipes API.
- Import recipes into the local SQLite database.
- Download remote recipe images for local storage.
- Skip previously imported recipes to prevent duplicates.
- Display import progress and results.
- Keep locally edited recipes unchanged during subsequent imports.

### Authentication
- Sign in using DummyJSON Authentication API.
- Validate user credentials.
- Store access and refresh tokens using Flutter Secure Storage.
- Restore a saved session when the application starts.
- Log out and clear locally stored authentication tokens.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter / Dart | Application development |
| Material Design | User interface |
| Provider / ChangeNotifier | State management |
| SQLite / sqflite | Local recipe persistence |
| HTTP | Remote API integration |
| flutter_secure_storage | Secure token storage |
| image_picker | Recipe image selection |
| path_provider | Local file storage |

## Architecture

The application follows a lightweight MVVM-inspired structure using Provider and ChangeNotifier.

```text
lib/
├── models/
│   ├── recipe.dart
│   ├── remote_recipe_dto.dart
│   ├── auth_user.dart
│   └── auth_login_result.dart
├── services/
│   ├── recipe_api_service.dart
│   ├── auth_storage_service.dart
│   ├── image_storage_service.dart
│   └── recipe_import_service.dart
├── repositories/
│   └── recipe_repository.dart
├── viewmodels/
│   ├── recipe_viewmodel.dart
│   └── auth_viewmodel.dart
├── screens/
│   ├── recipe_list_screen.dart
│   ├── import_recipe_screen.dart
│   └── login_screen.dart
└── main.dart
```

Additional files include database helpers, recipe form and detail screens, recipe type definitions, and supporting utilities.

### Responsibilities

**Models:** Represent application data and API response structures.

**Services:** Handle HTTP requests, authentication token storage, image storage, and recipe importing.

**Repository:** Manages local recipe persistence through SQLite.

**ViewModels:** Manage application state, business operations, loading states, and error handling.

**Screens:** Display the user interface and respond to user interactions.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or a physical device

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
```

2. Navigate to the project directory:

```bash
cd <project-directory>
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

An internet connection is required for authentication and remote recipe importing.

## Demo Login

The application uses DummyJSON for demonstration purposes.

| Field | Value |
|---|---|
| Username | `emilys` |
| Password | `emilyspass` |

These are public demo credentials provided for demonstration purposes.

## API Integration

Base URL:

```text
https://dummyjson.com
```

| Method | Endpoint | Description |
|---|---|---|
| GET | `/recipes?limit=10` | Fetch remote recipes |
| POST | `/auth/login` | Authenticate user |
| GET | `/auth/me` | Retrieve current user |
| POST | `/auth/refresh` | Refresh authentication tokens |

Remote recipe data is mapped into the application's local Recipe model before being stored in SQLite.

Remote recipes use stable identifiers to prevent duplicate imports.

The application uses the remote API for recipe retrieval and SQLite for persistent recipe CRUD operations.

## Local Storage

### SQLite

SQLite stores recipe information, including:

- Recipe ID
- Recipe name
- Recipe type
- Local image path
- Ingredients
- Preparation steps

The application includes sample recipes for initial demonstration.

### Image Storage

Images selected from the device or downloaded during import are saved locally.

Recipe records store local image paths rather than remote image URLs, allowing imported images to remain available after download.

### Secure Storage

Authentication access and refresh tokens are stored using `flutter_secure_storage`.

Tokens are cleared when the user logs out.

## State Management

Provider and ChangeNotifier are used to manage application state.

`RecipeViewModel` manages recipe loading, filtering, and CRUD operations.

`AuthViewModel` manages authentication status, login, logout, session restoration, loading, and error states.

The application's authentication gate determines whether to display the Login Screen or Recipe List Screen.

## Error Handling

The application includes basic error handling for:

- Failed API requests
- Invalid login credentials
- Recipe loading failures
- Remote recipe import failures
- Image download failures
- Form validation

## Known Limitations

- Authentication uses DummyJSON, a public demonstration API, rather than a production authentication backend.
- Recipes are stored in a shared local SQLite database and are not isolated by authenticated user.
- Token refresh is handled during session restoration rather than through a global HTTP interceptor.
- Temporary network failures during session restoration may require the user to sign in again.
- Remote recipe importing is limited to the configured API request.
- Imported recipes with unsupported recipe categories may be skipped.
- Remote recipe modifications are not synchronized back to DummyJSON.

## Future Improvements

- Improve token expiration and offline session handling.
- Introduce dependency injection for improved maintainability.
- Support dynamic ingredient and preparation step fields.
- Improve unused image cleanup.
- Add recipe search and sorting.
- Support user-specific recipe storage.

## Assignment Notes

The application prioritizes core recipe functionality, local persistence, remote API integration, and a clear separation of responsibilities.

Provider and ChangeNotifier provide reactive UI updates, while the repository and service layers keep data access separate from presentation logic.

The recipe category JSON file contains locally defined sample categories used for the assignment.

## License

This project was developed for technical assessment and demonstration purposes.