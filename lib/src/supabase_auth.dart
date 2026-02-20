import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:supabase/supabase.dart';

import 'supabase.dart';

/// Mixin to manage Supabase Auth state in Jaspr components.
mixin SupabaseAuthMixin<T extends StatefulComponent> on State<T> {
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (_mounted) {
        onAuthStateChange(data.event, data.session);
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _mounted = false;
    super.dispose();
  }

  /// Callback when auth state changes.
  void onAuthStateChange(AuthChangeEvent event, Session? session);
}
