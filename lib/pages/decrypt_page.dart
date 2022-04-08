import 'dart:async';
import 'dart:io';

import 'package:aes_app/controllers/count.dart';
import 'package:aes_app/globals.dart';
import 'package:aes_app/services/encryption_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypton/crypton.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class DecryptPage extends StatefulWidget {
  const DecryptPage({Key? key}) : super(key: key);

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  final List<XFile> _list = [];
  Offset? offset;
  bool _dragging = false;
  final bool _isChecked = false;
  String directory = "";
  bool _tempIsVisible = true;
  bool _isVisible = true;
  bool _isExpanded = false;
  String rsaEnabled = "No";
  final values = ["No", "Yes"];
  String currentDirectory = Directory.current.path;
  String tempString = "";
  final bool _useDefaultLocaiton = false;
  int count = 0;
  int actual = 0;
  List<File> keys = [];
  String tempStrForPriv = "";
  String tempStrForAes = "";
  String privKeyDirectory = "";
  String aesKeyDirectory = "";

  TextEditingController passwordController = TextEditingController();
  TextEditingController saveController = TextEditingController();
  TextEditingController privateKeyController = TextEditingController();
  TextEditingController aesKeyController = TextEditingController();

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  String keysDirectoryPath = "";
  bool keysPathExists = false;
  String documentsDirectory = "";

  String privKeyPath = "";
  String aesKeyPath = "";

  String privKey = "";
  String aesKey = "";

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
    privateKeyController.dispose();
    aesKeyController.dispose();
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

  void pickFolder2() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      setState(() {
        privateKeyController.text = currentDirectory;
      });
    } else {
      setState(() {
        privKeyPath = selectedDirectory.toString();
      });
    }
  }

  createFolder(String savePath, [String folderName = "EncryptedFiles"]) async {
    final path = Directory(savePath + "/" + folderName);

    if ((await path.exists())) {
      setState(() {
        keysPathExists = true;
      });
    } else {
      setState(() {
        keysDirectoryPath = path.path;
      });
      path.create();
    }
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

  Future<String> readPrivKey(String pathToPubKey) async {
    try {
      final file = File(pathToPubKey);

      final contents = await file.readAsString();

      setState(() {
        privKey = contents;
      });

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<String> readAesKey(String pathToAesKey) async {
    try {
      final file = File(pathToAesKey);

      final contents = await file.readAsString();

      setState(() {
        aesKey = contents;
      });

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<String> pickPrivKey() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        privKeyDirectory = result.files.single.path!;
      });
    } else {
      privateKeyController.text = currentDirectory;
    }

    return "";
  }

  Future<String> pickAesKey() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        aesKeyDirectory = result.files.single.path!;
      });
    } else {
      aesKeyController.text = currentDirectory;
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    EncryptionService es = EncryptionService();
    CountController cc = Get.put(CountController());
    if (saveController.text == "" && tempString == "" && directory == "") {
      saveController.text = currentDirectory;
    }
    if (saveController.text == "" && tempString != "" && directory == "") {
      saveController.text = tempString;
    }
    if (saveController.text == "" && tempString == "" && directory != "") {
      saveController.text = directory;
    }

    if (privateKeyController.text == "" &&
        tempStrForPriv == "" &&
        privKeyDirectory == "") {
      privateKeyController.text = currentDirectory;
    }
    if (privateKeyController.text == "" &&
        tempStrForPriv != "" &&
        privKeyDirectory == "") {
      privateKeyController.text = tempString;
    }
    if (privateKeyController.text == "" &&
        tempStrForPriv == "" &&
        privKeyDirectory != "") {
      privateKeyController.text = privKeyDirectory;
    }

    if (aesKeyController.text == "" &&
        tempStrForAes == "" &&
        aesKeyDirectory == "") {
      aesKeyController.text = currentDirectory;
    }
    if (aesKeyController.text == "" &&
        tempStrForAes != "" &&
        aesKeyDirectory == "") {
      aesKeyController.text = tempString;
    }
    if (aesKeyController.text == "" &&
        tempStrForAes == "" &&
        aesKeyDirectory != "") {
      aesKeyController.text = aesKeyDirectory;
    }
    //return _isVisible ? DecryptWidget(es) : decryptSummary(es, cc);
    return decryptSummary(es, cc);
  }

  AnimatedOpacity decryptSummary(EncryptionService es, CountController cc) {
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
                        color: background,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: neuOne,
                            offset: const Offset(5, 5),
                            blurRadius: 12,
                          ),
                          BoxShadow(
                            color: neuTwo,
                            offset: const Offset(-5, -5),
                            blurRadius: 12,
                          ),
                        ],
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
                          color: background,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: neuOne,
                              offset: const Offset(5, 5),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: neuTwo,
                              offset: const Offset(-5, -5),
                              blurRadius: 12,
                            ),
                          ],
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
                        color: background,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: neuOne,
                            offset: const Offset(5, 5),
                            blurRadius: 12,
                          ),
                          BoxShadow(
                            color: neuTwo,
                            offset: const Offset(-5, -5),
                            blurRadius: 12,
                          ),
                        ],
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
                                      value: rsaEnabled,
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() {
                                            rsaEnabled = v.toString();
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
                              if (rsaEnabled == "Yes") ...[
                                const SizedBox(height: 20),
                                TextBox(
                                  toolbarOptions: const ToolbarOptions(
                                    copy: true,
                                    cut: true,
                                    paste: true,
                                    selectAll: true,
                                  ),
                                  controller: privateKeyController,
                                  header: "Pick your private key:",
                                  headerStyle: const TextStyle(
                                    color: Color(0xFFf06b76),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  suffix: IconButton(
                                    onPressed: () async {
                                      await pickPrivKey();
                                      setState(() {
                                        privateKeyController.text =
                                            privKeyDirectory;
                                      });
                                    },
                                    icon: const Icon(
                                      FluentIcons.open_folder_horizontal,
                                      color: Color(0xFFf06b76),
                                    ),
                                  ),
                                  onSubmitted: (v) {
                                    setState(() {
                                      tempStrForPriv = v;
                                    });
                                    privateKeyController.text = tempStrForPriv;
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
                                  controller: aesKeyController,
                                  header: "Pick the AES key:",
                                  headerStyle: const TextStyle(
                                    color: Color(0xFFf06b76),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  suffix: IconButton(
                                    onPressed: () async {
                                      await pickAesKey();
                                      setState(() {
                                        aesKeyController.text = aesKeyDirectory;
                                      });
                                    },
                                    icon: const Icon(
                                      FluentIcons.open_folder_horizontal,
                                      color: Color(0xFFf06b76),
                                    ),
                                  ),
                                  onSubmitted: (v) {
                                    setState(() {
                                      tempStrForAes = v;
                                    });
                                    aesKeyController.text = tempStrForAes;
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
                              ] else
                                ...[],
                              const SizedBox(height: 20),
                              if (rsaEnabled == "No") ...[
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
                                const SizedBox(height: 20)
                              ],
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
                    color: background,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: neuOne,
                        offset: const Offset(5, 5),
                        blurRadius: 12,
                      ),
                      BoxShadow(
                        color: neuTwo,
                        offset: const Offset(-5, -5),
                        blurRadius: 12,
                      ),
                    ],
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
                                color: rsaEnabled == "Yes"
                                    ? Colors.white
                                    : const Color(0xFFD3D3D3).withOpacity(.80),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              rsaEnabled == "Yes"
                                  ? FluentIcons.accept
                                  : FluentIcons.status_circle_error_x,
                              color: rsaEnabled == "Yes"
                                  ? const Color(0xFFf06b76)
                                  : const Color(0xFFD3D3D3).withOpacity(.80),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (rsaEnabled == "Yes") ...[
                          Row(
                            children: [
                              Text(
                                "Private Key: ",
                                style: TextStyle(
                                  color: privateKeyController.text.isEmpty
                                      ? const Color(0xFFD3D3D3).withOpacity(.80)
                                      : Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                privateKeyController.text.isEmpty
                                    ? FluentIcons.status_circle_error_x
                                    : FluentIcons.accept,
                                color: privateKeyController.text.isEmpty
                                    ? const Color(0xFFD3D3D3).withOpacity(.80)
                                    : const Color(0xFFf06b76),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "AES Key: ",
                                style: TextStyle(
                                  color: aesKeyController.text.isEmpty
                                      ? const Color(0xFFD3D3D3).withOpacity(.80)
                                      : Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                aesKeyController.text.isEmpty
                                    ? FluentIcons.status_circle_error_x
                                    : FluentIcons.accept,
                                color: aesKeyController.text.isEmpty
                                    ? const Color(0xFFD3D3D3).withOpacity(.80)
                                    : const Color(0xFFf06b76),
                              ),
                            ],
                          ),
                        ] else ...[
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
                                    ? const Color(0xFFD3D3D3).withOpacity(.80)
                                    : const Color(0xFFf06b76),
                              ),
                            ],
                          ),
                        ],
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
                                  ? const Color(0xFFD3D3D3).withOpacity(.80)
                                  : const Color(0xFFf06b76),
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
                                          saveController.text.isNotEmpty ||
                                      privateKeyController.text.isNotEmpty &&
                                          aesKeyController.text.isNotEmpty &&
                                          saveController.text.isNotEmpty) {
                                    await createFolder(
                                        saveController.text, "DecryptedFiles");

                                    final temp =
                                        await getApplicationDocumentsDirectory();

                                    setState(() {
                                      documentsDirectory = temp.path;
                                    });

                                    if (rsaEnabled == "Yes") {
                                      String inBetween = saveController.text
                                          .substring(documentsDirectory.length);

                                      String pathWithoutKeys =
                                          documentsDirectory + inBetween;

                                      String pathWithKeys = Path.join(
                                          pathWithoutKeys, "DecryptedFiles");

                                      await readPrivKey(
                                        privateKeyController.text,
                                      );

                                      await readAesKey(aesKeyController.text);

                                      final key =
                                          RSAPrivateKey.fromString(privKey);

                                      String aesDecrypted = key.decrypt(aesKey);

                                      for (final i in _list) {
                                        String fileName = Path.basename(i.path);
                                        es.aesDecrypt(
                                          i.path,
                                          aesDecrypted,
                                          Path.join(pathWithKeys, fileName),
                                        );
                                        cc.increment();

                                        Future.delayed(
                                            const Duration(seconds: 3), () {
                                          setState(() {
                                            cc.count = 0.obs;
                                          });
                                        });

                                        setState(() {
                                          passwordController.text = "";
                                          saveController.text = "";
                                          aesKeyController.text = "";
                                          privateKeyController.text = "";
                                        });
                                      }
                                    } else {
                                      String inBetween = saveController.text
                                          .substring(documentsDirectory.length);

                                      String pathWithoutKeys =
                                          documentsDirectory + inBetween;

                                      String pathWithKeys = Path.join(
                                          pathWithoutKeys, "DecryptedFiles");

                                      for (final i in _list) {
                                        String fileName = Path.basename(i.path);
                                        es.aesDecrypt(
                                          i.path,
                                          passwordController.text,
                                          Path.join(pathWithKeys, fileName),
                                        );
                                        cc.increment();
                                      }

                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        setState(() {
                                          cc.count = 0.obs;
                                        });
                                      });

                                      setState(() {
                                        passwordController.text = "";
                                        saveController.text = "";
                                        aesKeyController.text = "";
                                        privateKeyController.text = "";
                                      });
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
              "Drag and drop to decrypt files or folders",
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0, 1],
                        colors: [gradientColorOne, gradientColorTwo],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: neuOne,
                          offset: const Offset(5, 5),
                          blurRadius: 12,
                        ),
                        BoxShadow(
                          color: neuTwo,
                          offset: const Offset(-5, -5),
                          blurRadius: 12,
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
