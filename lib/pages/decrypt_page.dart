import 'dart:async';
import 'dart:io';

import 'package:aes_app/controllers/count.dart';
import 'package:aes_app/controllers/requirments.dart';
import 'package:aes_app/services/encryption_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:file_picker/file_picker.dart';

class DecryptPage extends StatefulWidget {
  const DecryptPage({Key? key}) : super(key: key);

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
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
  List<File> keys = [];

  TextEditingController passwordController = TextEditingController();
  TextEditingController saveController = TextEditingController();

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  String privKey =
      "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCZJa//qrZ1NYFOs6Pt7kHCztJSlHoGmNQt3+l7JAAFVAfZaUalGE5sDZIj0mnYluwRe4g937avfZ1UUY5hCOddE9DEecaKlnJcDPfcLLcnHTnidbZpFbzlysvsB9QANNHv6X8aaDZemJsg+BHt/oLTStNEfQMH0QEaFrL+IBGzwZLdl/5DIAEOgMofgbgtQ5Bb/AjhgvXyqTzprKcBonv37xZHloFCDbIN1Z7rAta+xwcNgaBQd+W2FkoB1YiOnLW4JT5e3oFJ0cCYBGA3lTMuXi2rZm++2VksI3fEcP5iGkJ7RKVxHxKsAAySJ/9hWq/P3Fy31b0duNj3IejQD7YTAgMBAAECggEBAIXLNhpPYv29E83VBSctmof9tiNtEbpHtD6rusfY6Ke/BOh8n7pGJOUjagQfpFcTawPO/3TGyExCmrt6UMAXTkGzuRSdKsYSr7AZqETTT+M9Fj/xBL6DvjanWEZJhH31p19Ih8FjP/SesBA6iTd5vYOogC/6YzZl8ud+4zs+exilZjbKHlRHIniEE8KXj1KYilmNyt2Z9PDkdj6ktN0PmEBozgVV4mSIi47frwWHaMfZ6L2XskyLCZTSsTWD2YNW/x2v80J2+kne3oSETla5DaU618NRqDFeX7Qt9ufN9YGu7/bnwbP76ts7j54JhsW04Du5oFAVR0pt1el3hA9fPckCgYEA+csO6xs5fTSFSIETatIjq5xxMxs32wy+R7q+QjEqHMaGMJzteE41Z8ztMN5rfovuIWnflXOhuNti1vCht7c7+CtegWEhwZ8kP7NqmC/BzGlSj1Qzuc/+doNp6b8hGmxhrfgxEx3JcGhYb0hnGr3vI8svZogDNjmERtbVW0TVplUCgYEAnPPcgeJMndlIUPbn8ltct0MTgU+2eqeQlIvX7+JG7FTpOU4EVYnL8KuxcFHSW90mDwyn15OdRPWUrIRc7tw7OrJKI4u5dqSxzZYPWTF4Eg+i+6HLTEKNx15kZmAcHwkHvqdtwy3mDPgqSWDfoRFzGDqN9UDtN+0qRaT+gDczwscCgYAQxUFLJ5jEfzIzm/bhxRn/+5DeDYXCfyiHSFJdv09Ef0+jE+YdnaKYRXnnPgeZh2uFcsZAEnNZJeGM7Lruyq6MCt1dclgB191nKXSOoyYvwyJ33P9cCkrbShdiSiK+02f7dh5VWjqcAWVukz3Y3cegb5PPHnKYwWPQHbxVVFnDwQKBgEC2NwuCT46hgLSJKJb/XlndGRSu1hD6N51Xjz/DrvRQChzrctQFzYU8dRtXUQE5TDDWSfmTTjuZeaQrqtl9ChqoWfMP7/bf7sNSBKAEynm/4rYXPmgB5Mz3uTOQmuec5ImSJKpdqUVdqKm6fFm/hRHPSqp9C5GMgmpWnewlVn0PAoGAH37pxFR7QKG+Ki2x4PI3bcWmxxkrOzN9lS89YG0qovK+MPL152b0mn/Ei3Idq/qCAiyyoHwI8io0UmzBtLaO71ZU3zVZsfbof/qIVxFGneqaB3ubGdn1bSYmQvbBgrcdGaITdufltQLXp0y4YwbXRemzPRS1O4nP/GA6DYLBVIU=";

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

  _createFolder(String savePath) async {
    final folderName = "DecryptedFiles";
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

  Future<String> findFolder(String path) async {
    var dir = Directory(path);
    String temp = "";
    String ret = "";
    int count = 0;
    var indexes = [];

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity.path.contains("DecryptedFiles")) {
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

  Future<List<String>> listFiles(String path) async {
    var dir = Directory(path);
    List<String> files = [];

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (!entity.path.contains("DecryptedFiles") &&
          !entity.path.contains("EncryptedFiles")) {
        files.add(entity.path);
      }
    }
    return files;
  }

  Future<List<File>> pickKeys() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    List<File> files = [];

    if (result != null) {
      setState(() {
        files = result.paths.map((path) => File(path!)).toList();
      });
    } else {
      print("Cancelled");
    }
    return files;
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
    return _isVisible ? DecryptWidget(es) : DecryptSummary(requirments, es, cc);
    //return DecryptSummary(requirments, es, cc);
  }

  AnimatedOpacity DecryptSummary(
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
                        "Files to decrypt ...",
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
                                "Files to decrypt",
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
                                    "Was RSA Enabled",
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
                              if (_RSAEnabled == "Yes") ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Key Paths:",
                                          style: TextStyle(
                                            color: Color(0xFFf06b76),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          icon: const Icon(
                                            FluentIcons.file_request,
                                            size: 15,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ContentDialog(
                                                  actions: [
                                                    TextButton(
                                                      child: const Text(
                                                        "Okay",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFFf06b76),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() async {
                                                          keys =
                                                              await pickKeys();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                  backgroundDismiss: true,
                                                  title: const Text(
                                                    "Warning",
                                                    style: TextStyle(
                                                      color: Color(0xFFf06b76),
                                                    ),
                                                  ),
                                                  content: const Text(
                                                    "Pick 'aes.txt' and 'priv.txt' or it will not work",
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          "AES key path:",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          keys.isEmpty ? "Empty" : keys[0].path,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFf06b76),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          "RSA key path:",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          keys.isEmpty ? "Empty" : keys[0].path,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFf06b76),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ] else ...[
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
                              ],
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
                                    _createFolder(saveController.text);

                                    String folderName =
                                        await findFolder(saveController.text);

                                    for (final i in _list) {
                                      es.aesDecrypt(
                                        i.path,
                                        privKey,
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
                                      cc.increment2();
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
                                    "Decrypt",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFf06b76),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Obx(
                              //   () => CircularPercentIndicator(
                              //     radius: 70,
                              //     percent: cc.count2 / _list.length,
                              //     animation: true,
                              //     progressColor: const Color(0xFFf06b76),
                              //     backgroundColor: const Color(0xFF272727),
                              //     lineWidth: 10,
                              //     circularStrokeCap: CircularStrokeCap.round,
                              //     center: Text(
                              //       (cc.count2 / _list.length * 100)
                              //               .toInt()
                              //               .toString() +
                              //           "%",
                              //       style: const TextStyle(fontSize: 20),
                              //     ),
                              //   ),
                              // ),
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

  AnimatedOpacity DecryptWidget(EncryptionService es) {
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
              "Drag and drop or press to decrypt files or folders",
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
                      "assets/icons/decryptionp1.png",
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
