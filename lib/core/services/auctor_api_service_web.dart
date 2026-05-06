// lib/core/services/auctor_api_service_web.dart
// Used on Flutter Web only. Performs a multipart upload using dart:html
// XMLHttpRequest, which correctly handles CORS preflight for multipart/form-data.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

Future<String> uploadPdfXhr({
  required String url,
  required Uint8List pdfBytes,
  required String fileName,
}) async {
  final completer = Completer<String>();

  final formData = html.FormData();
  final blob = html.Blob([pdfBytes], 'application/pdf');
  formData.appendBlob('file', blob, fileName);

  final xhr = html.HttpRequest();
  xhr.open('POST', url);
  xhr.setRequestHeader('Accept', 'application/json');
  // Do NOT set Content-Type — the browser sets multipart/form-data + boundary

  xhr.onLoad.listen((_) {
    if (xhr.status == 200) {
      completer.complete(xhr.responseText ?? '');
    } else {
      completer.completeError(
        Exception('CV parse failed (${xhr.status}): ${xhr.responseText}'),
      );
    }
  });

  xhr.onError.listen((_) {
    completer.completeError(
      Exception(
        'Network error uploading CV. '
        'Check that the Railway backend is running and CORS allows '
        'https://auctor-flutter-init.vercel.app',
      ),
    );
  });

  xhr.send(formData);

  return completer.future.timeout(
    const Duration(seconds: 90),
    onTimeout: () => throw Exception('CV upload timed out after 90 seconds'),
  );
}
