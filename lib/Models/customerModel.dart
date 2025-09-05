class CustomerModel {
  String customerName;
  String customerContactNumber;
  String customerAddress;
  String customerUid;

  CustomerModel({
    required this.customerName,
    required this.customerContactNumber,
    required this.customerAddress,
    required this.customerUid,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerContactNumber': customerContactNumber,
      'customerAddress': customerAddress,
      'customerUid': customerUid,
    };
  }

  factory CustomerModel.fromJson(Map<dynamic, dynamic> json) {
    return CustomerModel(
      customerName: json['customerName'] ?? '',
      customerContactNumber: json['customerContactNumber'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerUid: json['customerUid'] ?? '',
    );
  }
}
