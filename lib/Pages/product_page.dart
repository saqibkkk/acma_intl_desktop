import 'package:acma_intl_desktop/Pages/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Controllers/productController.dart';
import '../Models/productModel.dart';
import '../APIs/productApi.dart';
import '../utils.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final productController = Get.put(ProductController());
  final stockApi = Get.put(ProductApi());
  final Utils utils = Utils();
  final TextEditingController searchController = TextEditingController();
  bool internetAvailable = true;
  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    internetAvailable = await Utils.isInternetAvailable();
    if (!internetAvailable) {
      _showNoInternetSnack();
    } else {
      await productController.fetchProductsDetails();
      await productController.fetchProductsNames();
    }
    setState(() {});
  }

  void _showNoInternetSnack() {
    utils.customSnackBar(
        title: 'No Internet',
        message: 'Internet connection is not available.',
        bgColor: Colors.red[200]);
  }

  void _sort<T>(
    Comparable<T> Function(ProductDetailsModel product) getField,
    int columnIndex,
    bool ascending,
  ) {
    productController.productsDetails.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      if (aValue is String && bValue is String) {
        final aInt = int.tryParse(aValue as String);
        final bInt = int.tryParse(bValue as String);
        if (aInt != null && bInt != null) {
          return ascending ? aInt.compareTo(bInt) : bInt.compareTo(aInt);
        }
      }

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
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
                      productController.manageProducts();
                    },
                    btnName: 'Manage Products',
                    bgColor: Colors.blueGrey,
                    fgColor: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Products...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                productController.searchText.value = value;
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
              if (productController.isLoading.value) {
                return Center(
                    child: utils.customCircularProgressingIndicator());
              }
              if (productController.productsDetails.isEmpty) {
                return const Center(
                  child: Text(
                    'No Products Found!',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return Column(
                children: [
                  // Fixed header above table
                  Container(
                    color: Colors.blueGrey,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 3,
                            child: Text('Product Name',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        const Expanded(
                            flex: 2,
                            child: Text('Catalogue Number',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        const Expanded(
                            flex: 2,
                            child: Text('Lot Number',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        const Expanded(
                            flex: 1,
                            child: Text('Holes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        const Expanded(
                            flex: 2,
                            child: Text('AKL Number',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => _sort(
                                (p) => p.availableStockInPakistan,
                                5,
                                !_isAscending),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pakistan',
                                  style: TextStyle(
                                    color: _sortColumnIndex == 5
                                        ? Colors.red
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_sortColumnIndex == 5)
                                  Icon(
                                    _isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => _sort(
                                (p) => p.availableStockInIndonesia,
                                6,
                                !_isAscending),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Indonesia',
                                  style: TextStyle(
                                    color: _sortColumnIndex == 6
                                        ? Colors.red
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_sortColumnIndex == 6)
                                  Icon(
                                    _isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => _sort(
                                (p) => p.totalAvailableStock, 7, !_isAscending),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total Stock',
                                  style: TextStyle(
                                    color: _sortColumnIndex == 7
                                        ? Colors.red
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_sortColumnIndex == 7)
                                  Icon(
                                    _isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Expanded(
                            flex: 2,
                            child: Align(
                                alignment: Alignment.center,
                                child: Text('Actions',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            productController.filteredProducts.map((product) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: _fancyCell(product.productName)),
                                Expanded(
                                    flex: 2,
                                    child: _fancyCell(product.catalogueNumber)),
                                Expanded(
                                    flex: 2,
                                    child: _fancyCell(product.lotNumber)),
                                Expanded(
                                    flex: 1,
                                    child: _fancyCell(product.numberOfHoles)),
                                Expanded(
                                    flex: 2,
                                    child: _fancyCell(product.aklNumber)),
                                Expanded(
                                    flex: 1,
                                    child: _stockCell(
                                        product.availableStockInPakistan)),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: _stockCell(
                                        product.availableStockInIndonesia)),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: _stockCell(
                                        product.totalAvailableStock)),
                                Expanded(
                                  flex: 2,
                                  child: utils.customTextCancelButton(
                                    onPressed: () async {
                                      await addStockInPakistan(
                                        productNameUid: product.productNameUid,
                                        productDetailsUid:
                                            product.productDetailsUid,
                                        existingStockInPakistan:
                                            product.availableStockInPakistan,
                                        existingStockInIndonesia:
                                            product.availableStockInIndonesia,
                                        productName: product.productName,
                                      );
                                    },
                                    btnName: 'Manage Stock',
                                    textColor: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
              // return SizedBox(
              //  width: MediaQuery.of(context).size.width,
              //  child: IconTheme(
              //    data: const IconThemeData(
              //      color: Colors.red,
              //    ),
              //    child: DataTable(
              //      sortAscending: _isAscending,
              //      sortColumnIndex: _sortColumnIndex,
              //      headingRowHeight: 40,
              //      dataRowHeight: 40,
              //      dataTextStyle: TextStyle(fontWeight: FontWeight.bold),
              //      headingRowColor:
              //      MaterialStateProperty.resolveWith<Color?>((states) {
              //        return Colors.blueGrey; // default heading background
              //      }),
              //      columns: [
              //        const DataColumn(
              //            label: Text(
              //              'Product Name',
              //              style: TextStyle(
              //                  fontWeight: FontWeight.bold, color: Colors.white),
              //            )),
              //        const DataColumn(
              //            label: Text(
              //              'Catalogue Number',
              //              style: TextStyle(
              //                  fontWeight: FontWeight.bold, color: Colors.white),
              //            )),
              //        const DataColumn(
              //            label: Text(
              //              'Lot Number',
              //              style: TextStyle(
              //                  fontWeight: FontWeight.bold, color: Colors.white),
              //            )),
              //        const DataColumn(
              //            label: Text(
              //              'Number of Holes',
              //              style: TextStyle(
              //                  fontWeight: FontWeight.bold, color: Colors.white),
              //            )),
              //        const DataColumn(
              //            label: Text(
              //              'AKL Number',
              //              style: TextStyle(
              //                  fontWeight: FontWeight.bold, color: Colors.white),
              //            )),
              //        DataColumn(
              //          label: Text(
              //            'Pakistan',
              //            style: TextStyle(
              //              fontWeight: FontWeight.bold,
              //              color: _sortColumnIndex == 5
              //                  ? Colors.red
              //                  : Colors.white,
              //            ),
              //          ),
              //          numeric: true,
              //          onSort: (i, asc) =>
              //              _sort((p) => p.availableStockInPakistan, i, asc),
              //        ),
              //        DataColumn(
              //          label: Text(
              //            'Indonesia',
              //            style: TextStyle(
              //              fontWeight: FontWeight.bold,
              //              color: _sortColumnIndex == 6
              //                  ? Colors.red
              //                  : Colors.white,
              //            ),
              //          ),
              //          numeric: true,
              //          onSort: (i, asc) =>
              //              _sort((p) => p.availableStockInIndonesia, i, asc),
              //        ),
              //        DataColumn(
              //          label: Text(
              //            'Total Stock',
              //            style: TextStyle(
              //              fontWeight: FontWeight.bold,
              //              color: _sortColumnIndex == 7
              //                  ? Colors.red
              //                  : Colors.white,
              //            ),
              //          ),
              //          numeric: true,
              //          onSort: (i, asc) =>
              //              _sort((p) => p.totalAvailableStock, i, asc),
              //        ),
              //        const DataColumn(
              //            label: Text(
              //              'Actions',
              //              style: TextStyle(
              //                  fontWeight: FontWeight.bold, color: Colors.white),
              //            )),
              //      ],
              //      rows: productController.filteredProducts.map((product) {
              //        return DataRow(
              //          cells: [
              //            _fancyCell(product.productName),
              //            _fancyCell(product.catalogueNumber),
              //            _fancyCell(product.lotNumber),
              //            _fancyCell(product.numberOfHoles),
              //            _fancyCell(product.aklNumber),
              //            _stockCell(product.availableStockInPakistan),
              //            _stockCell(product.availableStockInIndonesia),
              //            _stockCell(product.totalAvailableStock),
              //            DataCell(utils.customTextCancelButton(
              //                onPressed: () async {
              //                  if (!internetAvailable) {
              //                    _showNoInternetSnack();
              //                    return;
              //                  }
              //                  await addStockInPakistan(
              //                      productNameUid: product.productNameUid,
              //                      productDetailsUid:
              //                      product.productDetailsUid,
              //                      existingStockInPakistan:
              //                      product.availableStockInPakistan,
              //                      existingStockInIndonesia:
              //                      product.availableStockInIndonesia,
              //                      productName: product.productName);
              //                },
              //                btnName: 'Manage Stock',
              //                textColor: Colors.blue)),
              //          ],
              //        );
              //      }).toList(),
              //    ),
              //  ));
            }),
          ),
        ],
      ),
    );
  }

  // Returns a Widget instead of DataCell
  Widget _fancyCell(String? text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text ?? "-",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _stockCell(String value) {
    int stock = int.tryParse(value) ?? 0;
    Color color;
    Icon icon;
    if (stock == 0) {
      color = Colors.red.shade100;
      icon = const Icon(Icons.close, color: Colors.red, size: 16);
    } else if (stock < 100) {
      color = Colors.orange.shade100;
      icon = const Icon(Icons.warning, color: Colors.orange, size: 16);
    } else {
      color = Colors.green.shade100;
      icon = const Icon(Icons.check, color: Colors.green, size: 16);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 6),
            Text(value),
          ],
        ),
      ),
    );
  }

  Future addStockInPakistan(
      {required String productNameUid,
      required String productDetailsUid,
      required String existingStockInPakistan,
      required String existingStockInIndonesia,
      required String productName}) {
    final productController = Get.put(ProductController());
    final utils = Utils();
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Stock Quantity'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    productName,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  IconButton(
                    onPressed: () async {
                      Get.back();
                      await convertPakStockToIndonesia(
                          productNameUid: productNameUid,
                          productDetailsUid: productDetailsUid,
                          existingStockInPakistan: existingStockInPakistan,
                          existingStockInIndonesia: existingStockInIndonesia,
                          productName: productName);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: utils.customTextFormField(
              'Add Stock (Pakistan)',
              productController.stockInPakistan,
              keyboardType: TextInputType.number,
            ),
          ),
          actions: [
            utils.customTextCancelButton(
                onPressed: () {
                  Get.back();
                  productController.clearFields();
                },
                btnName: 'Cancel',
                textColor: Colors.red),
            utils.customElevatedFunctionButton(
                onPressed: () async {
                  // user input
                  int newPakStock =
                      int.tryParse(productController.stockInPakistan.text) ?? 0;
                  int existingPakStock =
                      int.tryParse(existingStockInPakistan) ?? 0;
                  int updatedPakStock = existingPakStock + newPakStock;
                  int existingIndoStock =
                      int.tryParse(existingStockInIndonesia) ?? 0;
                  final totalUpdatedStock = updatedPakStock + existingIndoStock;
                  if (newPakStock <= 0) {
                    utils.customSnackBar(
                        title: 'Error',
                        message: 'Stock quantity must be greater than 0',
                        bgColor: Colors.red[200]);
                    return;
                  }
                  Get.back();
                  await stockApi.addPakStock(
                      productNameUid: productNameUid,
                      productDetailsUid: productDetailsUid,
                      stockInPakistan: updatedPakStock.toString(),
                      totalAvailableStock: totalUpdatedStock.toString());
                  utils.customSnackBar(
                      title: 'Success',
                      message:
                          '$newPakStock quantity has been added for $productName',
                      bgColor: Colors.green[200]);
                  // refresh list
                  await productController.fetchProductsDetails();
                  productController.clearFields();
                },
                btnName: 'Save',
                bgColor: Colors.green[200],
                fgColor: Colors.white)
          ],
        );
      },
    );
  }

  Future convertPakStockToIndonesia({
    required String productName,
    required String productNameUid,
    required String productDetailsUid,
    required String existingStockInPakistan,
    required String existingStockInIndonesia,
  }) {
    final productController = Get.put(ProductController());
    final utils = Utils();
    return showDialog(
      useSafeArea: true,
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final enteredQty =
                int.tryParse(productController.stockInIndonesia.text) ?? 0;
            final existingPakStock = int.tryParse(existingStockInPakistan) ?? 0;

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Convert Ready To Deliver Stock'),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    productName,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  )
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    utils.customTextFormField(
                      'Convert Stock (Pakistan to Indonesia)',
                      productController.stockInIndonesia,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {}); // rebuild to show/hide error
                      },
                      errorText: enteredQty > existingPakStock
                          ? 'Not enough stock available'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Ready to deliver stock: $existingStockInPakistan'),
                    ),
                  ],
                ),
              ),
              actions: [
                utils.customTextCancelButton(
                    onPressed: () async {
                      Get.back();
                      productController.clearFields();
                    },
                    btnName: 'Close',
                    textColor: Colors.red),
                utils.customElevatedFunctionButton(
                    onPressed: () async {
                      final newEnteredStockInIndonesia = int.tryParse(
                              productController.stockInIndonesia.text) ??
                          0;
                      final existingStockPakistan =
                          int.tryParse(existingStockInPakistan) ?? 0;

                      if (newEnteredStockInIndonesia > existingStockPakistan) {
                        utils.customSnackBar(
                            title: 'Error',
                            message: 'Not enough stock available',
                            bgColor: Colors.red[200]);
                        return;
                      }
                      if (newEnteredStockInIndonesia <= 0) {
                        utils.customSnackBar(
                            title: 'Error',
                            message: 'Stock quantity must be greater than 0',
                            bgColor: Colors.red[200]);
                        return;
                      }

                      final updatedPakStock =
                          existingStockPakistan - newEnteredStockInIndonesia;
                      final newIndStock = int.tryParse(
                              productController.stockInIndonesia.text) ??
                          0;
                      final existingIndStock =
                          int.tryParse(existingStockInIndonesia) ?? 0;

                      final updatedIndStock = existingIndStock + newIndStock;
                      final totalStock = updatedPakStock + updatedIndStock;
                      await stockApi.convertPakToIndo(
                        productNameUid: productNameUid,
                        productDetailsUid: productDetailsUid,
                        stockInPakistan: updatedPakStock.toString(),
                        stockInIndonesia: updatedIndStock.toString(),
                        totalAvailableStock: totalStock.toString(),
                      );
                      Get.back();
                      utils.customSnackBar(
                          title: 'Success',
                          message:
                              '$newEnteredStockInIndonesia has been successfully delivered from Pakistan to Indonesia for $productName',
                          bgColor: Colors.green[200]);
                      // refresh list
                      await productController.fetchProductsDetails();
                      productController.clearFields();
                    },
                    btnName: 'Save',
                    bgColor: Colors.green[200],
                    fgColor: Colors.white)
              ],
            );
          },
        );
      },
    );
  }
}
