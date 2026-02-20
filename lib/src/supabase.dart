import 'package:supabase/supabase.dart';
import 'dart:async';
import 'package:http/http.dart'; // For Client

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
    AuthClientOptions authOptions = const AuthClientOptions(),
    RealtimeClientOptions realtimeClientOptions = const RealtimeClientOptions(),
    StorageClientOptions storageOptions = const StorageClientOptions(),
    PostgrestClientOptions postgrestOptions = const PostgrestClientOptions(),
    Map<String, String>? headers,
    Client? httpClient,
    bool? debug,
  }) async {
    if (_instance._initialized) {
      // Supabase instance is already initialized
      return _instance;
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
  void dispose() {
    _client.dispose();
    _initialized = false;
  }
}
