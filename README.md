# hr_app

MOC HR-App project.

## Getting Started
📝 Notes for Developers

Note:

For new developers, start by reading the Authentication feature code first.
This Flutter app uses Riverpod for state management.
This project uses code generation - many files are for reference only (do not edit by hand).
Example: "auth_repository.dart" has generated file "auth_repository.g.dart".

To generate code:
dart run build_runner build --delete-conflicting-outputs

To generate translations (l10n):
dart run easy_localization:generate -S assets/l10n -f keys -O lib/l10n -o locale_keys.g.dart

To generate splash screen:
flutter pub run flutter_native_splash:create --path=splash.yaml

To build APK:
flutter build apk --build-name=1.0 --build-number=1

Built APK location:
yourAppFolder/build/app/outputs/apk/release/app-release.apk

Important notes:

"Employees" = list of Employee() objects
"Employee" = single Employee object
PATCH requests use "application/merge-patch+json" Content-Type
Other methods (GET/POST/PUT/DELETE) use "application/ld+json"
App architecture:

Feature-based organization
Three layers:
Data layer
Model
Presentation (UI + state controllers)
State controllers handle loading/error/data states
Contains reusable custom widgets.# eps-client
