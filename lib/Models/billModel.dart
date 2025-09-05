class BillItemModel {
  String productUid;
  String productName;
  String catalogueNumber;
  String lotNumber;
  String numberOfHoles;
  String aklNumber;
  int quantity;
  double price;
  double total;

  BillItemModel({
    required this.productUid,
    required this.productName,
    required this.catalogueNumber,
    required this.lotNumber,
    required this.numberOfHoles,
    required this.aklNumber,
    required this.quantity,
    required this.price,
    required this.total,
  });

  // Convert to Map for saving in database
  Map<String, dynamic> toMap() {
    return {
      "productUid": productUid,
      "productName": productName,
      "catalogueNumber": catalogueNumber,
      "lotNumber": lotNumber,
      "numberOfHoles": numberOfHoles,
      "aklNumber": aklNumber,
      "quantity": quantity,
      "price": price,
      "total": total,
    };
  }

  // Create instance from Map (for reading from DB)
  factory BillItemModel.fromMap(Map<String, dynamic> map) {
    return BillItemModel(
      productUid: map["productUid"],
      productName: map["productName"],
      catalogueNumber: map["catalogueNumber"],
      lotNumber: map["lotNumber"],
      numberOfHoles: map["numberOfHoles"],
      aklNumber: map["aklNumber"],
      quantity: map["quantity"] ?? 0,
      price: (map["price"] ?? 0).toDouble(),
      total: (map["total"] ?? 0).toDouble(),
    );
  }
}

class BillModel {
  String billId;
  DateTime createdAt;
  double totalBill;
  List<BillItemModel> items;

  BillModel({
    required this.billId,
    required this.createdAt,
    required this.totalBill,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      "billId": billId,
      "createdAt": createdAt.toIso8601String(),
      "totalBill": totalBill,
      "items": items.map((item) => item.toMap()).toList(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      billId: map["billId"],
      createdAt: DateTime.parse(map["createdAt"]),
      totalBill: map["totalBill"],
      items: List<BillItemModel>.from(
          map["items"].map((itemMap) => BillItemModel.fromMap(itemMap))),
    );
  }
}
