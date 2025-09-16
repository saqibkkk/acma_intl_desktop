import 'package:acma_intl_desktop/APIs/customerApi.dart';
import 'package:acma_intl_desktop/Controllers/customerController.dart';
import 'package:acma_intl_desktop/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final customerController = Get.put(CustomerController());
  final customerApi = Get.put(CustomerApi());
  final Utils utils = Utils();
  bool internetAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();

  }

  Future<void> _checkInternet() async {
    internetAvailable = await Utils.isInternetAvailable();
    if (!internetAvailable) {
      _showNoInternet();
    } else {
      customerController.fetchCustomers();
    }
    setState(() {});
  }

  void _showNoInternet() {
    Get.snackbar(
      "No Internet",
      "Internet connection is not available. Please check your network.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          utils.customPageHeader(),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: utils.customElevatedFunctionButton(
                    onPressed: () {
                      customerController.addCustomer();
                    },
                    btnName: 'Add Customers',
                    bgColor: Colors.blueGrey,
                    fgColor: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Customers...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                customerController.searchText.value = value;
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Obx(() {

              if (!internetAvailable) {
                return const Center(
                  child: Text(
                    'No Internet Connection.\nPlease check your network.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                );
              }

              if (customerController.isLoading.value) {
                return Center(
                    child: utils.customCircularProgressingIndicator());
              }
              if (customerController.customer.isEmpty) {
                return const Center(
                    child: Text(
                  "No Customers found!",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ));
              }

              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowHeight: 40,
                  headingRowColor: WidgetStateProperty.all(Colors.blueGrey),
                  columns: [
                    const DataColumn(
                        label: Text(
                      'Customer Name',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                    const DataColumn(
                        label: Text(
                      'Contact Number',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                    const DataColumn(
                        label: Text(
                      'Address',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                    const DataColumn(
                        label: Text(
                      'Actions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )), // <-- New column for button
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
                                      customerUid: customer.customerUid,
                                      customerName: customer.customerName);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              utils.customTextCancelButton(
                                  onPressed: () async {
                                    await customerController.selectBillProducts(
                                        customerUid: customer.customerUid,
                                        customerName: customer.customerName);
                                  },
                                  btnName: 'Generate Bill',
                                  textColor: Colors.blue)
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
