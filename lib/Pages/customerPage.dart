import 'package:acma_intl_desktop/APIs/customerApi.dart';
import 'package:acma_intl_desktop/Controllers/customerController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../APIs/productApi.dart';
import '../Controllers/productController.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final customerController = Get.put(CustomerController());
  final customerApi = Get.put(CustomerApi());

  @override
  void initState() {
    super.initState();
    customerController.fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient Header with Animated Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: const Text(
                      "✨ ACMA INTERNATIONAL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                onPressed: () {
                  customerController.addCustomer();
                },
                child: Text('Manage Customer')),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              // controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                // productController.searchText.value = value;
              },
            ),
          ),

          Expanded(
            child: Obx(() {
              if (customerController.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.indigoAccent,
                ));
              }
              if (customerController.customer.isEmpty) {
                return const Center(child: Text("No customer found."));
              }

              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  headingRowHeight: 60,
                  dataRowHeight: 40,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.blue.shade100),
                  columns: [
                    const DataColumn(label: Text('Customer Name')),
                    const DataColumn(label: Text('Contact Number')),
                    const DataColumn(label: Text('Address')),
                    const DataColumn(
                        label: Text('Actions')), // <-- New column for button
                  ],
                  rows: customerController.filteredCustomers.map((customer) {
                    return DataRow(
                      cells: [
                        _fancyCell(customer.customerName),
                        _fancyCell(customer.customerContactNumber),
                        _fancyCell(customer.customerAddress),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await customerController.editCustomer(
                                      customers: customer);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await customerController.deleteCustomer(
                                      customerUid: customer.customerUid);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await customerController.selectBillProducts(customerUid: customer.customerUid, customerName: customer.customerName);
                                },
                                child: const Text("Generate Bill"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  DataCell _fancyCell(String? text) {
    return DataCell(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            text ?? "-",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
