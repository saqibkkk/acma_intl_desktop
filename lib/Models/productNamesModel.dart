
class ProductNamesModel {
  String productNameUid;
  String productName;

  ProductNamesModel({
    required this.productNameUid,
    required this.productName,
  });

  Map<String, dynamic> toJson() {
    return {
      'productNameUid': productNameUid,
      'productName': productName,
    };
  }

  factory ProductNamesModel.fromJson(Map<dynamic, dynamic> json) {
    return ProductNamesModel(
      productNameUid: json['productNameUid'] ?? '',
      productName: json['productName'] ?? '',
    );
  }

}
