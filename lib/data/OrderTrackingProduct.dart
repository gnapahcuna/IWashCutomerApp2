class OrderTrackingProduct {
  final int ProductID;
  final int ServiceType;
  final int CategoryID;
  final String ProductNameTH;
  final String ProductNameEN;
  final String ImageFile;
  final String ProductPrice;
  final int Count;

  OrderTrackingProduct({this.ProductID, this.ServiceType, this.CategoryID, this.ProductNameTH, this.ProductNameEN, this.ImageFile,this.ProductPrice,this.Count});

  factory OrderTrackingProduct.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return OrderTrackingProduct(
      ProductID: json['ProductID'],
      ServiceType: json['ServiceType'],
      CategoryID: json['CategoryID'],
      ProductNameTH: json['ProductNameTH'],
      ProductNameEN: json['ProductNameEN'],
      ProductPrice: json['Amount'],
      ImageFile: json['ImageFile'],
      Count: json['Counts'],
    );
  }
}