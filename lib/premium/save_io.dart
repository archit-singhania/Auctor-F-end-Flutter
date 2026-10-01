import 'dart:io';
import 'dart:typed_data';

Future<void> completeSave(String? path, Uint8List bytes) async {
  // Mobile platform pickers write the bytes themselves; desktop returns a path.
  if (path != null &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await File(path).writeAsBytes(bytes, flush: true);
  }
}
