import 'package:acma_intl_desktop/APIs/customerApi.dart';
import 'package:acma_intl_desktop/APIs/productApi.dart';
import 'package:acma_intl_desktop/Controllers/productController.dart';
import 'package:acma_intl_desktop/Models/customerModel.dart';
import 'package:acma_intl_desktop/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/billModel.dart';
import '../Models/productModel.dart';

class CustomerController extends GetxController {
  final Utils utils = Utils();
  final CustomerApi api = Get.put(CustomerApi());
  final ProductApi productApi = Get.put(ProductApi());
  final productController = Get.put(ProductController());
  var isLoading = true.obs;
  RxBool isSavingBill = false.obs;
  var customer = <CustomerModel>[].obs;
  var searchText = ''.obs;
  Map<String, Map<String, bool>> selectedDetailsPerProduct = {};
  // Text controllers
  final customerName = TextEditingController();
  final customerContact = TextEditingController();
  final customerAddress = TextEditingController();
  final newCustomerName = TextEditingController();
  final newCustomerContact = TextEditingController();
  final newCustomerAddress = TextEditingController();
  final billQuantity = TextEditingController();
  final billPrice = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    productController.fetchProductsDetails();
  }

  void clearFields() {
    customerName.clear();
    customerContact.clear();
    customerAddress.clear();
    newCustomerName.clear();
    newCustomerContact.clear();
    newCustomerAddress.clear();
  }

  @override
  void onClose() {
    customerName.dispose();
    customerContact.dispose();
    customerAddress.dispose();
    newCustomerName.dispose();
    newCustomerContact.dispose();
    newCustomerAddress.dispose();
    super.onClose();
  }

  List<CustomerModel> get filteredCustomers {
    if (searchText.isEmpty) return customer;
    return customer
        .where((p) =>
            p.customerName
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            p.customerContactNumber
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            p.customerAddress
                .toLowerCase()
                .contains(searchText.value.toLowerCase()))
        .toList();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      update();

      final data = await api.fetchCustomers();
      customer.value = data.entries.map((e) {
        return CustomerModel(
          customerName: e.value['customerName'],
          customerContactNumber: e.value['customerContactNumber'],
          customerAddress: e.value['customerAddress'],
          customerUid: e.value['customerUid'],
        );
      }).toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future addCustomer() {
    String customerUid = utils.generateRealtimeUid();
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Customer'),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  utils.customTextFormField('Name', customerName,
                      keyboardType: TextInputType.text),
                  const SizedBox(height: 10),
                  utils.customTextFormField('Contact', customerContact,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  utils.customTextFormField(
                    'Address',
                    customerAddress,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            utils.customTextCancelButton(
                onPressed: () {
                  Get.back();
                  clearFields();
                },
                btnName: 'Cancel',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () async {
                  String name = customerName.text.trim().toUpperCase();
                  String contact = customerContact.text.trim().toUpperCase();
                  String address = customerAddress.text.trim().toUpperCase();

                  if (name.isEmpty || contact.isEmpty || address.isEmpty) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'All fields are required',
                        bgColor: Colors.red[200]);
                    return;
                  }

                  bool exists = customer.any(
                    (c) => c.customerName.toUpperCase() == name,
                  );

                  if (exists) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'Customer already exists',
                        bgColor: Colors.red[200]);
                    return;
                  }

                  final customerModel = CustomerModel(
                      customerName: name,
                      customerContactNumber: contact,
                      customerAddress: address,
                      customerUid: customerUid);

                  Get.back();
                  await api.saveCustomers(
                      customer: customerModel, customerUid: customerUid);
                  utils.customSnackBar(
                      title: 'Error',
                      message: 'New customer: $name has been added',
                      bgColor: Colors.green[200]);
                  await fetchCustomers();
                  clearFields();
                },
                btnName: 'Save',
                bgColor: Colors.green[200],
                fgColor: Colors.white)
          ],
        );
      },
    );
  }

  Future editCustomer({required CustomerModel customers}) {
    // Pre-fill controllers
    newCustomerName.text = customers.customerName;
    newCustomerContact.text = customers.customerContactNumber;
    newCustomerAddress.text = customers.customerAddress;

    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Customer - ${customers.customerName}'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                utils.customTextFormField(
                  'Customer Name',
                  newCustomerName,
                ),
                const SizedBox(height: 10),
                utils.customTextFormField(
                  'Customer Contact',
                  newCustomerContact,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                utils.customTextFormField(
                  'Customer Address',
                  newCustomerAddress,
                ),
              ],
            ),
          ),
          actions: [
            utils.customTextCancelButton(
                onPressed: () {
                  Get.back();
                  clearFields();
                },
                btnName: 'Cancel',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () async {
                  final newName = newCustomerName.text.trim().toUpperCase();
                  final newContact =
                      newCustomerContact.text.trim().toUpperCase();
                  final newAddress =
                      newCustomerAddress.text.trim().toUpperCase();

                  if (newName.isEmpty ||
                      newContact.isEmpty ||
                      newAddress.isEmpty) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'All fields are required',
                        bgColor: Colors.red[200]);
                    return;
                  }

                  bool exists = customer.any((d) =>
                      d.customerName == newName &&
                      d.customerContactNumber == newContact &&
                      d.customerAddress == newAddress);

                  if (exists) {
                    utils.customSnackBar(
                        title: 'Error',
                        message:
                            'These details already exist for this customer',
                        bgColor: Colors.red[200]);
                    return;
                  }
                  Get.back();

                  await api.editCustomer(
                      customerUid: customers.customerUid,
                      newCustomerName: newName,
                      newCustomerContact: newContact,
                      newCustomerAddress: newAddress);
                  utils.customSnackBar(
                      title: 'Success',
                      message: 'Customer details have been edited',
                      bgColor: Colors.green[200]);
                  await fetchCustomers();
                  clearFields();
                },
                btnName: 'Save',
                bgColor: Colors.green[200],
                fgColor: Colors.white),
          ],
        );
      },
    );
  }

  Future deleteCustomer(
      {required String customerUid, required String customerName}) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Container(
            width: 500,
            child: Text(
              'Are you sure?'
              '\n\nAll details of $customerName will be deleted permanently!',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
          ),
          actions: [
            utils.customTextCancelButton(
                onPressed: () async {
                  Get.back();
                  await api.deleteCustomer(customerUid: customerUid);
                  utils.customSnackBar(
                      title: 'Success',
                      message: 'All details of $customerName have been deleted',
                      bgColor: Colors.green[200]);
                  await fetchCustomers();
                },
                btnName: 'Delete',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () {
                  Get.back();
                },
                btnName: 'Cancel',
                bgColor: Colors.green[200],
                fgColor: Colors.white)
          ],
        );
      },
    );
  }

  Future selectBillProducts(
      {required String customerUid, required String customerName}) {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        String searchText = '';
        Map<String, Map<String, bool>> selectedDetailsPerProduct = {};

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Products'),
              content: Container(
                width: 900,
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Products list
                    Expanded(
                      child: GetBuilder<ProductController>(
                        builder: (controller) {
                          if (controller.isLoading.value) {
                            return utils.customCircularProgressingIndicator();
                          }

                          final productsToShow = controller.productNames
                              .where((p) => p.productName
                                  .toLowerCase()
                                  .contains(searchText.toLowerCase()))
                              .toList();

                          if (productsToShow.isEmpty) {
                            return const Center(
                                child: Text(
                              'No Products Found!',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ));
                          }

                          return ListView(
                            children: productsToShow.map((product) {
                              final details = controller.productsDetails
                                  .where((d) =>
                                      d.productName == product.productName)
                                  .toList();

                              // Initialize map for this product
                              selectedDetailsPerProduct.putIfAbsent(
                                  product.productName, () => {});

                              return ExpansionTile(
                                title: Text(
                                  product.productName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  if (details.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'No Details Found!',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Select')),
                                          DataColumn(
                                              label: Text('Catalogue Number')),
                                          DataColumn(label: Text('Lot Number')),
                                          DataColumn(label: Text('Holes')),
                                          DataColumn(label: Text('AKL Number')),
                                          DataColumn(
                                              label: Text('Available stock')),
                                        ],
                                        rows: details.map((d) {
                                          final id =
                                              d.catalogueNumber + d.lotNumber;

                                          // Initialize checkbox state
                                          selectedDetailsPerProduct[
                                                  product.productName]!
                                              .putIfAbsent(id, () => false);

                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Checkbox(
                                                  value:
                                                      selectedDetailsPerProduct[
                                                          product
                                                              .productName]![id],
                                                  onChanged: (val) {
                                                    setState(() {
                                                      selectedDetailsPerProduct[
                                                              product
                                                                  .productName]![
                                                          id] = val!;
                                                    });
                                                  },
                                                ),
                                              ),
                                              DataCell(Text(d.catalogueNumber)),
                                              DataCell(Text(d.lotNumber)),
                                              DataCell(Text(d.numberOfHoles)),
                                              DataCell(Text(d.aklNumber)),
                                              DataCell(Text(
                                                  d.availableStockInIndonesia)),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                utils.customTextCancelButton(
                    onPressed: () {
                      Get.back();
                    },
                    btnName: 'Cancel',
                    textColor: Colors.red),
                utils.customElevatedFunctionButton(
                    onPressed: () async {
                      List<Map<String, dynamic>> selectedProducts = [];

                      selectedDetailsPerProduct
                          .forEach((productName, detailsMap) {
                        detailsMap.forEach((detailId, isSelected) {
                          if (isSelected) {
                            final detail = Get.find<ProductController>()
                                .productsDetails
                                .firstWhere((d) =>
                                    d.productName == productName &&
                                    d.catalogueNumber + d.lotNumber ==
                                        detailId);

                            selectedProducts.add({
                              "productUid": detail.productNameUid,
                              "detailsUid": detail.productDetailsUid,
                              "name": detail.productName,
                              "quantity": TextEditingController(),
                              "price": TextEditingController(),
                              "catalogueNumber": detail.catalogueNumber,
                              "lotNumber": detail.lotNumber,
                              "holes": detail.numberOfHoles,
                              "aklNumber": detail.aklNumber,
                              "availableQuantityInPakistan":
                                  detail.availableStockInPakistan,
                              "availableQuantityInIndonesia":
                                  detail.availableStockInIndonesia,
                              "totalStock": detail.totalAvailableStock
                            });
                          }
                        });
                      });
                      if (selectedProducts.isEmpty) {
                        utils.customSnackBar(
                            title: 'Error',
                            message:
                                'Please select atleast one product to proceed',
                            bgColor: Colors.red[200]);
                        return;
                      }
                      Get.back();
                      await generateBill(
                          customerUid: customerUid,
                          selectedProducts: selectedProducts,
                          customerName: customerName); // pass selected products
                    },
                    btnName: 'Proceed ->>',
                    bgColor: Colors.green[200],
                    fgColor: Colors.white)
              ],
            );
          },
        );
      },
    );
  }

// Updated generateBill
  Future generateBill({
    required String customerName,
    required String customerUid,
    required List<Map<String, dynamic>> selectedProducts,
  }) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Obx(() {
              if (isSavingBill.value) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(20),
                  content: Center(
                      heightFactor: 1,
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator())),
                );
              }
              return AlertDialog(
                title: Text('Generate Bill - $customerName'),
                content: SizedBox(
                  width: 600,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedProducts.length,
                    itemBuilder: (context, index) {
                      final product = selectedProducts[index];
                      final enteredQty =
                          int.tryParse(product["quantity"].text) ?? 0;
                      final availableQty = int.tryParse(
                              product['availableQuantityInIndonesia']
                                  .toString()) ??
                          0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Product name
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${product['name']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Catalogue #: ${product['catalogueNumber']}",
                                      style: const TextStyle(),
                                    ),
                                    Text(
                                      "Lot #: ${product['lotNumber']}",
                                      style: const TextStyle(),
                                    ),
                                    Text(
                                      'Available Stock: $availableQty',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              // Quantity field
                              Expanded(
                                flex: 1,
                                child: utils.customTextFormField(
                                    'Quantity', product["quantity"],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                  setState(() {}); // rebuild to update error
                                },
                                    errorText: enteredQty > availableQty
                                        ? 'Not enough stock available'
                                        : null),
                              ),
                              SizedBox(
                                width: 5,
                              ),

                              // Price field
                              Expanded(
                                flex: 1,
                                child: utils.customTextFormField(
                                  'Price',
                                  product["price"],
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  utils.customTextCancelButton(
                      onPressed: () {
                        Get.back();
                        clearFields();
                      },
                      btnName: 'Cancel',
                      textColor: Colors.red),
                  utils.customElevatedFunctionButton(
                      onPressed: () async {
                        try {
                          isSavingBill.value = true;
                          update();
                          // Validate quantities and prices before saving
                          for (var product in selectedProducts) {
                            final qty = int.tryParse(
                                    product["quantity"]?.text ?? '0') ??
                                0;
                            final price = double.tryParse(
                                    product["price"]?.text ?? '0') ??
                                0;
                            final availableQty = int.tryParse(
                                    product['availableQuantityInIndonesia']
                                            ?.toString() ??
                                        '0') ??
                                0;

                            if (qty <= 0) {
                              utils.customSnackBar(
                                  title: 'Error',
                                  message:
                                      'Quantity for ${product['name']} must be greater than 0',
                                  bgColor: Colors.red[200]);
                              return;
                            }

                            if (price <= 0) {
                              utils.customSnackBar(
                                  title: 'Error',
                                  message:
                                      'Price for ${product['name']} must be greater than 0',
                                  bgColor: Colors.red[200]);
                              return;
                            }

                            if (qty > availableQty) {
                              utils.customSnackBar(
                                  title: 'Error',
                                  message:
                                      'Quantity for ${product['name']} exceeds available stock',
                                  bgColor: Colors.red[200]);
                              return;
                            }
                          }

                          // Map selected products to BillItemModel
                          final billItems = selectedProducts.map((product) {
                            int quantity = int.tryParse(
                                    product["quantity"]?.text ?? '0') ??
                                0;
                            double price = double.tryParse(
                                    product["price"]?.text ?? '0') ??
                                0;
                            double total = quantity * price;

                            return BillItemModel(
                              productUid: product["productUid"]?.toString() ?? '',
                              productName: product["name"]?.toString() ?? '',
                              catalogueNumber:
                                  product["catalogueNumber"]?.toString() ?? '',
                              lotNumber: product["lotNumber"]?.toString() ?? '',
                              numberOfHoles: product["holes"]?.toString() ?? '',
                              aklNumber: product["aklNumber"]?.toString() ?? '',
                              quantity: quantity,
                              price: price,
                              total: total,
                            );
                          }).toList();

                          // Calculate total bill
                          final totalBill = billItems.fold<double>(
                              0, (sum, item) => sum + item.total);

                          final bill = BillModel(
                            billId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            createdAt: DateTime.now(),
                            totalBill: totalBill,
                            items: billItems,
                          );

                          // Save bill in database
                          await api.saveBill(
                            bill: bill,
                            customerUid: customerUid,
                            billUid: bill.billId,
                          );

                          // Update stock for each product
                          for (var product in selectedProducts) {
                            final qty = int.tryParse(
                                    product["quantity"]?.text ?? '0') ??
                                0;
                            final availableQty = int.tryParse(
                                    product['availableQuantityInIndonesia']
                                            ?.toString() ??
                                        '0') ??
                                0;
                            final totalStock = int.tryParse(
                                    product['totalStock']?.toString() ?? '0') ??
                                0;
                            final updatedStock = availableQty - qty;
                            final totalAvailableStock = totalStock - qty;

                            final detailUid =
                                product['detailsUid']?.toString() ?? '';
                            final productUid =
                                product['productUid']?.toString() ?? '';
                            final updatedStockString = updatedStock.toString();
                            final totalAvailableStockString =
                                totalAvailableStock.toString();

                            if (detailUid.isNotEmpty && productUid.isNotEmpty) {
                              await productApi.updateStockOnBill(
                                detailUid: detailUid,
                                productUid: productUid,
                                updatedStockOnSale: updatedStockString,
                                totalStock: totalAvailableStockString,
                              );
                            }
                          }

                          Get.back();
                          utils.customSnackBar(
                              title: 'Success',
                              message:
                                  'Bill to $customerName, Total Amount of $totalBill saved successfully!',
                              bgColor: Colors.green[200]);
                        } catch (e) {
                          utils.customSnackBar(
                              title: 'Error',
                              message: e.toString(),
                              bgColor: Colors.red[200]);
                        } finally {
                          isSavingBill.value = false;
                          update();
                        }
                      },
                      btnName: 'Save Bill',
                      bgColor: Colors.green[200],
                      fgColor: Colors.white)
                ],
              );
            });
          },
        );
      },
    );
  }
}
