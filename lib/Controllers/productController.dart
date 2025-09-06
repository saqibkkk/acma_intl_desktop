import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../APIs/productApi.dart';
import '../Models/productNamesModel.dart';
import '../Models/productModel.dart';
import '../Pages/searchableDropdownMenu.dart';
import '../utils.dart';

class ProductController extends GetxController {
  final ProductApi api = Get.put(ProductApi());
  final Utils utils = Utils();
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
                            child: utils.customElevatedFunctionButton(
                                onPressed: () async {
                                  await addProductNames();
                                },
                                btnName: 'Add New Product',
                                bgColor: Colors.blueGrey,
                                fgColor: Colors.white)),
                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: utils.customElevatedFunctionButton(
                                onPressed: () async {
                                  await addProductDetails();
                                },
                                btnName: 'Add Product Details',
                                bgColor: Colors.blueGrey,
                                fgColor: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
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

                    const SizedBox(height: 10),

                    // Products list
                    Expanded(
                      child: GetBuilder<ProductController>(
                        builder: (controller) {
                          if (controller.isLoading.value) {
                            return Center(
                                child:
                                    utils.customCircularProgressingIndicator());
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

                              return ExpansionTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                                              productName:
                                                                  d.productName,
                                                              noOfHoles: d
                                                                  .numberOfHoles,
                                                              aklNumber:
                                                                  d.aklNumber);
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
                utils.customTextCancelButton(
                    onPressed: () {
                      Get.back();
                    },
                    btnName: 'Close',
                    textColor: Colors.red),
              ],
            );
          },
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
                  'Are you sure?'
                  '\n\nComplete data of product: $productName will be deleted permanently!',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                )),
          ),
          actions: [
            utils.customTextCancelButton(
                onPressed: () async {
                  Get.back();
                  await api.deleteProduct(productNameUid: productNameUid);
                  utils.customSnackBar(
                      title: 'Success',
                      message:
                          'All Data $productName has been deleted permanently!',
                      bgColor: Colors.green[200]);
                  await fetchProductsNames();
                  await fetchProductsDetails();
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
                  String inputName =
                      productNameController.text.trim().toUpperCase();
                  if (inputName.isEmpty) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'Product name must not be empty',
                        bgColor: Colors.red[200]);
                    return;
                  }
                  bool exists = productNames.any(
                    (p) => p.productName.toUpperCase() == inputName,
                  );
                  if (exists) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'Product name already available',
                        bgColor: Colors.red[200]);
                    return;
                  }
                  Get.back();
                  await api.saveProductNames(productName: inputName);
                  utils.customSnackBar(
                      title: 'Success',
                      message: 'New product - $inputName has been added',
                      bgColor: Colors.green[200]);
                  await fetchProductsNames();
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

  Future editProductNames(
      {required String currentName, required String productNameUid}) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit - $currentName'),
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
            utils.customTextCancelButton(
                onPressed: () {
                  Get.back();
                  clearFields();
                },
                btnName: 'Cancel',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () async {
                  String inputName = newProductName.text.trim().toUpperCase();

                  // Check if the product already exists
                  bool exists = productNames
                      .any((p) => p.productName.toUpperCase() == inputName);

                  if (inputName.isEmpty) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: "Product name cannot be empty",
                        bgColor: Colors.red[200]);
                    return;
                  }

                  if (exists) {
                    utils.customSnackBar(
                        title: "Error",
                        message: "Product already available",
                        bgColor: Colors.red[200]);

                    return;
                  }
                  Get.back();
                  // Save the product name in capital letters
                  await api.editProductNames(
                      newProductName: inputName,
                      productNameUid: productNameUid);
                  utils.customSnackBar(
                      title: 'Success',
                      message:
                          'Product name $currentName has been changed to $inputName',
                      bgColor: Colors.green[200]);
                  // Refresh product names list
                  await fetchProductsNames();
                  await fetchProductsDetails();
                  clearFields();
                },
                btnName: 'Save',
                bgColor: Colors.green[200],
                fgColor: Colors.red),
          ],
        );
      },
    );
  }

  Future addProductDetails() {
    String? selectedProductName;
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
                  SearchableDropdown<ProductNamesModel>(
                    label: 'Product Name',
                    items: productNames,
                    itemAsString: (p) => p.productName,
                    selectedItem: selectedProductUid != null
                        ? productNames.firstWhere(
                            (p) => p.productNameUid == selectedProductUid)
                        : null,
                    onChanged: (value) {
                      selectedProductName = value?.productName;
                      selectedProductUid = value?.productNameUid;
                    },
                  ),
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
            utils.customTextCancelButton(
                onPressed: () {
                  Get.back();
                  clearFields();
                },
                btnName: 'Cancel',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () async {
                  if (selectedProductName == null) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'Please select a product name',
                        bgColor: Colors.red[200]);
                    return;
                  }

                  String catalogueNumber =
                      catalogueNumberController.text.trim();
                  String lotNumber = lotNumberController.text.trim();
                  String numberOfHoles = holesController.text.trim();
                  String aklNumber = aklNumberController.text.trim();

                  if (catalogueNumber.isEmpty ||
                      lotNumber.isEmpty ||
                      numberOfHoles.isEmpty ||
                      aklNumber.isEmpty) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'All fields are required',
                        bgColor: Colors.red[200]);
                    return;
                  }
                  // Check if the same product detail already exists
                  bool exists = productsDetails.any((d) =>
                      d.productName == selectedProductName &&
                      d.catalogueNumber == catalogueNumber &&
                      d.lotNumber == lotNumber &&
                      d.numberOfHoles == numberOfHoles &&
                      d.aklNumber == aklNumber);

                  if (exists) {
                    utils.customSnackBar(
                        title: 'Error',
                        message:
                            'Entered details are already added for this product',
                        bgColor: Colors.red[200]);
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
                  utils.customSnackBar(
                      title: 'Success',
                      message:
                          'New details of the product $selectedProductName has been added',
                      bgColor: Colors.green[200]);
                  // // Update the observable list
                  productsDetails.add(product);
                  await fetchProductsDetails();
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
            utils.customTextCancelButton(
                onPressed: () {
                  Get.back();
                  clearFields();
                },
                btnName: 'Cancel',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () async {
                  final newCat = newCatalogueNumberController.text.trim();
                  final newLot = newLotNumberController.text.trim();
                  final newHoles = newHolesController.text.trim();
                  final newAKL = newAklNumberController.text.trim();

                  if (newCat.isEmpty ||
                      newLot.isEmpty ||
                      newHoles.isEmpty ||
                      newAKL.isEmpty) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'All fields are required',
                        bgColor: Colors.red[200]);
                    return;
                  }

                  // Check for duplicate details (excluding current editing node)
                  bool exists = productsDetails.any((d) =>
                      d.catalogueNumber == newCat &&
                      d.lotNumber == newLot &&
                      d.numberOfHoles == newHoles &&
                      d.aklNumber == newAKL);

                  if (exists) {
                    utils.customSnackBar(
                        title: 'Error',
                        message:
                            'Entered details already exist for this product',
                        bgColor: Colors.red[200]);
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
                  utils.customSnackBar(
                      title: 'Success',
                      message:
                          'Details of the product ${detail.productName} has been edited',
                      bgColor: Colors.green[200]);
                  // Refresh local lists
                  await fetchProductsNames();
                  await fetchProductsDetails();
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

  Future deleteProductDetails(
      {required String uid,
      required String productUid,
      required String catalogueNumber,
      required String lotNumber,
      required String noOfHoles,
      required String aklNumber,
      required String productName}) {
    return showDialog(
      context: Get.context!,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product Detail'),
          content: Text(
            'Are you sure?'
            '\n\nCatalogue Number: $catalogueNumber,'
            '\nLot Number: $lotNumber,'
            '\nNumber of Holes: $noOfHoles and'
            '\nAKL Number: $aklNumber,'
            '\nof Product: $productName will be permanently deleted!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            utils.customTextCancelButton(
                onPressed: () async {
                  Get.back();
                  await api.deleteProductDetails(
                      productUid: productUid, uid: uid);
                  utils.customSnackBar(
                      title: 'Success',
                      message:
                          'Product details of the product: $productName has been deleted permanently',
                      bgColor: Colors.green[200]);
                  await fetchProductsNames();
                  await fetchProductsDetails();
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
}
