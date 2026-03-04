# I am Agent (Flutter)

Flutter-версия приложения I am Agent. Портировано с React Native.

## Требования

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.0+
- Dart 3.0+

## Первоначальная настройка

В корне проекта выполните:

```bash
flutter create . --project-name i_am_agent_flutter
flutter pub get
```

## Запуск

```bash
flutter pub get
flutter run
```

## Что реализовано

- **Supabase** — подключение, аутентификация
- **Экраны**: Preloader, Login, Registration, Main (нижняя навигация)
- **Вкладки**: База недвижимости, Bookings, Calendar, Мой кабинет
- **Мой кабинет** → Контакты, Выход
- **База недвижимости**: список объектов, поиск, развёртка карточек
- **Добавление объекта** — модалка (тип, название, код)
- **Карточка объекта** — детали, для резорта — список домов
- **Добавление домика в резорт** — модалка (название, внутренний код)
- **Навигация**: возврат к резорту при «Назад» из домика
- **Локализация** — en, th, ru
- **Логотип** — как в RN-версии

## Структура

- `lib/config/` — Supabase URL, ключи
- `lib/services/` — auth, supabase, properties
- `lib/models/` — Property
- `lib/providers/` — LanguageProvider
- `lib/screens/` — экраны приложения
- `lib/widgets/` — Logo, BottomNav, AddPropertyModal, AddHouseInResortModal
- `lib/i18n/` — переводы
