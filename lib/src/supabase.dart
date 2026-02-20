import 'package:jaspr_supabase/jaspr_supabase.dart';
import 'package:supabase/supabase.dart';
import 'dart:async';
import 'package:http/http.dart'; // For Client
import 'package:async/async.dart';
import 'auth.dart';

/// Supabase instance.
///
/// It must be initialized before used, otherwise an error is thrown.
///
/// ```dart
/// await Supabase.initialize(url: 'https://xyz.supabase.co', anonKey: 'public-anon-key');
/// final client = Supabase.instance.client;
/// ```
class Supabase {
  /// Gets the current Supabase instance.
  ///
  /// An [AssertionError] is thrown if supabase is not initialized.
  static Supabase get instance {
    assert(_instance._initialized, 'You must call the Supabase.initialize method before accessing the instance');
    return _instance;
  }

  static final Supabase _instance = Supabase._();

  Supabase._();

  late SupabaseClient _client;

  bool _initialized = false;

  // ignore: unused_field
  SupabaseAuth? _supabaseAuth;

  CancelableOperation<Session?>? _restoreSessionCancellableOperation;

  /// Initialize the Supabase instance.
  ///
  /// [url] and [anonKey] can be found on your Supabase dashboard.
  ///
  /// [authOptions], [realtimeClientOptions], [storageOptions] are optional configurations.
  ///
  /// [debug] enables debug logging.
  static Future<Supabase> initialize({
    required String url,
    required String anonKey,
    JasprAuthClientOptions authOptions = const JasprAuthClientOptions(),
    RealtimeClientOptions realtimeClientOptions = const RealtimeClientOptions(),
    StorageClientOptions storageOptions = const StorageClientOptions(),
    PostgrestClientOptions postgrestOptions = const PostgrestClientOptions(),
    Map<String, String>? headers,
    Client? httpClient,
    Future<String?> Function()? accessToken,
    bool? debug,
  }) async {
    if (_instance._initialized) {
      // Supabase instance is already initialized
      return _instance;
    }

    if (authOptions.pkceAsyncStorage == null) {
      authOptions = authOptions.copyWith(pkceAsyncStorage: SharedPreferencesGotrueAsyncStorage());
    }

    if (authOptions.storage == null) {
      authOptions = authOptions.copyWith(storage: SharedPreferencesStorage("sb-${Uri.parse(url).host.split(".").first}-auth-token"));
    }

    if (accessToken == null) {
      final supabaseAuth = SupabaseAuth();
      _instance._supabaseAuth = supabaseAuth;
      await supabaseAuth.initialize(options: authOptions);

      // Wrap `recoverSession()` in a `CancelableOperation` so that it can be canceled in dispose
      // if still in progress
      _instance._restoreSessionCancellableOperation = CancelableOperation.fromFuture(supabaseAuth.recoverSession());
    }

    _instance._init(
      url,
      anonKey,
      authOptions: authOptions,
      realtimeClientOptions: realtimeClientOptions,
      storageOptions: storageOptions,
      postgrestOptions: postgrestOptions,
      headers: headers,
      httpClient: httpClient,
    );

    if (accessToken == null) {
      final supabaseAuth = SupabaseAuth();
      _instance._supabaseAuth = supabaseAuth;
      await supabaseAuth.initialize(options: authOptions);

      // Wrap `recoverSession()` in a `CancelableOperation` so that it can be canceled in dispose
      // if still in progress
      _instance._restoreSessionCancellableOperation = CancelableOperation.fromFuture(supabaseAuth.recoverSession());
    }

    return _instance;
  }

  void _init(
    String url,
    String anonKey, {
    AuthClientOptions? authOptions,
    RealtimeClientOptions? realtimeClientOptions,
    StorageClientOptions? storageOptions,
    PostgrestClientOptions? postgrestOptions,
    Map<String, String>? headers,
    Client? httpClient,
  }) {
    _client = SupabaseClient(
      url,
      anonKey,
      authOptions: authOptions ?? const AuthClientOptions(),
      realtimeClientOptions: realtimeClientOptions ?? const RealtimeClientOptions(),
      storageOptions: storageOptions ?? const StorageClientOptions(),
      postgrestOptions: postgrestOptions ?? const PostgrestClientOptions(),
      headers: headers,
      httpClient: httpClient,
    );
    _initialized = true;
  }

  /// The [SupabaseClient] instance.
  SupabaseClient get client => _client;

  /// Dispose the instance to free up resources.
  Future<void> dispose() async {
    await _restoreSessionCancellableOperation?.cancel();
    _client.dispose();
    _initialized = false;
  }
}
