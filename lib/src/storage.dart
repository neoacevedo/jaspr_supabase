import 'package:jaspr/server.dart';
import 'package:universal_web/web.dart';

/// Storage interface for storing authentication data.
abstract class Storage {
  /// Check if there is a persisted session.
  Future<bool> hasAccessToken();

  /// Get the access token from the current persisted session.
  Future<String?> accessToken();

  /// Remove the current persisted session.
  Future<void> removePersistedSession();

  /// Persist a session in the device.
  Future<void> persistSession(String persistSessionString);
}

/// Storage implementation using cookies for server-side persistence.
class SharedStorage implements Storage {
  SharedStorage({this.context, this.expires, this.secure = true, this.path = '/', this.domain});

  final BuildContext? context;
  final Duration? expires;
  final bool secure;
  final String path;
  final String? domain;

  static const _useWebLocalStorage = kIsWeb && bool.fromEnvironment('dart.library.js_interop');

  @override
  Future<bool> hasAccessToken() async {
    return _useWebLocalStorage ? window.localStorage.getItem('access_token') != null : context?.cookies['access_token'] != null;
  }

  @override
  Future<String?> accessToken() async {
    return _useWebLocalStorage ? window.localStorage.getItem('access_token') : context?.cookies['access_token'];
  }

  @override
  Future<void> removePersistedSession() async {
    context?.setCookie('access_token', '', expires: DateTime.now().subtract(const Duration(days: -1000)), path: path, secure: secure, domain: domain);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    context?.setCookie(
      'access_token',
      persistSessionString,
      expires: DateTime.now().subtract(expires ?? const Duration(days: 1)),
      path: path,
      secure: secure,
      domain: domain,
    );
  }
}

class SharedPreferencesLocalStorage {
  String? getItem({required String key}) {
    return window.localStorage.getItem(key);
  }

  void removeItem({required String key}) {
    window.localStorage.removeItem(key);
  }

  void setItem({required String key, required String value}) {
    window.localStorage.setItem(key, value);
  }
}
