// Conditional export so tests/desktop/mobile build without web-only libs.
export 'analytics_stub.dart' if (dart.library.html) 'analytics_web.dart';
