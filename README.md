# Family Vault

A cross-platform Flutter app (Android + iOS) for securely organising and storing personal and family documents — locally on your device with AES-256 encryption.

## Features

- **Family Profiles (Lockers)** — Create a locker for each family member (self, spouse, children, parents, relatives). Each locker has a custom emoji avatar, colour, and relationship label.
- **Folder System** — Each profile contains categorised folders (Identity, Medical, Education, Financial, Insurance, Legal, Travel, etc.) that you can add more of.
- **Encrypted File Storage** — Every file (image, PDF, certificate) is encrypted with AES-256-CBC before being written to the device. The 256-bit key is stored in the OS secure keychain (Android Keystore / iOS Keychain). No cloud sync — everything stays on your phone.
- **File Import** — Pick files from your device, take a photo with camera, or import from photo gallery.
- **In-App Viewer** — View images (pinch-to-zoom) and PDFs without decrypting to permanent storage.
- **Share Files** — Decrypt on-the-fly and share via WhatsApp, email, or any app using the native OS share sheet.
- **Email Authentication** — Register and log in with email + password (stored locally, password hashed with bcrypt).
- **Neo-Pop UI** — High-contrast black background, electric yellow / blue / pink / green accent colours, hard drop-shadows, and bold typography — the Neo-pop design language.

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Local DB | Hive |
| Encryption | `encrypt` (AES-256) + `flutter_secure_storage` |
| Auth | `bcrypt` (password hashing) |
| File Picking | `file_picker`, `image_picker` |
| PDF Viewer | `flutter_pdfview` |
| Image Viewer | `photo_view` |
| Sharing | `share_plus` |
| State | `provider` |
| Animations | `flutter_animate` |

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants & default values
│   ├── theme/          # Neo-pop colour palette & ThemeData
│   └── utils/          # Dart extensions (file size, date, colour)
├── data/
│   ├── models/         # Hive-annotated data models (User, Profile, Folder, Document)
│   └── services/       # AuthService, EncryptionService, StorageService, FileService
├── features/
│   ├── auth/           # Login & Register screens
│   ├── home/           # Profiles grid + AddProfile sheet
│   ├── profile/        # Folders grid + AddFolder sheet
│   ├── folder/         # Document list + AddFile sheet
│   ├── document/       # In-app file viewer (image/PDF)
│   └── settings/       # Settings, change password, sign-out
├── providers/          # AuthProvider, VaultProvider (ChangeNotifier)
├── widgets/            # NeoButton, NeoCard, NeoTextField
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter 3.24+ ([install](https://docs.flutter.dev/get-started/install))
- Android Studio / Xcode for device targets

### Run

```bash
cd family_vault
flutter pub get
flutter run          # connects to attached device / emulator
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

## Security Notes

- Files are encrypted before writing to disk using AES-256-CBC with a per-installation random key.
- The encryption key lives exclusively in the Android Keystore / iOS Secure Enclave via `flutter_secure_storage`.
- Temporary decrypted files for viewing are written to `Directory.systemTemp` and cleaned up after 10 minutes.
- Passwords are hashed with bcrypt (10 rounds) and stored in the local Hive database — never in plain text.
- No network requests are made; the app is fully offline.
