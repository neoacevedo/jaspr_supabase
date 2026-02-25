# jaspr_supabase

A [Jaspr](https://github.com/schultek/jaspr) package for [Supabase](https://supabase.com), replicating the experience of `supabase_flutter`.

## Installation

Add `jaspr_supabase` to your `pubspec.yaml`:

```yaml
dependencies:
  jaspr_supabase: 26.2.19
```

## Architecture: Pure Single Page Application (SPA)

> [!IMPORTANT]  
> As of version `26.2.24`, `jaspr_supabase` is designed **strictly for Client-Side Single Page Applications (SPA)**. 
> 
> All server-side `Context` and `Cookie` logic has been completely removed to prevent critical race conditions and cross-user data bleeding when deployed on server environments. Session persistence relies natively on `window.localStorage` directly in the user's browser, matching the exact behavior of `supabase_flutter`.

## Usage

### Initialization

Initialize Supabase in your `main()` function. Since the process involves reading from the browser's persistent storage, it will automatically attempt to recover the session in the background:

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

### Routing & Auth State Management (Example)

To prevent your router from redirecting an already-logged-in user to the login page on a hard refresh (F5), you must wait for the `AuthChangeEvent.initialSession` event to fire before mounting the `<Router>`. 

Use the `SupabaseAuth` mixin in your root component:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_supabase/jaspr_supabase.dart';
import 'package:supabase/supabase.dart';

class App extends StatefulComponent {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SupabaseAuth<App> {
  bool _initialized = false;

  @override
  void onAuthStateChange(AuthChangeEvent event, Session? session) {
    // When the app boots, jaspr_supabase will read localStorage and fire this event.
    // If there is a valid token, 'session' will be populated.
    if (!_initialized) {
      if (event == AuthChangeEvent.initialSession) {
        setState(() {
          _initialized = true;
        });
      }
    } else {
      // Re-build the tree on subsequent sign-in/sign-out events
      setState(() {});
    }
  }

  @override
  Component build(BuildContext context) {
    if (!_initialized) {
      return div([text('Loading session...')]);
    }

    final session = Supabase.instance.client.auth.currentSession;

    return Router(
      routes: [
        Route(
          path: '/',
          builder: (context, state) => DashboardPage(),
          redirect: (context, state) => session == null ? '/login' : null,
        ),
        Route(
          path: '/login',
          builder: (context, state) => LoginPage(),
          redirect: (context, state) => session != null ? '/' : null,
        ),
      ],
    );
  }
}
```

### Accessing the Client

Access the global `SupabaseClient` instance anywhere:

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