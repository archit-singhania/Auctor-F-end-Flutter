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
  // Create blob with explicit MIME type — required for Railway to accept the file
  final blob = html.Blob([pdfBytes], 'application/pdf');
  formData.appendBlob('file', blob, fileName);

  final xhr = html.HttpRequest();
  xhr.open('POST', url, async: true);
  // Only set Accept — browser must set Content-Type with multipart boundary automatically
  xhr.setRequestHeader('Accept', 'application/json');
  // withCredentials must be false when server uses wildcard or explicit origin CORS
  xhr.withCredentials = false;

  xhr.onLoad.listen((_) {
    final status = xhr.status ?? 0;
    if (status == 200) {
      completer.complete(xhr.responseText ?? '');
    } else {
      // Surface the actual server error message to the UI
      final body = xhr.responseText ?? 'No response body';
      completer.completeError(
        Exception('CV parse failed ($status): $body'),
      );
    }
  });

  xhr.onError.listen((_) {
    // XHR onError fires when:
    // 1. Network is unreachable
    // 2. CORS preflight was rejected by the server
    // 3. Railway service is sleeping / cold-starting
    completer.completeError(
      Exception(
        'CORS or network error uploading CV.\n'
        'The Railway backend rejected the request from this origin.\n'
        'Make sure GITHUB_TOKEN and OPENAI_API_KEY are set in Railway, '
        'and that the service is running.',
      ),
    );
  });

  xhr.send(formData);

  return completer.future.timeout(
    const Duration(seconds: 120),
    onTimeout: () => throw Exception(
      'CV upload timed out (120s). Railway may be cold-starting — try again in 30 seconds.',
    ),
  );
}
