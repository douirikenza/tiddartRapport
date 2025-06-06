import 'package:Tiddart/controllers/message_controller.dart';
import 'package:Tiddart/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'bindings/app_binding.dart';
import 'routes/app_routes.dart';
import 'controllers/category_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(CategoryController(), permanent: true);
  Get.put(MessageController());

  runApp(const TiddartApp());
}

class TiddartApp extends StatelessWidget {
  const TiddartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiddart',
      initialBinding: AppBinding(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFCEEDB),
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.alkalamiTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFCEEDB),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.brown),
          titleTextStyle: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.alkalamiTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.welcome,
      getPages: AppRoutes.routes,
    );
  }
}
