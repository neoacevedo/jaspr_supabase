// coverage:ignore-file
import 'package:jaspr/jaspr.dart';

extension ContextCookies on BuildContext {
  Map<String, String> get cookies => {};
  void setCookie(String name, String value, {DateTime? expires, String? path, bool? secure, String? domain}) {}
}
