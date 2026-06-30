import 'package:web/web.dart' as web;

String? readStoryFromUrl() {
  final params = Uri.parse(web.window.location.href).queryParameters;
  final name = params['story'];
  return (name == null || name.isEmpty) ? null : name;
}

void writeStoryToUrl(String? name) {
  final loc = web.window.location;
  final base = Uri.parse(loc.href);
  final next = name == null || name.isEmpty
      ? base.replace(queryParameters: {})
      : base.replace(queryParameters: {...base.queryParameters, 'story': name});
  if (next.toString() == loc.href) return;
  web.window.history.replaceState(null, '', next.toString());
}
