import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

class RSAKeyGeneratePage extends StatefulWidget {
  const RSAKeyGeneratePage({Key? key}) : super(key: key);

  @override
  State<RSAKeyGeneratePage> createState() => _RSAKeyGeneratePageState();
}

class _RSAKeyGeneratePageState extends State<RSAKeyGeneratePage> {
  String currentDirectory = Directory.current.path;
  String directory = "";
  String tempString = "";
  String keysDirectoryPath = "";
  String privKeyPath = "";
  String pubKeyPath = "";
  bool showText = false;
  bool keysPathExists = false;

  String documentsDirectory = "";
  String otherFoldersInBetween = "";
  String fileNames = "";

  TextEditingController pathController = TextEditingController();

  RSAKeypair rsaKeypair = RSAKeypair.fromRandom();

  void pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      setState(() {
        pathController.text = currentDirectory;
      });
    } else {
      setState(() {
        directory = selectedDirectory.toString();
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
    return File('$path\\priv.txt');
  }

  Future<File> get _localFile2 async {
    final path = await _localPath;
    return File('$path\\pub.txt');
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

  @override
  void dispose() {
    pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pathController.text == "" && tempString == "" && directory == "") {
      pathController.text = currentDirectory;
    }
    if (pathController.text == "" && tempString != "" && directory == "") {
      pathController.text = tempString;
    }
    if (pathController.text == "" && tempString == "" && directory != "") {
      pathController.text = directory;
    }
    return ScaffoldPage.withPadding(
      padding: const EdgeInsets.all(20),
      content: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 5,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFf808080).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: const [
                    Text(
                      "Generation of the keys will only be used if you select to encyrpt with RSA, these keys are needed in order for the algorithm to work correctly.",
                      style: TextStyle(color: Color(0xFFf06b76)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "This step only needs to be done once although you can do it however many times you want.",
                      style: TextStyle(color: Color(0xFFf06b76)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFf808080).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      TextBox(
                        toolbarOptions: const ToolbarOptions(
                          copy: true,
                          cut: true,
                          paste: true,
                          selectAll: true,
                        ),
                        controller: pathController,
                        header: "Save location:",
                        headerStyle: const TextStyle(
                          color: Color(0xFFf06b76),
                        ),
                        style: const TextStyle(fontSize: 14),
                        suffix: IconButton(
                          onPressed: () {
                            pickFolder();
                            setState(() {
                              pathController.text = directory;
                            });
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
                          pathController.text = tempString;
                        },
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () async {
                          await createFolder(pathController.text, "Keys");

                          final temp = await getApplicationDocumentsDirectory();

                          setState(() {
                            documentsDirectory = temp.path;
                          });

                          if (keysPathExists) {
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
                                    "Keys folder already exists in this directory!\nPlease remove the existing keys folder or change where you want to save the files.",
                                  ),
                                );
                              },
                            );
                            setState(() {
                              keysPathExists = false;
                            });
                          } else {
                            if (pathController.text.length ==
                                documentsDirectory.length) {
                              String documentsAndKeys =
                                  Path.join(pathController.text, "Keys");

                              await writeContent();

                              await File(privKeyPath).rename(
                                  Path.join(documentsAndKeys, "priv.txt"));

                              await writeContent2();

                              await File(pubKeyPath).rename(
                                  Path.join(documentsAndKeys, "pub.txt"));

                              setState(() {
                                showText = true;
                              });
                            } else {
                              String inBetween = pathController.text
                                  .substring(documentsDirectory.length);

                              String pathWithoutKeys =
                                  documentsDirectory + inBetween;

                              String pathWithKeys =
                                  Path.join(pathWithoutKeys, "Keys");

                              String pathWithNamePriv =
                                  Path.join(pathWithKeys, "priv.txt");

                              String pathWithNamePub =
                                  Path.join(pathWithKeys, "pub.txt");

                              await writeContent();

                              await File(privKeyPath).rename(pathWithNamePriv);

                              await writeContent2();

                              await File(pubKeyPath).rename(pathWithNamePub);

                              setState(() {
                                showText = true;
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF272727),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "Generate",
                            style: TextStyle(
                              color: Color(0xFFf06b76),
                            ),
                          ),
                        ),
                      ),
                      if (showText) ...[
                        const SizedBox(height: 40),
                        const Text(
                          "Your keys were created successfully!",
                          style: TextStyle(
                            color: Color(0xFFf06b76),
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          "Keep them safe.",
                          style: TextStyle(
                            color: Color(0xFFf06b76),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
