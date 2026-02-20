import 'package:jaspr_supabase/jaspr_supabase.dart';
import 'package:supabase/supabase.dart';

class JasprAuthClientOptions extends AuthClientOptions {
  final Storage? storage;

  /// If true, the client will start the deep link observer and obtain sessions
  /// when a valid URI is detected.
  final bool detectSessionInUri;

  const JasprAuthClientOptions({
    super.authFlowType,
    super.autoRefreshToken,
    super.pkceAsyncStorage,
    this.storage,
    this.detectSessionInUri = true,
  });

  JasprAuthClientOptions copyWith({
    AuthFlowType? authFlowType,
    bool? autoRefreshToken,
    Storage? storage,
    GotrueAsyncStorage? pkceAsyncStorage,
    bool? detectSessionInUri,
  }) {
    return JasprAuthClientOptions(
      authFlowType: authFlowType ?? this.authFlowType,
      autoRefreshToken: autoRefreshToken ?? this.autoRefreshToken,
      storage: storage ?? this.storage,
      pkceAsyncStorage: pkceAsyncStorage ?? this.pkceAsyncStorage,
      detectSessionInUri: detectSessionInUri ?? this.detectSessionInUri,
    );
  }
}
