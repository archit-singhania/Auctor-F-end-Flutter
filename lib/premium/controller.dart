import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PlatformApi {
  static const base = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8000');
  final http.Client client;
  String? token;
  PlatformApi({http.Client? client}) : client = client ?? http.Client();
  Future<dynamic> call(String path,
      {String method = 'GET', Object? data, bool authenticated = true}) async {
    final headers = {
      'Accept': 'application/json',
      if (authenticated && token != null) 'Authorization': 'Bearer $token',
      if (data != null) 'Content-Type': 'application/json'
    };
    final req = http.Request(method, Uri.parse('$base/api$path'))
      ..headers.addAll(headers);
    if (data != null) req.body = jsonEncode(data);
    final response = await http.Response.fromStream(
        await client.send(req).timeout(const Duration(seconds: 30)));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final detail = jsonDecode(response.body)['detail'];
        message = detail is String ? detail : 'Please check the form fields';
      } catch (_) {}
      throw ApiFailure(message, response.statusCode);
    }
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  Future<dynamic> upload(String path, Uint8List bytes, String name,
      {String mime = 'application/pdf'}) async {
    final req = http.MultipartRequest('POST', Uri.parse('$base/api$path'));
    req.headers.addAll(
        {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    req.files.add(http.MultipartFile.fromBytes('file', bytes,
        filename: name, contentType: MediaType.parse(mime)));
    final res = await http.Response.fromStream(
        await client.send(req).timeout(const Duration(seconds: 45)));
    if (res.statusCode >= 400) {
      String message = 'Upload failed';
      try {
        message = jsonDecode(res.body)['detail'].toString();
      } catch (_) {}
      throw ApiFailure(message, res.statusCode);
    }
    return jsonDecode(res.body);
  }

  Future<Uint8List> bytes(String path) async {
    final res = await client.get(Uri.parse('$base/api$path'), headers: {
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw ApiFailure('Download failed (${res.statusCode})', res.statusCode);
    }
    return res.bodyBytes;
  }
}

class ApiFailure implements Exception {
  final String message;
  final int status;
  ApiFailure(this.message, this.status);
  @override
  String toString() => message;
}

class WorkspaceController extends ChangeNotifier {
  final PlatformApi api;
  final FlutterSecureStorage storage;
  Map<String, dynamic>? workspace;
  bool loading = true, busy = false;
  String? error;
  ThemeMode theme = ThemeMode.system;
  bool reducedMotion = false, reducedTransparency = false;
  int destination = 0;
  WorkspaceController({PlatformApi? api, FlutterSecureStorage? storage})
      : api = api ?? PlatformApi(),
        storage = storage ?? const FlutterSecureStorage();
  Map<String, dynamic> get profile =>
      Map<String, dynamic>.from(workspace?['profile'] ?? {});
  Map<String, dynamic> get cv => Map<String, dynamic>.from(workspace?['cv'] ??
      {'skills': [], 'projects': [], 'experience': [], 'profiles': {}});
  Map<String, dynamic> get score => Map<String, dynamic>.from(
      workspace?['score'] ?? {'total': 0, 'components': {}});
  List<Map<String, dynamic>> list(String key) =>
      (workspace?[key] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
  Future<void> initialize() async {
    try {
      api.token = await storage.read(key: 'auctor-session');
      if (api.token != null) await refresh();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void select(int value) {
    destination = value;
    error = null;
    notifyListeners();
  }

  void previewTheme(ThemeMode value) {
    theme = value;
    notifyListeners();
  }

  Future<void> authenticate(Map<String, dynamic> credentials,
      {bool register = false}) async {
    await run(() async {
      final result = await api.call(register ? '/auth/register' : '/auth/login',
          method: 'POST', data: credentials, authenticated: false);
      api.token = result['token'];
      await storage.write(key: 'auctor-session', value: api.token);
      await refresh();
    });
  }

  Future<void> refresh() async {
    try {
      workspace = Map<String, dynamic>.from(await api.call('/me'));
      final prefs = profile['preferences'] as Map? ?? {};
      theme = switch (prefs['theme']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system
      };
      reducedMotion = prefs['reduced_motion'] == true;
      reducedTransparency = prefs['reduced_transparency'] == true;
      error = null;
      notifyListeners();
    } on ApiFailure catch (e) {
      if (e.status == 401) {
        api.token = null;
        workspace = null;
        await storage.delete(key: 'auctor-session');
      }
      rethrow;
    }
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await run(() async {
      await api.call('/auth/logout', method: 'POST');
      await storage.delete(key: 'auctor-session');
      api.token = null;
      workspace = null;
      destination = 0;
    });
  }

  Future<void> mutate(String path, {String method = 'POST', Object? data}) =>
      run(() async {
        await api.call(path, method: method, data: data);
        await refresh();
      });
  Future<void> preferences(
      {ThemeMode? mode, bool? motion, bool? transparency}) async {
    await mutate('/me', method: 'PATCH', data: {
      'display_name': profile['display_name'],
      'bio': profile['bio'],
      'discoverable': profile['discoverable'],
      'preferences': {
        ...Map<String, dynamic>.from(profile['preferences'] ?? {}),
        'theme': (mode ?? theme).name,
        'reduced_motion': motion ?? reducedMotion,
        'reduced_transparency': transparency ?? reducedTransparency
      }
    });
  }
}
