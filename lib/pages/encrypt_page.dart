import 'dart:async';

import 'package:aes_app/services/encryption_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
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
    return _isVisible ? EncryptWidget(es) : EncryptSummary();
  }

  AnimatedOpacity EncryptSummary() {
    return AnimatedOpacity(
      opacity: _isVisible ? 0 : 1,
      duration: const Duration(seconds: 1),
      child: ScaffoldPage.withPadding(
        padding: const EdgeInsets.all(12),
        content: const Center(
          child: Text("Yo moms a hoe"),
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

                    setState(() {
                      _tempIsVisible = false;
                    });

                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        _isVisible = false;
                      });
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
                  for (final i in _list) {
                    print(i.path);

                    es.aesEncrypt(i.path, "123", directory, fileName(i.path));
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
                      "assets/icons/encryption.png",
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
