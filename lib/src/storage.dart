import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/server.dart' if (dart.library.js_util) 'context_extensions.dart';
import 'package:supabase/supabase.dart';
import 'package:universal_web/web.dart';

/// Storage interface for storing authentication data.
abstract class Storage {
  const Storage();

  /// Check if there is a persisted session.
  Future<bool> hasAccessToken();

  /// Get the access token from the current persisted session.
  Future<String?> accessToken();

  /// Remove the current persisted session.
  Future<void> removePersistedSession();

  /// Persist a session in the device.
  Future<void> persistSession(String persistSessionString);
}

/// A [LocalStorage] implementation that does nothing. Use this to
/// disable persistence.
class EmptyLocalStorage extends Storage {
  /// Creates a [LocalStorage] instance that disables persistence
  const EmptyLocalStorage();

  @override
  Future<bool> hasAccessToken() => Future.value(false);

  @override
  Future<String?> accessToken() => Future.value();

  @override
  Future<void> removePersistedSession() async {}

  @override
  Future<void> persistSession(persistSessionString) async {}
}

/// Storage implementation using localStorage for client-side persistence.
class SharedPreferencesStorage extends GotrueAsyncStorage implements Storage {
  SharedPreferencesStorage(
    this.persistSessionKey, {
    this.context,
    this.expires,
    this.secure = true,
    this.path = '/',
    this.domain,
  });

  final String persistSessionKey;

  // These are kept for constructor backward compatibility but are unused in SPA mode
  final BuildContext? context;
  final Duration? expires;
  final bool secure;
  final String path;
  final String? domain;

  static const _useWebLocalStorage = kIsWeb && bool.fromEnvironment('dart.library.js_interop');

  @override
  Future<bool> hasAccessToken() async {
    if (!_useWebLocalStorage) return false;
    return window.localStorage.getItem(persistSessionKey) != null;
  }

  @override
  Future<String?> accessToken() async {
    if (!_useWebLocalStorage) return null;
    return window.localStorage.getItem(persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    if (_useWebLocalStorage) {
      window.localStorage.removeItem(persistSessionKey);
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    if (_useWebLocalStorage) {
      window.localStorage.setItem(persistSessionKey, persistSessionString);
    }
  }

  @override
  Future<String?> getItem({required String key}) async {
    return accessToken();
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    await persistSession(value);
  }

  @override
  Future<void> removeItem({required String key}) async {
    await removePersistedSession();
  }
}

/// local storage to store pkce flow code verifier.
class SharedPreferencesGotrueAsyncStorage extends GotrueAsyncStorage {
  SharedPreferencesGotrueAsyncStorage() {
    _initialize();
  }

  final Completer<void> _initializationCompleter = Completer();

  Future<void> _initialize() async {
    _initializationCompleter.complete();
  }

  @override
  Future<String?> getItem({required String key}) async {
    return window.localStorage.getItem(key);
  }

  @override
  Future<void> removeItem({required String key}) async {
    window.localStorage.removeItem(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    window.localStorage.setItem(key, value);
  }
}
