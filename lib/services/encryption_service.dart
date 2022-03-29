import 'dart:io';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

class EncryptionService {
  String? encFilePath;
  String? decFilePath;

  String getFilePath() {
    final file = OpenFilePicker();
    final result = file.getFile();

    if (result != null) {
      return result.path;
    }
    return "Path not found";
  }

  List<String> withoutDotAes(String path) {
    int start = 0;
    int firstDot = 0;
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == "\\") {
        start = i;
        break;
      }
    }
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == ".") {
        firstDot = i;
        break;
      }
    }
    String pathWithoutDotAes = path.substring(0, start);
    String fileName = path.substring(start, path.length);
    String fileNameWithoutDotAes = path.substring(start, firstDot);

    return <String>[pathWithoutDotAes, fileNameWithoutDotAes, fileName];
  }

  void aesEncrypt(
      String filePath, String password, String destinationFilePath) {
    var crypt = AesCrypt();
    crypt.setPassword(password);

    try {
      encFilePath = crypt.encryptFileSync(filePath, destinationFilePath);
    } on AesCryptException catch (e) {
      if (e.type == AesCryptExceptionType.destFileExists) {
        print(e.message);
      }
      return;
    }
  }

  void aesDecrypt(String filePath, String password, String destinationFilePath) {
    String srcFilePath = filePath;

    var crypt = AesCrypt();
    crypt.setPassword(password);

    try {
      decFilePath =
          crypt.decryptFileSync(srcFilePath, destinationFilePath);
    } on AesCryptException catch (e) {
      if (e.type == AesCryptExceptionType.destFileExists) {
        print(e.message);
      }
      return;
    }
  }
}
