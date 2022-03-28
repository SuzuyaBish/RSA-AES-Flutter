import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypton/crypton.dart';
import 'package:path/path.dart' as Path;

import 'package:aes_app/controllers/count.dart';
import 'package:aes_app/controllers/requirments.dart';
import 'package:aes_app/services/encryption_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:file_picker/file_picker.dart';

class EncryptPage extends StatefulWidget {
  const EncryptPage({Key? key}) : super(key: key);

  @override
  State<EncryptPage> createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage> {
  final List<XFile> _list = [];
  Offset? offset;
  bool _dragging = false;
  bool _isChecked = false;
  String directory = "";
  bool _tempIsVisible = true;
  bool _isVisible = true;
  bool _isExpanded = false;
  String? _RSAEnabled;
  final values = ["No", "Yes"];
  String currentDirectory = Directory.current.path;
  String tempString = "";
  bool _useDefaultLocaiton = false;
  int count = 0;
  int actual = 0;

  TextEditingController passwordController = TextEditingController();
  TextEditingController saveController = TextEditingController();

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  RSAKeypair rsaKeypair = RSAKeypair.fromRandom();
  String pubKeyPath = "";
  String privKeyPath = "";
  String aesKeyPath = "";

  void pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      setState(() {
        saveController.text = currentDirectory;
      });
    } else {
      setState(() {
        directory = selectedDirectory.toString();
      });
      print(directory);
    }
  }

  String fileName(String path) {
    int start = 0;
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == "\\") {
        start = i;
        break;
      }
    }
    return path.substring(start);
  }

  _createFolder(String savePath, [String folderName = "EncryptedFiles"]) async {
    final path = Directory(savePath + "/" + folderName);

    if ((await path.exists())) {
      print("Path exists");
    } else {
      path.create();
    }
  }

  int findInsert(String path) {
    int start = 0;
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == "\\") {
        start = i;
        break;
      }
    }
    return start;
  }

  Future<String> findFolder(String path,
      [String folderName = "EncryptedFiles"]) async {
    var dir = Directory(path);
    String temp = "";
    String ret = "";
    int count = 0;
    var indexes = [];

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity.path.contains(folderName)) {
        temp = entity.path;
      }
    }

    for (int i = 0; i < temp.length; i++) {
      if (temp[i] == "\\") {
        indexes.add(i);
      }
    }
    return temp.substring(indexes[indexes.length - 1]);
  }

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    print(dir.path);
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path\\priv.txt');
  }

  Future<File> get _localFile2 async {
    final path = await _localPath;
    return File('$path\\pub.txt');
  }

  Future<File> get _localFile3 async {
    final path = await _localPath;
    return File('$path\\aes.txt');
  }

  Future<File> writeContent() async {
    final file = await _localFile;

    setState(() {
      privKeyPath = file.path;
    });

    return file.writeAsString(rsaKeypair.privateKey.toString());
  }

  Future<File> writeContent2() async {
    final file = await _localFile2;

    setState(() {
      pubKeyPath = file.path;
    });

    return file.writeAsString(rsaKeypair.publicKey.toString());
  }

  Future<File> writeContent3() async {
    final file = await _localFile3;
    String encrypted = rsaKeypair.publicKey.encrypt(passwordController.text);

    setState(() {
      aesKeyPath = file.path;
    });

    return file.writeAsString(encrypted);
  }

  Future<List<String>> listFiles(String path) async {
    var dir = Directory(path);
    List<String> files = [];

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (!entity.path.contains("EncryptedFiles")) {
        files.add(entity.path);
      }
    }
    return files;
  }

  int findInsertsKeys(String path) {
    int start = 0;
    int count = 0;
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == "\\") {
        count++;
      }
      if (count == 2) {
        start = i;
        break;
      }
    }
    return start;
  }

  int findInsertFilePath(String path) {
    int start = 0;
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == "\\") {
        start = i;
        break;
      }
    }
    return start;
  }

  @override
  void initState() {
    scrollController1;
    scrollController2;

    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    saveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EncryptionService es = EncryptionService();
    Requirments requirments = Get.put(Requirments());
    CountController cc = Get.put(CountController());
    //saveController.text = directory == "" ? currentDirectory : directory;
    if (saveController.text == "" && tempString == "" && directory == "") {
      saveController.text = currentDirectory;
    }
    if (saveController.text == "" && tempString != "" && directory == "") {
      saveController.text = tempString;
    }
    if (saveController.text == "" && tempString == "" && directory != "") {
      saveController.text = directory;
    }
    return _isVisible ? EncryptWidget(es) : EncryptSummary(requirments, es, cc);
    //return EncryptSummary(requirments, es, cc);
  }

  AnimatedOpacity EncryptSummary(
      Requirments requirments, EncryptionService es, CountController cc) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(seconds: 1),
      child: ScaffoldPage.withPadding(
        padding: const EdgeInsets.all(20),
        content: SafeArea(
          child: Row(
            children: [
              Column(
                children: [
                  if (_isExpanded) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFf808080).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Files to encrypt ...",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFf808080).withOpacity(0.35),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Files to encrypt",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  controller: scrollController1,
                                  itemCount: _list.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Text(
                                      _list[index].path,
                                      style: const TextStyle(
                                        color: Color(0xFFf06b76),
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFf808080).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Settings",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: _isExpanded
                                        ? const Icon(
                                            FluentIcons.collapse_content,
                                            color: Color(0xFFf06b76),
                                          )
                                        : const Icon(
                                            FluentIcons.pop_expand,
                                            color: Color(0xFFf06b76),
                                          ),
                                    onPressed: () {
                                      if (_isExpanded) {
                                        setState(() {
                                          _isExpanded = false;
                                        });
                                      } else {
                                        setState(() {
                                          _isExpanded = true;
                                        });
                                      }
                                      print(saveController.text);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Divider(
                                style: DividerThemeData(
                                  thickness: 1,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(.40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Text(
                                    "RSA Enabled",
                                    style: TextStyle(
                                      color: Color(0xFFf06b76),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 40,
                                    width: 70,
                                    child: Combobox(
                                      placeholder: const Text("No"),
                                      isExpanded: false,
                                      items: values
                                          .map((e) => ComboboxItem<String>(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      value: _RSAEnabled,
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() {
                                            _RSAEnabled = v.toString();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Tooltip(
                                    message:
                                        "Higher standard of encryption, read FAQ for more details.",
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFf808080),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Text("?"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Divider(
                                style: DividerThemeData(
                                  thickness: 1,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(.40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextBox(
                                toolbarOptions: const ToolbarOptions(
                                  copy: true,
                                  cut: true,
                                  paste: true,
                                  selectAll: true,
                                ),
                                controller: passwordController,
                                obscureText: true,
                                obscuringCharacter: "*",
                                header: "Password:",
                                placeholder: "Type your password here",
                                headerStyle: const TextStyle(
                                  color: Color(0xFFf06b76),
                                ),
                                onChanged: (s) {
                                  setState(() {
                                    passwordController.text = s;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              Divider(
                                style: DividerThemeData(
                                  thickness: 1,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(.40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextBox(
                                toolbarOptions: const ToolbarOptions(
                                  copy: true,
                                  cut: true,
                                  paste: true,
                                  selectAll: true,
                                ),
                                controller: saveController,
                                header: "Save location:",
                                headerStyle: const TextStyle(
                                  color: Color(0xFFf06b76),
                                ),
                                style: const TextStyle(fontSize: 12),
                                suffix: IconButton(
                                  onPressed: () {
                                    pickFolder();
                                    setState(() {
                                      saveController.text = directory;
                                    });
                                    print(saveController.text);
                                  },
                                  icon: const Icon(
                                    FluentIcons.open_folder_horizontal,
                                    color: Color(0xFFf06b76),
                                  ),
                                ),
                                onSubmitted: (v) {
                                  setState(() {
                                    tempString = v;
                                  });
                                  saveController.text = tempString;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFf808080).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Requirements: ",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "RSA enabled: ",
                              style: TextStyle(
                                color: _RSAEnabled == "Yes"
                                    ? Colors.white
                                    : const Color(0xFFD3D3D3).withOpacity(.80),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              _RSAEnabled == "Yes"
                                  ? FluentIcons.accept
                                  : FluentIcons.status_circle_error_x,
                              color: _RSAEnabled == "Yes"
                                  ? const Color(0xFF66FF00)
                                  : const Color(0xFFD3D3D3).withOpacity(.80),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Password: ",
                              style: TextStyle(
                                color: passwordController.text.isEmpty
                                    ? const Color(0xFFD3D3D3).withOpacity(.80)
                                    : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              passwordController.text.isEmpty
                                  ? FluentIcons.status_circle_error_x
                                  : FluentIcons.accept,
                              color: passwordController.text.isEmpty
                                  ? const Color(0xFFf06b76)
                                  : const Color(0xFF66FF00),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Save location: ",
                              style: TextStyle(
                                color: _useDefaultLocaiton == false &&
                                        directory == ""
                                    ? const Color(0xFFD3D3D3).withOpacity(.80)
                                    : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              _useDefaultLocaiton == false && directory == ""
                                  ? FluentIcons.status_circle_error_x
                                  : FluentIcons.accept,
                              color: _useDefaultLocaiton == false &&
                                      directory == ""
                                  ? const Color(0xFFf06b76)
                                  : const Color(0xFF66FF00),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _useDefaultLocaiton = true;
                                  saveController.text = currentDirectory;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF272727),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  "Use default",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFf06b76),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (passwordController.text.isNotEmpty &&
                                      saveController.text.isNotEmpty) {
                                    if (_RSAEnabled == "Yes") {
                                      _createFolder(saveController.text);

                                      String folderName =
                                          await findFolder(saveController.text);

                                      for (final i in _list) {
                                        es.aesEncrypt(
                                          i.path,
                                          passwordController.text,
                                          saveController.text,
                                          es.withoutDotAes(i.path)[2],
                                        );
                                      }

                                      String encryptedPassword = rsaKeypair
                                          .publicKey
                                          .encrypt(passwordController.text);

                                      List<String> currentFiles =
                                          await listFiles(saveController.text);

                                      String folderPath = saveController.text;

                                      for (final i in currentFiles) {
                                        int index = findInsert(i);
                                        await File(i).rename(
                                          i.substring(0, index) +
                                              folderName +
                                              i.substring(index),
                                        );
                                        // folderPath =
                                        //     i.substring(0, index) + folderName;

                                        cc.increment();
                                      }

                                      _createFolder(folderPath, "Keys");

                                      String tempKeysPath =
                                          Path.join(folderPath, "Keys");

                                      await writeContent();

                                      await File(privKeyPath).rename(privKeyPath
                                              .substring(
                                                  0,
                                                  findInsertFilePath(
                                                      privKeyPath)) +
                                          tempKeysPath.substring(
                                              findInsertsKeys(tempKeysPath)) +
                                          privKeyPath.substring(
                                              findInsertFilePath(privKeyPath)));

                                      await writeContent2();

                                      await File(pubKeyPath).rename(pubKeyPath
                                              .substring(
                                                  0,
                                                  findInsertFilePath(
                                                      pubKeyPath)) +
                                          tempKeysPath.substring(
                                              findInsertsKeys(tempKeysPath)) +
                                          pubKeyPath.substring(
                                              findInsertFilePath(pubKeyPath)));

                                      await writeContent3();

                                      await File(aesKeyPath).rename(aesKeyPath
                                              .substring(
                                                  0,
                                                  findInsertFilePath(
                                                      aesKeyPath)) +
                                          tempKeysPath.substring(
                                              findInsertsKeys(tempKeysPath)) +
                                          aesKeyPath.substring(
                                              findInsertFilePath(aesKeyPath)));
                                    } else {
                                      _createFolder(saveController.text);

                                      String folderName =
                                          await findFolder(saveController.text);

                                      for (final i in _list) {
                                        es.aesEncrypt(
                                          i.path,
                                          passwordController.text,
                                          saveController.text,
                                          es.withoutDotAes(i.path)[2],
                                        );
                                      }

                                      List<String> currentFiles =
                                          await listFiles(saveController.text);

                                      for (final i in currentFiles) {
                                        int index = findInsert(i);
                                        await File(i).rename(
                                          i.substring(0, index) +
                                              folderName +
                                              i.substring(index),
                                        );
                                        cc.increment();
                                      }
                                    }
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ContentDialog(
                                          actions: [
                                            TextButton(
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                  color: Color(0xFFf06b76),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                          backgroundDismiss: true,
                                          title: const Text(
                                            "Error",
                                            style: TextStyle(
                                              color: Color(0xFFf06b76),
                                            ),
                                          ),
                                          content: const Text(
                                            "Please fill in all required fields",
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    left: 20,
                                    right: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF272727),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    "Encrypt",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFf06b76),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Obx(
                                () => CircularPercentIndicator(
                                  radius: 70,
                                  percent: cc.count / _list.length,
                                  animation: true,
                                  progressColor: const Color(0xFFf06b76),
                                  backgroundColor: const Color(0xFF272727),
                                  lineWidth: 10,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  center: Text(
                                    (cc.count / _list.length * 100)
                                            .toInt()
                                            .toString() +
                                        "%",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedOpacity EncryptWidget(EncryptionService es) {
    return AnimatedOpacity(
      opacity: _tempIsVisible ? 1 : 0,
      duration: const Duration(seconds: 1),
      child: ScaffoldPage.withPadding(
        padding: const EdgeInsets.all(20),
        bottomBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: const [
              Text(
                "This program encrypts data using the AES 256 algorithm\n",
                style: TextStyle(color: Color(0xFf808080), fontSize: 8),
              ),
              Text(
                "If specified the program will use the RSA algorithm to generate keys which will be given to AES to encrypt your data",
                style: TextStyle(color: Color(0xFf808080), fontSize: 8),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Drag and drop or press to encrypt files or folders",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 50),
            Center(
              child: DropTarget(
                onDragDone: (detail) async {
                  setState(() {
                    _list.addAll(detail.files);
                  });

                  setState(() {
                    _tempIsVisible = false;
                  });

                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _isVisible = false;
                    });
                  });

                  // for (final i in _list) {
                  //   print(i.path);
                  //   es.aesEncrypt(i.path, "123", directory, fileName(i.path));
                  //   es.aesDecrypt(i.path, "123");

                  // }
                },
                onDragUpdated: (details) {
                  setState(() {
                    offset = details.localPosition;
                  });
                },
                onDragEntered: (detail) {
                  setState(() {
                    _dragging = true;
                    offset = detail.localPosition;
                  });
                },
                onDragExited: (detail) {
                  setState(() {
                    _dragging = false;
                    offset = null;
                  });
                },
                child: RippleAnimation(
                  repeat: true,
                  minRadius: 110,
                  ripplesCount: 3,
                  color: const Color(0xFFf06b76),
                  child: Container(
                    height: 260,
                    width: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0, 1],
                        colors: [Color(0xFF2a2a2a), Color(0xFF232323)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(3, 3),
                        ),
                        BoxShadow(
                          color: Color(0xFF3e3e3e),
                          offset: Offset(-3, -3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/icons/encrypted.png",
                      color: const Color(0xFFf06b76),
                      scale: 5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
