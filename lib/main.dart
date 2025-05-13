import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quill_with_llm/firebase_options.dart';
import 'screens/home_screen.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../constants/fonts_loader/fonts_loader.dart';

final FontsLoader loader = FontsLoader();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loader.loadFonts();
  await dotenv.load(fileName: "assets/app_config.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Quill with LLM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          background: Colors.purple[50],
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
