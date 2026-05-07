// lib/core/services/auctor_api_service_web.dart
//
// Flutter Web upload implementation using the standard http package.
// dart:html is intentionally NOT used here — it is deprecated in Flutter 3.x
// and causes dart2js compilation errors.
//
// The CORS issue that previously required raw XHR is now solved at the backend
// level (PermissiveCORSMiddleware in main.py echoes the exact Origin back),
// so http.MultipartRequest works correctly on web.

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<String> uploadPdfXhr({
  required String url,
  required Uint8List pdfBytes,
  required String fileName,
}) async {
  final uri = Uri.parse(url);

  final request = http.MultipartRequest('POST', uri)
    ..headers['Accept'] = 'application/json';
  // Do NOT manually set Content-Type — http sets multipart/form-data + boundary
  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      pdfBytes,
      filename: fileName,
      contentType: MediaType('application', 'pdf'),
    ),
  );

  final streamed = await request.send().timeout(
    const Duration(seconds: 120),
    onTimeout: () => throw Exception(
      'Request timed out (120s). Railway may be cold-starting — wait 30 seconds and try again.',
    ),
  );

  final body = await http.Response.fromStream(streamed);

  if (body.statusCode == 200) return body.body;

  // Surface the exact server error to the UI
  String detail = 'CV parse failed (${body.statusCode})';
  try {
    // Try to extract FastAPI's {"detail": "..."} message
    final idx = body.body.indexOf('"detail"');
    if (idx != -1) {
      final start = body.body.indexOf('"', idx + 9) + 1;
      final end = body.body.indexOf('"', start);
      if (start > 0 && end > start) detail = body.body.substring(start, end);
    }
  } catch (_) {}
  throw Exception(detail);
}
