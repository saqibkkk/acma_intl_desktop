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

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: SizedBox(
          width: 50, // ✅ Limit leading width to avoid layout error
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        title: showTitle
            ? Text(
                title,
                style: TextStyle(
                    color: isSelected ? Colors.lightBlue : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16),
              )
            : null, // no title when collapsed
        onTap: () => navCtrl.setPage(pageType),
        selected: isSelected,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        width: navCtrl.isDrawerOpen.value ? 230 : 70,
        duration: const Duration(milliseconds: 1),
        color: Colors.grey[300],
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
                    : Icons.arrow_forward_ios),
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
                        'Version 2.1.2',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  )
                : const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '2.1.1',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  )
          ],
        ),
      );
    });
  }
}
