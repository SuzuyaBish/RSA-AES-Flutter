import 'package:aes_app/pages/decrypt_page.dart';
import 'package:aes_app/pages/encrypt_page.dart';
import 'package:aes_app/pages/settings_page.dart';
import 'package:aes_app/pages/summary_page.dart';
import 'package:aes_app/utils/window_buttons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const String appTitle = 'Encrypt and Decrypt';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  if (isDesktop) {
    WidgetsFlutterBinding.ensureInitialized();
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle('hidden');
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(755, 545));
      await windowManager.setMaximumSize(const Size(755, 545));
      await windowManager.setResizable(false);
      await windowManager.center();
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }
  Paint.enableDithering = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: appTitle,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.red,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
      ),
      theme: ThemeData(
        accentColor: Colors.red,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        leading: const Icon(FluentIcons.accept, color: Colors.transparent),
        title: () {
          return const DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            ),
          );
        }(),
        actions: DragToMoveArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [Spacer(), WindowButtons()],
          ),
        ),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          openMinWidth: 250,
          openMaxWidth: 320,
        ),
        items: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.dataflows),
            title: const Text('Encrypt'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.dataverse),
            title: const Text('Decrypt'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.icon_sets_flag),
            title: const Text('Summary'),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: const [
          EncryptPage(),
          DecryptPage(),
          SummaryPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}
