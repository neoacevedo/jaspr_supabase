import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_supabase/jaspr_supabase.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(url: 'https://xyz.supabase.co', anonKey: 'public-anon-key');

  runApp(App());
}

class App extends StatefulComponent {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SupabaseAuthMixin<App> {
  String _authStatus = 'Not logged in';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  @override
  void onAuthStateChange(event, session) {
    setState(() {
      _authStatus = 'Auth Event: $event, User: ${session?.user.email ?? 'None'}';
    });
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: _email, password: _password);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Component build(BuildContext context) {
    return div([
      h1([Component.text('Jaspr Supabase Example')]),
      p([Component.text('Status: $_authStatus')]),

      form(
        events: {
          'submit': (e) {
            (e as dynamic).preventDefault();
            _signIn();
          },
        },
        [
          div([
            label([Component.text('Email: ')]),
            input(type: InputType.email, onInput: (value) => _email = value.toString(), attributes: {'required': 'true'}),
          ]),
          div([
            label([Component.text('Password: ')]),
            input(type: InputType.password, onInput: (value) => _password = value.toString(), attributes: {'required': 'true'}),
          ]),
          button(attributes: {'type': 'submit'}, disabled: _isLoading, [Component.text(_isLoading ? 'Signing In...' : 'Sign In')]),
        ],
      ),
    ]);
  }
}
