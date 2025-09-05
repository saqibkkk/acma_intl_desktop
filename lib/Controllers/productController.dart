import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../APIs/productApi.dart';
import '../Models/productNamesModel.dart';
import '../Models/productModel.dart';
import '../utils.dart';

class ProductController extends GetxController {
  final ProductApi api = Get.put(ProductApi());
  final utils = Utils();
  var productsDetails = <ProductDetailsModel>[].obs;
  var productNames = <ProductNamesModel>[].obs;
  var isLoading = true.obs;

  // Text controllers
  final productNameController = TextEditingController();
  final catalogueNumberController = TextEditingController();
  final lotNumberController = TextEditingController();
  final holesController = TextEditingController();
  final aklNumberController = TextEditingController();
  final newProductName = TextEditingController();
  final newCatalogueNumberController = TextEditingController();
  final newLotNumberController = TextEditingController();
  final newHolesController = TextEditingController();
  final newAklNumberController = TextEditingController();
  final stockInPakistan = TextEditingController();
  final stockInIndonesia = TextEditingController();

  // inside ProductController
  var searchText = ''.obs;

  List<ProductDetailsModel> get filteredProducts {
    if (searchText.isEmpty) return productsDetails;
    return productsDetails
        .where((p) =>
            p.productName
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            p.catalogueNumber
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            p.lotNumber
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            p.aklNumber.toLowerCase().contains(searchText.value.toLowerCase()))
        .toList();
  }

  void clearFields() {
    productNameController.clear();
    catalogueNumberController.clear();
    lotNumberController.clear();
    holesController.clear();
    aklNumberController.clear();
    newAklNumberController.clear();
    newHolesController.clear();
    newLotNumberController.clear();
    newCatalogueNumberController.clear();
    newProductName.clear();
    stockInPakistan.clear();
    stockInIndonesia.clear();
  }

  @override
  void onClose() {
    productNameController.dispose();
    catalogueNumberController.dispose();
    lotNumberController.dispose();
    holesController.dispose();
    aklNumberController.dispose();
    newAklNumberController.dispose();
    newHolesController.dispose();
    newLotNumberController.dispose();
    newCatalogueNumberController.dispose();
    newProductName.dispose();
    stockInPakistan.dispose();
    stockInIndonesia.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchProductsDetails();
    fetchProductsNames();
  }

  Future<void> fetchProductsDetails() async {
    try {
      isLoading.value = true;
      update();

      productsDetails.value = await api.fetchProductsDetails();
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchProductsNames() async {
    try {
      isLoading.value = true;
      update();

      final data = await api.fetchProductNames();
      productNames.value = data.entries.map((e) {
        return ProductNamesModel(
          productName: e.value['productName'],
          productNameUid: e.value['productNameUid'],
        );
      }).toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future manageProducts() {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        String searchText = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Manage Products'),
              content: SizedBox(
                width: 700,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product Name'),
                              onPressed: () async {
                                await addProductNames();
                                setState(() {});
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product Details'),
                            onPressed: () async {
                              await addProductDetails();
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search Products...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
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
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final productsToShow = controller.productNames
                              .where((p) => p.productName
                                  .toLowerCase()
                                  .contains(searchText.toLowerCase()))
                              .toList();

                          if (productsToShow.isEmpty) {
                            return const Center(
                                child: Text('No Products Found'));
                          }

                          return ListView(
                            children: productsToShow.map((product) {
                              final details = controller.productsDetails
                                  .where((d) =>
                                      d.productName == product.productName)
                                  .toList();

                              return ExpansionTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(product.productName),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.green, size: 20),
                                          onPressed: () async {
                                            await editProductNames(
                                                currentName:
                                                    product.productName,
                                                productNameUid:
                                                    product.productNameUid);
                                            setState(() {});
                                            // Call edit product name function
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            // Call delete product name function
                                            await deleteProductNames(
                                                productNameUid:
                                                    product.productNameUid,
                                                productName:
                                                    product.productName);
                                            setState(() {}); // Refresh list
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  if (details.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('No Details Added'),
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                              label: Text('Catalogue Number')),
                                          DataColumn(label: Text('Lot Number')),
                                          DataColumn(label: Text('Holes')),
                                          DataColumn(label: Text('AKL Number')),
                                          DataColumn(label: Text('Actions')),
                                          // For edit/delete
                                        ],
                                        rows: details
                                            .map(
                                              (d) => DataRow(
                                                cells: [
                                                  DataCell(
                                                      Text(d.catalogueNumber)),
                                                  DataCell(Text(d.lotNumber)),
                                                  DataCell(
                                                      Text(d.numberOfHoles)),
                                                  DataCell(Text(d.aklNumber)),
                                                  DataCell(Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.edit,
                                                            color: Colors.green,
                                                            size: 18),
                                                        onPressed: () async {
                                                          // Call edit details function
                                                          await editProductDetails(
                                                              detail: d);
                                                          setState(() {});
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                            size: 18),
                                                        onPressed: () async {
                                                          // Call delete details function
                                                          await deleteProductDetails(
                                                              uid: d
                                                                  .productDetailsUid,
                                                              productUid: d
                                                                  .productNameUid,
                                                              catalogueNumber: d
                                                                  .catalogueNumber,
                                                              lotNumber:
                                                                  d.lotNumber,
                                                              productName: d
                                                                  .productName);
                                                          setState(
                                                              () {}); // Refresh table
                                                        },
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                            )
                                            .toList(),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future addProductDetails() {
    String? selectedProductName; // to store selected product
    String? selectedProductUid;
    String productDetailsUid = utils.generateRealtimeUid();
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Product Details'),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => DropdownButtonFormField<ProductNamesModel>(
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedProductName != null &&
                                selectedProductUid != null
                            ? productNames.firstWhere((p) =>
                                p.productName == selectedProductName &&
                                p.productNameUid == selectedProductUid)
                            : null,
                        items: productNames
                            .map((product) =>
                                DropdownMenuItem<ProductNamesModel>(
                                  value: product,
                                  child: Text(product.productName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          selectedProductName = value!.productName;
                          selectedProductUid = value.productNameUid;
                        },
                      )),
                  const SizedBox(height: 10),
                  utils.customTextFormField(
                      'Catalogue Number', catalogueNumberController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  utils.customTextFormField('Lot Number', lotNumberController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  utils.customTextFormField('Number of Holes', holesController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  utils.customTextFormField('AKL Number', aklNumberController),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () async {
                Get.back();
                clearFields();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                if (selectedProductName == null) {
                  Get.snackbar("Error", "Please select a product name",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                String catalogueNumber = catalogueNumberController.text.trim();
                String lotNumber = lotNumberController.text.trim();
                String numberOfHoles = holesController.text.trim();
                String aklNumber = aklNumberController.text.trim();

                // Check if the same product detail already exists
                bool exists = productsDetails.any((d) =>
                    d.productName == selectedProductName &&
                    d.catalogueNumber == catalogueNumber &&
                    d.lotNumber == lotNumber &&
                    d.numberOfHoles == numberOfHoles &&
                    d.aklNumber == aklNumber);

                if (exists) {
                  Get.snackbar("Error",
                      "These details are already added for this product",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                Get.back();

                ProductDetailsModel product = ProductDetailsModel(
                    productName: selectedProductName!,
                    catalogueNumber: catalogueNumber,
                    lotNumber: lotNumber,
                    numberOfHoles: numberOfHoles,
                    aklNumber: aklNumber,
                    availableStockInPakistan: '0',
                    availableStockInIndonesia: '0',
                    totalAvailableStock: '0',
                    productDetailsUid: productDetailsUid,
                    productNameUid: selectedProductUid!);

                // Save in database
                await api.saveProductDetails(
                    product: product,
                    productNameUid: selectedProductUid,
                    productDetailsUid: productDetailsUid);
                // // Update the observable list
                productsDetails.add(product);
                await fetchProductsDetails();
                clearFields();
              },
            ),
          ],
        );
      },
    );
  }

  Future editProductDetails({required ProductDetailsModel detail}) {
    // Pre-fill controllers
    newCatalogueNumberController.text = detail.catalogueNumber;
    newLotNumberController.text = detail.lotNumber;
    newHolesController.text = detail.numberOfHoles;
    newAklNumberController.text = detail.aklNumber;

    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Product Details'),
              SizedBox(
                height: 5,
              ),
              Text(detail.productName,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]))
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                utils.customTextFormField(
                  'Catalogue Number',
                  newCatalogueNumberController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                utils.customTextFormField(
                  'Lot Number',
                  newLotNumberController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                utils.customTextFormField(
                  'Number of Holes',
                  newHolesController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                utils.customTextFormField(
                  'AKL Number',
                  newAklNumberController,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                final newCat = newCatalogueNumberController.text.trim();
                final newLot = newLotNumberController.text.trim();
                final newHoles = newHolesController.text.trim();
                final newAKL = newAklNumberController.text.trim();

                // Check for duplicate details (excluding current editing node)
                bool exists = productsDetails.any((d) =>
                    d.catalogueNumber == newCat &&
                    d.lotNumber == newLot &&
                    d.numberOfHoles == newHoles &&
                    d.aklNumber == newAKL);

                if (exists) {
                  Get.snackbar(
                    'Error',
                    'These details already exist for this product',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                Get.back();
                // Update the correct node in Firebase using REST API
                await api.editProductDetails(
                  detailUid: detail.productDetailsUid,
                  productUid: detail.productNameUid,
                  newCatNumber: newCat,
                  newLotNumber: newLot,
                  newHolesNumber: newHoles,
                  newAKLNumber: newAKL,
                );

                // Refresh local lists
                await fetchProductsNames();
                await fetchProductsDetails();
                clearFields();
              },
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            )
          ],
        );
      },
    );
  }

  Future deleteProductNames(
      {required String productNameUid, required String productName}) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
                width: 500,
                child: Text(
                    'Are you sure?\nAll Data of product: $productName will be deleted permanently!')),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  // Close the add product dialog
                  Get.back();
                  await api.deleteProduct(productNameUid: productNameUid);
                  await fetchProductsNames();
                  await fetchProductsDetails();
                },
                child: Text('Delete')),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Cancel'))
          ],
        );
      },
    );
  }

  Future addProductNames() {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: Container(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                utils.customTextFormField(
                  'Product Name',
                  productNameController,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () async {
                Get.back();
                clearFields();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                String inputName =
                    productNameController.text.trim().toUpperCase();

                if (inputName.isEmpty) {
                  Get.snackbar("Error", "Product name cannot be empty",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                bool exists = productNames.any(
                  (p) => p.productName.toUpperCase() == inputName,
                );

                if (exists) {
                  Get.snackbar("Error", "Product already available",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                Get.back();
                await api.saveProductNames(productName: inputName);
                await fetchProductsNames();
                clearFields();
              },
            )
          ],
        );
      },
    );
  }

  Future editProductNames(
      {required String currentName, required String productNameUid}) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $currentName'),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  utils.customTextFormField(
                    currentName,
                    newProductName,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () async {
                Get.back();
                clearFields();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                String inputName = newProductName.text.trim().toUpperCase();

                // Check if the product already exists
                bool exists = productNames
                    .any((p) => p.productName.toUpperCase() == inputName);

                if (inputName.isEmpty) {
                  Get.snackbar("Error", "Product name cannot be empty",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                if (exists) {
                  Get.snackbar("Error", "Product already available",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                Get.back();
                // Save the product name in capital letters
                await api.editProductNames(
                    newProductName: inputName, productNameUid: productNameUid);

                // Refresh product names list
                await fetchProductsNames();
                await fetchProductsDetails();
                clearFields();
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteProductDetails(
      {required String uid,
      required String productUid,
      required String catalogueNumber,
      required String lotNumber,
      required String productName}) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product Detail'),
          content: Text(
              'Are you sure?\nCatalogue Number: $catalogueNumber\nLot Number: $lotNumber\nof Product: $productName will be permanently deleted!'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Cancel')),
            Container(
              width: 500,
              child: Row(
                children: [
                  TextButton(
                      onPressed: () async {
                        Get.back();
                        await api.deleteProductDetails(
                            productUid: productUid, uid: uid);
                        await fetchProductsNames();
                        await fetchProductsDetails();
                      },
                      child: Text('Delete')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
