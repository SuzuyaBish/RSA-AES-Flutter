import 'dart:async';
import 'dart:io';

import 'package:aes_app/services/encryption_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:resizable_widget/resizable_widget.dart';
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
  TextEditingController passwordController = TextEditingController();
  TextEditingController saveController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    saveController.dispose();
    super.dispose();
  }

  void pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      print("oof");
    }
    setState(() {
      directory = selectedDirectory.toString();
    });
    print(directory);
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

  @override
  Widget build(BuildContext context) {
    EncryptionService es = EncryptionService();
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
    //return _isVisible ? EncryptWidget(es) : EncryptSummary();
    return EncryptSummary();
  }

  AnimatedOpacity EncryptSummary() {
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
                        borderRadius: BorderRadius.circular(30),
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
                          borderRadius: BorderRadius.circular(30),
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
                                  itemCount: 30,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Text(
                                      "Index " + index.toString(),
                                      style: const TextStyle(
                                        color: Color(0xFFf06b76),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        controller: ScrollController(),
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
                                header: "Save Location:",
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
                  padding: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFf808080).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(30),
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
                "If checked the program will use the RSA algorithm to generate keys which will be given to AES to encrypt your data",
                style: TextStyle(color: Color(0xFf808080), fontSize: 8),
              ),
            ],
          ),
        ),
        content: Column(
          children: [
            const Text(
              "Drag and drop or press to encrypt files or folders",
              style: TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Extra Security",
                    style: TextStyle(
                      color: Color(0xFf808080),
                      fontSize: 16,
                    ),
                  ),
                ),
                ToggleSwitch(
                  checked: _isChecked,
                  onChanged: (v) {
                    setState(() {
                      _isChecked = v;
                    });

                    //pickFolder();
                  },
                  content: Text(_isChecked ? "Yes" : "No"),
                ),
                const SizedBox(width: 5),
                Tooltip(
                  message: "Enables RSA along with AES",
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
            const SizedBox(height: 40),
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

                  for (final i in _list) {
                    print(i.path);
                    //es.aesEncrypt(i.path, "123", directory, fileName(i.path));
                    //es.aesDecrypt(i.path, "123");
                  }
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
