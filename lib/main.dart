import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_selector_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));

  runApp(const UnilearnApp());
}

class UnilearnApp extends StatelessWidget {
  const UnilearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unilearn',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoadingScreen(),
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainSelectorScreen(),
      },
    );
  }
}