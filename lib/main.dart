import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:metacolhub/auth/auth.dart';
import 'package:metacolhub/auth/login_or_register.dart';
import 'package:metacolhub/firebase_options.dart';
import 'package:metacolhub/pages/added_files.dart';
import 'package:metacolhub/pages/home_page.dart';
import 'package:metacolhub/pages/profile_page.dart';
import 'package:metacolhub/pages/settings_page.dart';
import 'package:metacolhub/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/login_register_page': (context) => LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/added_files': (context) => AddedFiles(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
