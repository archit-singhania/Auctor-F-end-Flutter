// lib/core/services/auctor_api_service_stub.dart
// Stub for non-web platforms. The kIsWeb guard in auctor_api_service.dart
// ensures this is never actually called on native — but the compiler needs
// a matching symbol so the conditional import resolves.
import 'dart:typed_data';

Future<String> uploadPdfXhr({
  required String url,
  required Uint8List pdfBytes,
  required String fileName,
}) {
  throw UnsupportedError('uploadPdfXhr is only available on Flutter Web');
}
