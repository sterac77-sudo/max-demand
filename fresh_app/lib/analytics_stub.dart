// Fallback (non-web) implementation: all methods are no-ops.

class Analytics {
  static void event(String name, {Map<String, dynamic>? props}) {
    // no-op
  }
}
