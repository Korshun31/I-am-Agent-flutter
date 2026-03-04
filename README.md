# I am Agent (Flutter)

Flutter-версия приложения I am Agent. Полная копия React Native приложения на Flutter/Dart.

## Требования

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.0+
- Dart 3.0+

## Первоначальная настройка

Если проект создан без `flutter create`, выполните в корне проекта:

```bash
flutter create . --project-name i_am_agent_flutter
flutter pub get
```

## Запуск

```bash
flutter pub get
flutter run
```

## Структура (планируется)

- `lib/` — исходный код Dart
- `lib/screens/` — экраны (RealEstate, Contacts, Account, PropertyDetail и др.)
- `lib/services/` — Supabase, storage
- `lib/i18n/` — локализация (en, th, ru)
