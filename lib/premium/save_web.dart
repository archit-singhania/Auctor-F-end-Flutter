import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Browser downloads use a local Blob; the private bearer token stays in HTTP.
Future<void> saveReport(String name, Uint8List bytes) async {
  final mime = name.endsWith('.pdf') ? 'application/pdf' : 'application/json';
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();
  // Give the browser time to start the download before releasing its bytes.
  Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
}
