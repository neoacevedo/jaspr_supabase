import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_supabase/jaspr_supabase.dart';

class LoginPage extends StatefulComponent {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email,
        password: _password,
      );
    } catch (error) {
      print('Unexpected error: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onMagicLink() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _email,
        emailRedirectTo: 'http://localhost:8080/login',
      );
      print('Check your email for the magic link!');
    } catch (error) {
      print('Unexpected error: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'login-container', [
      h1([Component.text('Login')]),
      div([
        label([Component.text('Email: ')]),
        input(
          type: InputType.email,
          value: _email,
          onInput: (value) => _email = value as String,
        ),
      ]),
      div([
        label([Component.text('Password: ')]),
        input(
          type: InputType.password,
          value: _password,
          onInput: (value) => _password = value as String,
        ),
      ]),
      button(
        [Component.text(_isLoading ? 'Loading...' : 'Sign In')],
        onClick: _isLoading ? null : _signIn,
      ),
      button(
        [Component.text(_isLoading ? 'Loading...' : 'Send Magic Link')],
        onClick: _isLoading ? null : _onMagicLink,
      ),
    ]);
  }
}
