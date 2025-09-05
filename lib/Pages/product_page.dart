import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Controllers/productController.dart';
import '../Models/productModel.dart';
import '../APIs/productApi.dart';
import '../utils.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final productController = Get.put(ProductController());
  final stockApi = Get.put(ProductApi());
  final TextEditingController searchController = TextEditingController();

  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    productController.fetchProductsDetails();
    productController.fetchProductsNames();
  }

  void _sort<T>(Comparable<T> Function(ProductDetailsModel product) getField,
      int columnIndex, bool ascending) {
    productController.productsDetails.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
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
                  productController.manageProducts();
                },
                child: const Text('Manage Product')),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
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

          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.indigoAccent,
                ));
              }
              if (productController.productsDetails.isEmpty) {
                return const Center(child: Text("No products found."));
              }

              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  sortAscending: _isAscending,
                  sortColumnIndex: _sortColumnIndex,
                  headingRowHeight: 60,
                  dataRowHeight: 40,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.blue.shade100),
                  columns: [
                    const DataColumn(label: Text('Product Name')),
                    const DataColumn(label: Text('Catalogue Number')),
                    const DataColumn(label: Text('Lot Number')),
                    const DataColumn(label: Text('Number of Holes')),
                    const DataColumn(label: Text('AKL Number')),
                    DataColumn(
                      label: const Text('Pakistan'),
                      numeric: true,
                      onSort: (i, asc) =>
                          _sort((p) => p.availableStockInPakistan, i, asc),
                    ),
                    DataColumn(
                      label: const Text('Indonesia'),
                      numeric: true,
                      onSort: (i, asc) =>
                          _sort((p) => p.availableStockInIndonesia, i, asc),
                    ),
                    DataColumn(
                      label: const Text('Total Stock'),
                      numeric: true,
                      onSort: (i, asc) =>
                          _sort((p) => p.totalAvailableStock, i, asc),
                    ),
                    const DataColumn(
                        label: Text('Actions')), // <-- New column for button
                  ],
                  rows: productController.filteredProducts.map((product) {
                    return DataRow(
                      cells: [
                        _fancyCell(product.productName),
                        _fancyCell(product.catalogueNumber),
                        _fancyCell(product.lotNumber),
                        _fancyCell(product.numberOfHoles),
                        _fancyCell(product.aklNumber),
                        _stockCell(product.availableStockInPakistan),
                        _stockCell(product.availableStockInIndonesia),
                        _stockCell(product.totalAvailableStock),
                        DataCell(
                          TextButton(
                            onPressed: () async {
                              await addStockInPakistan(
                                  productNameUid: product.productNameUid,
                                  productDetailsUid: product.productDetailsUid,
                                  existingStockInPakistan:
                                      product.availableStockInPakistan,
                                  existingStockInIndonesia:
                                      product.availableStockInIndonesia,
                                  productName: product.productName);
                            },
                            child: const Text("More"),
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

  DataCell _stockCell(String value) {
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

    return DataCell(
      MouseRegion(
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
                  Text(productName, style: TextStyle(fontSize: 16,color: Colors.grey[800]),),
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
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          content:

          Container(
            width: 400,
            child: utils.customTextFormField(
                'Add Stock (Pakistan)', productController.stockInPakistan,
                keyboardType: TextInputType.number),
          ),
          actions: [
            ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Get.back();
                  productController.clearFields();
                }),
            ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: () async {
                  // user input
                  int newPakStock =
                      int.tryParse(productController.stockInPakistan.text) ?? 0;
                  int existingPakStock =
                      int.tryParse(existingStockInPakistan) ?? 0;
                  int updatedPakStock = existingPakStock + newPakStock;
                  Get.back();
                  await stockApi.addPakStock(
                      productNameUid: productNameUid,
                      productDetailsUid: productDetailsUid,
                      stockInPakistan: updatedPakStock.toString(),
                      totalAvailableStock: updatedPakStock.toString());
                  // refresh list
                  await productController.fetchProductsDetails();
                  productController.clearFields();
                }),
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
                  SizedBox(height: 5,),
                  Text(productName, style: TextStyle(fontSize: 16,color: Colors.grey[800]),)
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
                ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () async {
                    Get.back();
                    productController.clearFields();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () async {
                    final newEnteredStockInIndonesia =
                        int.tryParse(productController.stockInIndonesia.text) ??
                            0;
                    final existingStockPakistan =
                        int.tryParse(existingStockInPakistan) ?? 0;

                    if (newEnteredStockInIndonesia > existingStockPakistan) {
                      Get.snackbar("Error",
                          "Quantity exceeds from ready to deliver stock");
                      return;
                    }

                    final updatedPakStock =
                        existingStockPakistan - newEnteredStockInIndonesia;
                    final newIndStock =
                        int.tryParse(productController.stockInIndonesia.text) ??
                            0;
                    final existingIndStock =
                        int.tryParse(existingStockInIndonesia) ?? 0;

                    final updatedIndStock = existingIndStock + newIndStock;
                    final totalStock = updatedPakStock + updatedIndStock;

                    Get.back();

                    await stockApi.convertPakToIndo(
                      productNameUid: productNameUid,
                      productDetailsUid: productDetailsUid,
                      stockInPakistan: updatedPakStock.toString(),
                      stockInIndonesia: updatedIndStock.toString(),
                      totalAvailableStock: totalStock.toString(),
                    );

                    // refresh list
                    await productController.fetchProductsDetails();
                    productController.clearFields();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
