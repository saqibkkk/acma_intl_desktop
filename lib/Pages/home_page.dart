import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acma_intl_desktop/Controllers/nav_controller.dart';
import '../utils.dart';
import 'product_page.dart';
import 'customerPage.dart';
import 'side_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final navCtrl = Get.find<NavController>();
  bool internetAvailable = true;

  @override
  void initState() {
    super.initState();
  }

  Widget _getPage(PageType type) {
    switch (type) {
      case PageType.stock:
        return ProductsPage();
      case PageType.clients:
        return ClientsPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SideDrawer(),
                Expanded(
                  child: Obx(() => _getPage(navCtrl.selectedPage.value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
