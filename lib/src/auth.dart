import 'dart:async';
import 'dart:convert';
import 'package:supabase/supabase.dart';
import 'supabase.dart';
import 'storage.dart';

/// SupabaseAuth manages the authentication state of the Supabase instance.
class SupabaseAuth {
  SupabaseAuth();

  late Storage _storage;
  StreamSubscription<AuthState>? _authSubscription;

  /// Initialize the SupabaseAuth instance.
  Future<void> initialize({required AuthClientOptions options}) async {
    // We expect options to be JasprAuthClientOptions which has the storage property
    // We need to cast it or get it dynamically because the base class doesn't have it
    dynamic dynamicOptions = options;
    _storage = dynamicOptions.storage as Storage;

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        _onAuthStateChange(data.event, data.session);
      },
      onError: (error, _) {},
    );

    final hasPersistedSession = await _storage.hasAccessToken();
    var shouldEmitInitialSession = true;
    if (hasPersistedSession) {
      final persistedSession = await _storage.accessToken();
      if (persistedSession != null) {
        try {
          await Supabase.instance.client.auth.setInitialSession(persistedSession);
          shouldEmitInitialSession = false;
        } catch (error) {
          // Ignore
        }
      }
    }

    if (shouldEmitInitialSession) {
      // ignore: invalid_use_of_internal_member
      Supabase.instance.client.auth.notifyAllSubscribers(AuthChangeEvent.initialSession);
    }
  }

  /// Recover the session from storage.
  Future<Session?> recoverSession() async {
    try {
      final hasPersistedSession = await _storage.hasAccessToken();
      if (hasPersistedSession) {
        final persistedSession = await _storage.accessToken();
        if (persistedSession != null) {
          final response = await Supabase.instance.client.auth.recoverSession(persistedSession);
          return response.session;
        }
      }
    } catch (error) {
      // Ignore
    }
    return null;
  }

  void _onAuthStateChange(AuthChangeEvent event, Session? session) {
    if (session != null) {
      _storage.persistSession(jsonEncode(session.toJson()));
    } else if (event == AuthChangeEvent.signedOut) {
      _storage.removePersistedSession();
    }
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}
