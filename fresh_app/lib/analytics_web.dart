// Web implementation that calls the global `plausible` function if present.

import 'dart:js_util' as js_util;

class Analytics {
  static void event(String name, {Map<String, dynamic>? props}) {
    try {
      final plausible = js_util.getProperty(js_util.globalThis, 'plausible');
      if (plausible != null) {
        if (props != null && props.isNotEmpty) {
          js_util.callMethod(js_util.globalThis, 'plausible', [
            name,
            {'props': props},
          ]);
        } else {
          js_util.callMethod(js_util.globalThis, 'plausible', [name]);
        }
      }
    } catch (_) {
      // Best-effort only.
    }
  }
}
