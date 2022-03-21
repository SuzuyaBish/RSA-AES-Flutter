import 'package:fluent_ui/fluent_ui.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class DecryptPage extends StatefulWidget {
  const DecryptPage({Key? key}) : super(key: key);

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      padding: const EdgeInsets.all(30),
      content: Column(
        children: [
          const Text(
            "Drag and drop or click to add files or folders",
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
                onChanged: (v) => setState(() => _isChecked = v),
                content: Text(_isChecked ? "Yes" : "No"),
              ),
              const SizedBox(width: 5),
              Tooltip(
                message:
                    "Enables RSA along with AES\nThis setting is required if you checked extra security during encryption",
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
        ],
      ),
    );
  }
}
