import 'dart:convert';
import 'package:acma_intl_desktop/Models/billModel.dart';
import 'package:http/http.dart' as http;
import 'package:acma_intl_desktop/utils.dart';
import 'package:get/get.dart';

import '../Models/customerModel.dart';
import '../constants.dart';

class CustomerApi extends GetxController {
  final utils = Utils();

  Future<void> saveCustomers(
      {required CustomerModel customer, required String customerUid}) async {
    final String fullUrl = '$url/AllClients/$customerUid.json';
    final response = await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save client: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchCustomers() async {
    final String fullUrl = '$url/AllClients.json';
    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic>? data = json.decode(response.body);
        return data ?? {};
      } else {
        throw Exception('Failed to fetch clients: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return {};
    }
  }

  Future<void> editCustomer({
    required String customerUid,
    required String newCustomerName,
    required String newCustomerContact,
    required String newCustomerAddress,
  }) async {
    final String detailsUrl = '$url/AllClients/$customerUid.json';

    try {
      final response = await http.patch(
        Uri.parse(detailsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customerName': newCustomerName,
          'customerContactNumber': newCustomerContact,
          'customerAddress': newCustomerAddress,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating customer details: $e');
    }
  }

  Future<void> deleteCustomer({required String customerUid}) async {
    final String fullUrl = '$url/AllClients/$customerUid.json';
    final response = await http.delete(Uri.parse(fullUrl));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete customer: ${response.body}");
    }
  }

  Future<void> saveBill(
      {required BillModel bill,
      required String customerUid,
      required String billUid}) async {
    final String fullUrl = '$url/AllClients/$customerUid/Bills/$billUid.json';
    final response = await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(bill.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save client: ${response.body}");
    }
  }
}
