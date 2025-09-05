import 'dart:convert';
import 'package:acma_intl_desktop/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Models/productModel.dart';
import '../utils.dart';

class ProductApi extends GetxController {
  // Save stock to Firebase via REST
  final utils = Utils();

  Future<void> saveProductNames({required String productName}) async {
    String productNameUid = utils.generateRealtimeUid();
    final String fullUrl = '$url/AllProducts/$productNameUid.json';
    final response = await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(
          {'productName': productName, 'productNameUid': productNameUid}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save product: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchProductNames() async {
    final String fullUrl = '$url/AllProducts.json';
    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic>? data = json.decode(response.body);
        return data ?? {};
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return {};
    }
  }

  Future<void> editProductNames({
    required String productNameUid,
    required String newProductName,
  }) async {
    final String productUrl = '$url/AllProducts/$productNameUid.json';
    final String detailsUrl = '$url/AllProducts/$productNameUid/Details.json';

    try {
      // 1️⃣ Update the main product name
      final productResponse = await http.patch(
        Uri.parse(productUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'productName': newProductName}),
      );

      if (productResponse.statusCode != 200) {
        throw Exception(
            'Failed to update main product: ${productResponse.statusCode}');
      }

      // 2️⃣ Fetch all details
      final detailsResponse = await http.get(Uri.parse(detailsUrl));
      if (detailsResponse.statusCode == 200) {
        Map<String, dynamic>? detailsData = json.decode(detailsResponse.body);

        if (detailsData != null) {
          // Iterate over each detail UID
          for (var detailUid in detailsData.keys) {
            final detailPatchUrl =
                '$url/AllProducts/$productNameUid/Details/$detailUid.json';
            await http.patch(
              Uri.parse(detailPatchUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'productName': newProductName}),
            );
          }
        }
      } else {
        throw Exception(
            'Failed to fetch product details: ${detailsResponse.statusCode}');
      }
    } catch (e) {
      print('Error updating product and details: $e');
    }
  }

  Future<void> deleteProduct({required String productNameUid}) async {
    final String fullUrl = '$url/AllProducts/$productNameUid.json';
    final response = await http.delete(Uri.parse(fullUrl));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete product: ${response.body}");
    }
  }

  Future<void> saveProductDetails(
      {required ProductDetailsModel product,
      required productNameUid,
      required productDetailsUid}) async {
    final String fullUrl =
        '$url/AllProducts/$productNameUid/Details/$productDetailsUid.json';
    final response = await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to save product: ${response.body}");
    }
  }

  Future<List<ProductDetailsModel>> fetchProductsDetails() async {
    final url2 = Uri.parse('$url/AllProducts.json');
    final response = await http.get(url2);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      List<ProductDetailsModel> products = [];

      if (data != null) {
        data.forEach((uidKey, uidValue) {
          if (uidValue is Map && uidValue['Details'] is Map) {
            final details = uidValue['Details'] as Map<String, dynamic>;
            details.forEach((detailKey, detailValue) {
              if (detailValue is Map<String, dynamic>) {
                // Add UID from parent if needed
                detailValue['uid'] = uidKey;
                products.add(ProductDetailsModel.fromJson(detailValue));
              }
            });
          }
        });
      }

      return products;
    }

    return [];
  }

  Future<void> editProductDetails({
    required String detailUid,
    required String productUid,
    required String newCatNumber,
    required String newLotNumber,
    required String newHolesNumber,
    required String newAKLNumber,
  }) async {
    final String detailsUrl =
        '$url/AllProducts/$productUid/Details/$detailUid.json';

    try {
      final response = await http.patch(
        Uri.parse(detailsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'catalogueNumber': newCatNumber,
          'lotNumber': newLotNumber,
          'numberOfHoles': newHolesNumber,
          'aklNumber': newAKLNumber,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product details: $e');
    }
  }

  Future<void> deleteProductDetails(
      {required String productUid, required String uid}) async {
    final String fullUrl = '$url/AllProducts/$productUid/Details/$uid.json';
    final response = await http.delete(Uri.parse(fullUrl));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete product: ${response.body}");
    }
  }

  Future<void> addPakStock(
      {required String productNameUid,
      required String productDetailsUid,
      required String stockInPakistan,
      required String totalAvailableStock}) async {
    final String dbUrl =
        '$url/AllProducts/$productNameUid/Details/$productDetailsUid.json';

    try {
      final response = await http.patch(
        Uri.parse(dbUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'availableStockInPakistan': stockInPakistan,
          'totalAvailableStock': totalAvailableStock,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product details: $e');
    }
  }

  Future<void> convertPakToIndo(
      {required String productNameUid,
        required String productDetailsUid,
        required String stockInPakistan,
        required String stockInIndonesia,
        required String totalAvailableStock}) async {
    final String dbUrl =
        '$url/AllProducts/$productNameUid/Details/$productDetailsUid.json';

    try {
      final response = await http.patch(
        Uri.parse(dbUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'availableStockInPakistan': stockInPakistan,
          'availableStockInIndonesia': stockInIndonesia,
          'totalAvailableStock': totalAvailableStock,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product details: $e');
    }
  }

  Future<void> updateStockOnBill({
    required String detailUid,
    required String productUid,
    required String updatedStockOnSale,
    required String totalStock,
  }) async {
    final String detailsUrl =
        '$url/AllProducts/$productUid/Details/$detailUid.json';

    try {
      final response = await http.patch(
        Uri.parse(detailsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'availableStockInIndonesia': updatedStockOnSale,
          'totalAvailableStock': totalStock,

        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update stock quantity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product details: $e');
    }
  }

}
