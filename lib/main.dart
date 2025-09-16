import 'package:acma_intl_desktop/APIs/productApi.dart';
import 'package:acma_intl_desktop/Controllers/customerController.dart';
import 'package:acma_intl_desktop/Controllers/productController.dart';
import 'package:acma_intl_desktop/Pages/home_page.dart';
import 'package:acma_intl_desktop/Pages/splashScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Controllers/nav_controller.dart';
import 'Controllers/updateController.dart';
import 'firebase_options.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the window manager only for desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();

    // Dynamically get the screen size and maximize
    windowManager.waitUntilReadyToShow(
        const WindowOptions(
          center: true,
          titleBarStyle: TitleBarStyle.normal,
        ), () async {
      // Maximizing the window dynamically
      await windowManager.maximize();
      await windowManager.setResizable(false); // Prevent manual resize
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(MyWindowListener());
  }

  Get.put(NavController());
  Get.put(ProductApi());
  Get.put(ProductController());
  Get.put(CustomerController());
  Get.put(AutoUpdater());
  runApp(const MyApp());
}

class MyWindowListener extends WindowListener {
  @override
  void onWindowUnmaximize() {
    // If user clicks the center button, force back to maximized
    windowManager.maximize();
  }

  @override
  void onWindowResize() async {
    // Force it back to maximized if somehow resized
    bool isMaximized = await windowManager.isMaximized();
    if (!isMaximized) {
      await windowManager.maximize();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const
          // UpdatePage()
          // HomePage(),
          SplashScreen(),
      routes: {
        "/home": (context) => const HomePage(), // your main app screen
      },
    );
  }
}
