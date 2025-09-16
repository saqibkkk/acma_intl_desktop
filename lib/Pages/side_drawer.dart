import 'package:acma_intl_desktop/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/nav_controller.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  final navCtrl = Get.find<NavController>();

  Widget drawerButton(String title, IconData icon, PageType pageType) {
    return Obx(() {
      final isSelected = navCtrl.selectedPage.value == pageType;
      final showTitle = navCtrl.isDrawerOpen.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Material(
          color: isSelected ? Colors.red.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: isSelected ? 6 : 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => navCtrl.setPage(pageType),
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    icon,
                    color: isSelected ? Colors.red : Colors.blueGrey,
                  ),
                  if (showTitle) ...[
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.red : Colors.blueGrey[800],
                      ),
                    ),
                  ] else
                    const SizedBox.shrink(), // keeps ListTile error away
                ],
              ),
            ),
          ),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        width: navCtrl.isDrawerOpen.value ? 230 : 70,
        duration: const Duration(milliseconds: 1),
        color: Colors.blueGrey[200],
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(navCtrl.isDrawerOpen.value
                    ? Icons.arrow_back_ios
                    : Icons.arrow_forward_ios,
                    color: navCtrl.isDrawerOpen.value
                  ? Colors.red
                  :Colors.white,
                ),
                onPressed: navCtrl.toggleDrawer,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            drawerButton('Stock', Icons.inventory, PageType.stock),
            drawerButton('Clients', Icons.book, PageType.clients),
            const SizedBox(
              height: 10,
            ),
            const Spacer(),
            navCtrl.isDrawerOpen.value
                ? const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Version: $currentVersion',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  )
                : const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        currentVersion,
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  )
          ],
        ),
      );
    });
  }
}
