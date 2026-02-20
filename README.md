# jaspr_supabase

A [Jaspr](https://github.com/schultek/jaspr) package for [Supabase](https://supabase.com), replicating the experience of `supabase_flutter`.

## Installation

Add `jaspr_supabase` to your `pubspec.yaml`:

```yaml
dependencies:
  jaspr_supabase: 26.2.19
```

## Usage

### Initialization

Initialize Supabase in your `main()` function:

```dart
import 'package:jaspr_supabase/jaspr_supabase.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://xyz.supabase.co',
    anonKey: 'public-anon-key',
  );
  
  runApp(App());
}
```

### Auth State Management

Use the `SupabaseAuth` mixin in your components to listen to auth state changes:

```dart
class App extends StatefulComponent {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SupabaseAuth<App> {
  @override
  void onAuthStateChange(event, session) {
    // Handle auth state change
    print('Auth event: $event');
  }

  @override
  Component build(BuildContext context) {
    // ...
  }
}
```

### Accessing Client

Access the `SupabaseClient` instance anywhere:

```dart
final client = Supabase.instance.client;
```

## Donations

If this project is useful to you, consider making a donation:

<div align="center">

| Ko-fi                                                  | Litecoin                                                     |
| ------------------------------------------------------ | ------------------------------------------------------------ |
| [![Ko-fi QR](ko-fi.png)](https://ko-fi.com/neoacevedo) | <img title="" src="Litecoin.jpg" alt="Litecoin" width="399"> |
| ☕ [Ko-fi](https://ko-fi.com/neoacevedo)                | Ł Donaciones Litecoin                                        |

</div>

## License

This project is licensed under the GPL-3.0+ License - see the [LICENSE](LICENSE) file for more details.