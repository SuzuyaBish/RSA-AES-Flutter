import 'dart:async';
import 'dart:io';
import 'package:aes_app/globals.dart';
import 'package:crypton/crypton.dart';
import 'package:path/path.dart' as path_provider;

import 'package:aes_app/controllers/count.dart';
import 'package:aes_app/services/encryption_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
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
  bool dragging = false;
  bool isChecked = false;
  String directory = "";
  String pubKeyDirectory = "";
  bool tempIsVisible = true;
  bool isVisible = true;
  bool isExpanded = false;
  String? rsaEnabled;
  final values = ["No", "Yes"];
  String currentDirectory = Directory.current.path;
  String tempString = "";
  bool useDefaultLocaiton = false;
  int count = 0;
  int actual = 0;
  String tempStrForPub = "";
  bool validateKey = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController saveController = TextEditingController();
  TextEditingController theirPubKeyPathController = TextEditingController();

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  RSAKeypair rsaKeypair = RSAKeypair.fromRandom();
  String pubKeyPath = "";
  String privKeyPath = "";
  String aesKeyPath = "";

  String keysDirectoryPath = "";
  bool keysPathExists = false;
  String documentsDirectory = "";

  String pubKey = "";
  String aesKey = "";

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
    }
  }

  void pickFolder2() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      setState(() {
        theirPubKeyPathController.text = currentDirectory;
      });
    } else {
      setState(() {
        pubKeyDirectory = selectedDirectory.toString();
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

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path\\aes.txt');
  }

  Future<File> writeContent(String aesKey) async {
    final file = await _localFile;

    setState(() {
      aesKeyPath = file.path;
    });

    return file.writeAsString(aesKey);
  }

  Future<String> readPubKey(String pathToPubKey) async {
    try {
      final file = File(pathToPubKey);

      final contents = await file.readAsString();

      setState(() {
        pubKey = contents;
      });

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<String> pickPubKey() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        pubKeyDirectory = result.files.single.path!;
      });
    } else {
      theirPubKeyPathController.text = currentDirectory;
    }

    return "";
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
    theirPubKeyPathController.dispose();
    super.dispose();
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

    if (theirPubKeyPathController.text == "" &&
        tempStrForPub == "" &&
        pubKeyDirectory == "") {
      theirPubKeyPathController.text = currentDirectory;
    }
    if (theirPubKeyPathController.text == "" &&
        tempStrForPub != "" &&
        pubKeyDirectory == "") {
      theirPubKeyPathController.text = tempString;
    }
    if (theirPubKeyPathController.text == "" &&
        tempStrForPub == "" &&
        pubKeyDirectory != "") {
      theirPubKeyPathController.text = directory;
    }
    return isVisible ? encryptWidget(es) : encryptSummary(es, cc);
    //return encryptSummary(es, cc);
  }

  AnimatedOpacity encryptSummary(EncryptionService es, CountController cc) {
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
                  if (isExpanded) ...[
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
                                      style: TextStyle(
                                        color: redColor,
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
                  const SizedBox(height: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
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
                          padding: const EdgeInsets.only(
                            top: 12,
                            left: 12,
                            right: 12,
                            bottom: 12,
                          ),
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
                                    icon: isExpanded
                                        ? Icon(
                                            FluentIcons.collapse_content,
                                            color: redColor,
                                          )
                                        : Icon(
                                            FluentIcons.pop_expand,
                                            color: redColor,
                                          ),
                                    onPressed: () {
                                      if (isExpanded) {
                                        setState(() {
                                          isExpanded = false;
                                        });
                                      } else {
                                        setState(() {
                                          isExpanded = true;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Text(
                                    "RSA Enabled",
                                    style: TextStyle(
                                      color: redColor,
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: lightGreyFont,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Text("?"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (rsaEnabled == "Yes") ...[
                                const SizedBox(height: 20),
                                Divider(
                                  style: DividerThemeData(
                                    thickness: 1,
                                    decoration: BoxDecoration(
                                      color: lightGreyFont,
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
                                  controller: theirPubKeyPathController,
                                  header: "Pick their public key: *",
                                  headerStyle: TextStyle(
                                    color: redColor,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  suffix: IconButton(
                                    onPressed: () async {
                                      await pickPubKey();

                                      setState(() {
                                        String temp = path_provider.basename(
                                            theirPubKeyPathController.text);

                                        String hold = "";
                                        theirPubKeyPathController.text = hold;

                                        if (temp == "pub.txt") {
                                          hold = pubKeyDirectory;
                                        }

                                        print(hold);
                                      });
                                    },
                                    icon: Icon(
                                      FluentIcons.open_folder_horizontal,
                                      color: redColor,
                                    ),
                                  ),
                                  onSubmitted: (v) {
                                    setState(() {
                                      tempStrForPub = v;
                                    });
                                    theirPubKeyPathController.text =
                                        tempStrForPub;
                                  },
                                ),
                                const SizedBox(height: 20),
                                Divider(
                                  style: DividerThemeData(
                                    thickness: 1,
                                    decoration: BoxDecoration(
                                      color: lightGreyFont,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 20),
                                Divider(
                                  style: DividerThemeData(
                                    thickness: 1,
                                    decoration: BoxDecoration(
                                      color: lightGreyFont,
                                    ),
                                  ),
                                ),
                              ],
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
                                header: "Password: *",
                                placeholder: "Type your password here",
                                headerStyle: TextStyle(
                                  color: redColor,
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
                                    color: lightGreyFont,
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
                                header: "Save location: *",
                                headerStyle: TextStyle(
                                  color: redColor,
                                ),
                                style: const TextStyle(fontSize: 12),
                                suffix: IconButton(
                                  onPressed: () {
                                    pickFolder();
                                    setState(() {
                                      saveController.text = directory;
                                    });
                                  },
                                  icon: Icon(
                                    FluentIcons.open_folder_horizontal,
                                    color: redColor,
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
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                          right: 20,
                        ),
                        height: MediaQuery.of(context).size.height / 3,
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
                                "Requirements",
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
                                          ? lightGreyFont
                                          : lightGreyFont,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    rsaEnabled == "Yes"
                                        ? FluentIcons.accept
                                        : FluentIcons.status_circle_error_x,
                                    color: rsaEnabled == "Yes"
                                        ? redColor
                                        : const Color(0xFFD3D3D3)
                                            .withOpacity(.80),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (rsaEnabled == "Yes") ...[
                                Row(
                                  children: [
                                    Text(
                                      "Public Key: ",
                                      style: TextStyle(
                                        color: validateKey == false
                                            ? redColor
                                            : lightGreyFont,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      validateKey == false
                                          ? FluentIcons.status_circle_error_x
                                          : FluentIcons.accept,
                                      color: validateKey == false
                                          ? const Color(0xFFD3D3D3)
                                              .withOpacity(.80)
                                          : redColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      "Password: ",
                                      style: TextStyle(
                                        color: passwordController.text.isEmpty
                                            ? redColor
                                            : lightGreyFont,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      passwordController.text.isEmpty
                                          ? FluentIcons.status_circle_error_x
                                          : FluentIcons.accept,
                                      color: passwordController.text.isEmpty
                                          ? lightGreyFont
                                          : redColor,
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
                                            ? redColor
                                            : lightGreyFont,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      passwordController.text.isEmpty
                                          ? FluentIcons.status_circle_error_x
                                          : FluentIcons.accept,
                                      color: passwordController.text.isEmpty
                                          ? lightGreyFont
                                          : redColor,
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    "Save location: ",
                                    style: TextStyle(
                                      color: useDefaultLocaiton == false &&
                                              directory == ""
                                          ? redColor
                                          : lightGreyFont,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    useDefaultLocaiton == false &&
                                            directory == ""
                                        ? FluentIcons.status_circle_error_x
                                        : FluentIcons.accept,
                                    color: useDefaultLocaiton == false &&
                                            directory == ""
                                        ? lightGreyFont
                                        : redColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (passwordController.text.isNotEmpty &&
                                  saveController.text.isNotEmpty ||
                              rsaEnabled == "Yes" &&
                                  passwordController.text.isNotEmpty &&
                                  saveController.text.isNotEmpty &&
                                  validateKey) {
                            await createFolder(
                                saveController.text, "EncryptedFiles");

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

                              String pathWithKeys = path_provider.join(
                                  pathWithoutKeys, "EncryptedFiles");

                              for (final i in _list) {
                                String fileName =
                                    path_provider.basename(i.path);
                                es.aesEncrypt(
                                  i.path,
                                  passwordController.text,
                                  path_provider.join(pathWithKeys, fileName),
                                );
                                cc.increment();

                                await readPubKey(
                                    theirPubKeyPathController.text);

                                final key = RSAPublicKey.fromString(pubKey);

                                String aesEncrypted =
                                    key.encrypt(passwordController.text);

                                await writeContent(aesEncrypted);

                                File(aesKeyPath).rename(path_provider.join(
                                    pathWithKeys, "aes.txt"));

                                Future.delayed(const Duration(seconds: 3), () {
                                  setState(() {
                                    cc.count = 0.obs;
                                  });
                                });
                              }

                              setState(() {
                                saveController.text = currentDirectory;
                                passwordController.text = "";
                                theirPubKeyPathController.text =
                                    currentDirectory;
                              });
                            } else {
                              String inBetween = saveController.text
                                  .substring(documentsDirectory.length);

                              String pathWithoutKeys =
                                  documentsDirectory + inBetween;

                              String pathWithKeys = path_provider.join(
                                  pathWithoutKeys, "EncryptedFiles");

                              for (final i in _list) {
                                String fileName =
                                    path_provider.basename(i.path);
                                es.aesEncrypt(
                                  i.path,
                                  passwordController.text,
                                  path_provider.join(pathWithKeys, fileName),
                                );
                                cc.increment();
                              }

                              Future.delayed(const Duration(seconds: 3), () {
                                setState(() {
                                  cc.count = 0.obs;
                                });
                              });

                              setState(() {
                                saveController.text = currentDirectory;
                                passwordController.text = "";
                                theirPubKeyPathController.text =
                                    currentDirectory;
                              });
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ContentDialog(
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "Close",
                                        style: TextStyle(
                                          color: redColor,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                  backgroundDismiss: true,
                                  title: Text(
                                    "Error",
                                    style: TextStyle(
                                      color: redColor,
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
                            top: 20,
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              stops: const [0, 1],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                gradientColorOne,
                                gradientColorTwo,
                              ],
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
                          child: const Center(
                            child: Text(
                              "Encrypt",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
    );
  }

  AnimatedOpacity encryptWidget(EncryptionService es) {
    return AnimatedOpacity(
      opacity: tempIsVisible ? 1 : 0,
      duration: const Duration(seconds: 1),
      child: ScaffoldPage.withPadding(
        padding: const EdgeInsets.all(20),
        bottomBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "This program encrypts data using the AES 256 algorithm\n",
                style: TextStyle(color: lightGreyFont, fontSize: 8),
              ),
              Text(
                "If specified the program will use the RSA algorithm to generate keys which will be given to AES to encrypt your data",
                style: TextStyle(color: lightGreyFont, fontSize: 8),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Drag and drop to encrypt files",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Center(
              child: DropTarget(
                onDragDone: (detail) async {
                  setState(() {
                    _list.addAll(detail.files);
                  });

                  setState(() {
                    tempIsVisible = false;
                  });

                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      isVisible = false;
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
                    dragging = true;
                    offset = detail.localPosition;
                  });
                },
                onDragExited: (detail) {
                  setState(() {
                    dragging = false;
                    offset = null;
                  });
                },
                child: RippleAnimation(
                  repeat: true,
                  minRadius: 110,
                  ripplesCount: 3,
                  color: redColor,
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
                          blurRadius: 12,
                          color: neuOne,
                          offset: const Offset(5, 5),
                        ),
                        BoxShadow(
                          blurRadius: 12,
                          color: neuTwo,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/icons/encrypted.png",
                      color: redColor,
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
