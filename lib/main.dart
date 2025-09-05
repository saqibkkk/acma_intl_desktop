import 'package:acma_intl_desktop/APIs/productApi.dart';
import 'package:acma_intl_desktop/Controllers/customerController.dart';
import 'package:acma_intl_desktop/Controllers/productController.dart';
import 'package:acma_intl_desktop/Pages/home_page.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Controllers/nav_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(NavController());
  Get.put(ProductApi());
  Get.put(ProductController());
  Get.put(CustomerController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
