import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> saveReport(String name, Uint8List bytes) async {
  final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Auctor report',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: [name.split('.').last],
      bytes: desktop ? null : bytes);
  // Mobile pickers write the bytes; desktop pickers return the chosen path.
  if (path != null && desktop) {
    await File(path).writeAsBytes(bytes, flush: true);
  }
}
