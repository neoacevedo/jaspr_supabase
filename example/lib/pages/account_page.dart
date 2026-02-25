import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_supabase/jaspr_supabase.dart';

class AccountPage extends StatefulComponent {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _username;
  String? _website;
  String? _avatarUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client.from('profiles').select().eq('id', user.id).single();

        setState(() {
          _username = data['username'] as String?;
          _website = data['website'] as String?;
          _avatarUrl = data['avatar_url'] as String?;
        });
      }
    } catch (error) {
      print('Error fetching profile: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final updates = {
          'id': user.id,
          'username': _username,
          'website': _website,
          'avatar_url': _avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        };
        await Supabase.instance.client.from('profiles').upsert(updates);
        print('Profile updated!');
      }
    } catch (error) {
      print('Error updating profile: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  @override
  Component build(BuildContext context) {
    if (_loading) {
      return div([Component.text('Loading profile...')]);
    }

    return div(classes: 'account-container', [
      h1([Component.text('Profile')]),
      div([
        label([Component.text('Email: ')]),
        Component.text(Supabase.instance.client.auth.currentUser?.email ?? ''),
      ]),
      div([
        label([Component.text('Username: ')]),
        input(
          type: InputType.text,
          value: _username ?? '',
          onInput: (value) => _username = value as String,
        ),
      ]),
      div([
        label([Component.text('Website: ')]),
        input(
          type: InputType.url,
          value: _website ?? '',
          onInput: (value) => _website = value as String,
        ),
      ]),
      div([
        button([Component.text('Update')], onClick: _updateProfile),
        button([Component.text('Sign Out')], onClick: _signOut),
      ]),
    ]);
  }
}
