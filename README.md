# Notes Keep 📝

A clean, feature-rich notes app built with Flutter.

## Features
- ✅ Create, Edit, Delete notes
- 🔍 Search notes
- 📁 Categories / Folders
- 📌 Pin important notes
- 🎨 Rich text editor (bold, italic, lists, headings)
- 🌗 Auto light/dark theme
- 💾 Local SQLite storage (no internet needed)

## Setup

### Prerequisites
- Flutter 3.24+ installed
- VS Code with Flutter extension

### Run locally
```bash
flutter pub get
flutter run
```

### Build APK manually
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Build APK via GitHub Actions

1. Push this project to a GitHub repo
2. Go to **Actions** tab
3. The workflow runs automatically on every push
4. Download APK from **Artifacts** section

## Project Structure
```
lib/
├── main.dart              # Entry point
├── models/
│   ├── note.dart          # Note model
│   └── category.dart      # Category model
├── services/
│   └── database_service.dart  # SQLite operations
├── screens/
│   ├── home_screen.dart   # Main notes list
│   ├── editor_screen.dart # Rich text editor
│   └── categories_screen.dart # Manage categories
├── widgets/
│   ├── note_card.dart     # Note card widget
│   └── category_chip.dart # Category filter chip
└── theme/
    └── app_theme.dart     # Light & dark theme
```

## Tech Stack
- **Flutter** — UI framework
- **sqflite** — Local SQLite database
- **flutter_quill** — Rich text editor
- **flutter_staggered_grid_view** — Masonry grid layout
- **uuid** — Unique IDs for notes

---
Built as part of the Notes Keep OS project 🚀
