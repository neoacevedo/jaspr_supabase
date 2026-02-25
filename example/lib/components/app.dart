import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_supabase/jaspr_supabase.dart';

import '../pages/account_page.dart';
import '../pages/login_page.dart';

class App extends StatefulComponent {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SupabaseAuthMixin<App> {
  bool _initialized = false;

  @override
  void onAuthStateChange(event, session) {
    if (!_initialized) {
      if (event == AuthChangeEvent.initialSession) {
        setState(() {
          _initialized = true;
        });
      }
    } else {
      setState(() {});
    }
  }

  @override
  Component build(BuildContext context) {
    if (!_initialized) {
      return div([Component.text('Loading session...')]);
    }

    final session = Supabase.instance.client.auth.currentSession;

    return Router(
      routes: [
        Route(path: '/', title: 'Account', builder: (context, state) => AccountPage(), redirect: (context, state) => session == null ? '/login' : null),
        Route(path: '/login', title: 'Login', builder: (context, state) => LoginPage(), redirect: (context, state) => session != null ? '/' : null),
      ],
    );
  }
}
