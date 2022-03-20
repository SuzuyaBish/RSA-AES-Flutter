import 'package:aes_app/services/encryption_service.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Acrylic.in
  runApp(const AES());
}

class AES extends StatelessWidget {
  const AES({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          accentColor: Colors.red, scaffoldBackgroundColor: Colors.black),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    EncryptionService es = EncryptionService();

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text("Fluent Design App Bar"),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.code),
            title: const Text("Sample Page 1"),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.accept),
            title: const Text("Sample Page 2"),
          ),
        ],
      ),
      content: NavigationBody(
        index: 0,
        children: [
          ScaffoldPage(
            content: Column(
              children: [
                Text("Hey"),
                TextButton(
                  child: Text("Encrypt"),
                  onPressed: () {
                    es.aesEncrypt(es.getFilePath());
                  },
                ),
                TextButton(
                  child: Text("Decrypt"),
                  onPressed: () {
                    es.aesDecrypt();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
