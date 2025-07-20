import 'package:fluent_ui/fluent_ui.dart';
import 'package:hosts_manager/screens/hosts_screen.dart';

class HostsManagerApp extends StatelessWidget {
  const HostsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Hosts Manager',
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
      ),
      home: const HostsScreen(),
    );
  }
}