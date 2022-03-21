import 'package:fluent_ui/fluent_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      content: Column(
        children: [Text("Settings")],
      ),
    );
  }
}
