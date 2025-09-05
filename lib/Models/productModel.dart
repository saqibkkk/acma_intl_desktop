class ProductDetailsModel {
  String productDetailsUid;
  String productNameUid;
  String productName;
  String catalogueNumber;
  String lotNumber;
  String numberOfHoles;
  String aklNumber;
  String availableStockInPakistan;
  String availableStockInIndonesia;
  String totalAvailableStock;

  ProductDetailsModel({
    required this.productDetailsUid,
    required this.productNameUid,
    required this.productName,
    required this.catalogueNumber,
    required this.lotNumber,
    required this.numberOfHoles,
    required this.aklNumber,
    required this.availableStockInPakistan,
    required this.availableStockInIndonesia,
    required this.totalAvailableStock,
  });

  Map<String, dynamic> toJson() {
    return {
      'productDetailsUid': productDetailsUid,
      'productNameUid': productNameUid,
      'productName': productName,
      'catalogueNumber': catalogueNumber,
      'lotNumber': lotNumber,
      'numberOfHoles': numberOfHoles,
      'aklNumber': aklNumber,
      'availableStockInPakistan': availableStockInPakistan,
      'availableStockInIndonesia': availableStockInIndonesia,
      'totalAvailableStock': totalAvailableStock,
    };
  }

  factory ProductDetailsModel.fromJson(Map<dynamic, dynamic> json) {
    return ProductDetailsModel(
      productDetailsUid: json['productDetailsUid'] ?? '',
      productNameUid: json['productNameUid'] ?? '',
      productName: json['productName'] ?? '',
      catalogueNumber: json['catalogueNumber'] ?? '',
      lotNumber: json['lotNumber'] ?? '',
      numberOfHoles: json['numberOfHoles'] ?? '',
      aklNumber: json['aklNumber'] ?? '',
      availableStockInPakistan: json['availableStockInPakistan'] ?? '',
      availableStockInIndonesia: json['availableStockInIndonesia'] ?? '',
      totalAvailableStock: json['totalAvailableStock'] ?? '',
    );
  }

}
