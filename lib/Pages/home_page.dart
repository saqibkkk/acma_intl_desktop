import 'package:acma_intl_desktop/Pages/customerPage.dart';
import 'package:acma_intl_desktop/Pages/side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/nav_controller.dart';
import 'product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _getPage(PageType type) {
    switch (type) {
      case PageType.stock:
        return const StockPage();
      case PageType.clients:
        return const ClientsPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavController>();
    bool isHovered = false; // Declare outside of the builder

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SideDrawer(),
                Expanded(
                  child: Obx(() => _getPage(navCtrl.selectedPage.value)),
                ),
              ],
            ),
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         color: Colors.black87,
          //         height: 60,
          //         alignment: Alignment.center,
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             const Text(
          //               'White Asia (Pvt) Ltd',
          //               style: TextStyle(color: Colors.white, fontSize: 11),
          //             ),
          //             const SizedBox(
          //               height: 5,
          //             ),
          //             StatefulBuilder(
          //               builder: (context, setState) {
          //                 return MouseRegion(
          //                   onEnter: (_) => setState(() => isHovered = true),
          //                   onExit: (_) => setState(() => isHovered = false),
          //                   child: InkWell(
          //                     onTap: () async {
          //                       final Uri url = Uri.parse(
          //                           'https://saqib-portfolio1.web.app/');
          //                       try {
          //                         await launchUrl(url);
          //                       } catch (e) {
          //                         // handle error
          //                       }
          //                     },
          //                     child: Text(
          //                       powered,
          //                       style: TextStyle(
          //                         fontWeight: FontWeight.bold,
          //                         color: Colors.blue,
          //                         fontSize: 13,
          //                         decoration: isHovered
          //                             ? TextDecoration.underline
          //                             : TextDecoration.none,
          //                         decorationColor: Colors
          //                             .white, // 👈 underline will be white
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
