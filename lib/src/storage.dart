import 'dart:async';

import 'package:jaspr/server.dart';
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

/// Storage implementation using cookies for server-side persistence.
class SharedPreferencesStorage implements Storage {
  SharedPreferencesStorage(
    this.persistSessionKey, {
    this.context,
    this.expires,
    this.secure = true,
    this.path = '/',
    this.domain,
  });

  final String persistSessionKey;
  final BuildContext? context;
  final Duration? expires;
  final bool secure;
  final String path;
  final String? domain;

  static const _useWebLocalStorage = kIsWeb && bool.fromEnvironment('dart.library.js_interop');

  @override
  Future<bool> hasAccessToken() async {
    return _useWebLocalStorage
        ? window.localStorage.getItem(persistSessionKey) != null
        : context?.cookies[persistSessionKey] != null;
  }

  @override
  Future<String?> accessToken() async {
    return _useWebLocalStorage ? window.localStorage.getItem(persistSessionKey) : context?.cookies[persistSessionKey];
  }

  @override
  Future<void> removePersistedSession() async {
    context?.setCookie(
      persistSessionKey,
      '',
      expires: DateTime.now().subtract(const Duration(days: -1000)),
      path: path,
      secure: secure,
      domain: domain,
    );
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    context?.setCookie(
      persistSessionKey,
      persistSessionString,
      expires: DateTime.now().subtract(expires ?? const Duration(days: 1)),
      path: path,
      secure: secure,
      domain: domain,
    );
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
