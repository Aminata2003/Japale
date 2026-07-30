import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // généré automatiquement par flutterfire configure
import 'routes.dart';

Future<void> main() async {
  // Obligatoire avant tout appel Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35)),
        useMaterial3: true,
      ),

      // Toute la navigation passe maintenant par routes.dart.
      // Pour tester une page précise pendant le développement, changez
      // temporairement la ligne ci-dessous plutôt que celle-ci — ça évite
      // les conflits Git sur ce fichier entre vous deux.
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
