class Product {
  final int ProductID;
  final int ServiceType;
  final int CategoryID;
  final String ProductNameTH;
  final String ProductNameEN;
  final String ImageFile;
  final String ProductPrice;
  final String ColorCode;
  final int Rating;

  Product({this.ProductID, this.ServiceType, this.CategoryID, this.ProductNameTH, this.ProductNameEN, this.ImageFile,this.ProductPrice,this.ColorCode,this.Rating});

  factory Product.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Product(
      ProductID: json['ProductID'],
      ServiceType: json['ServiceType'],
      CategoryID: json['CategoryID'],
      ProductNameTH: json['ProductNameTH'],
      ProductNameEN: json['ProductNameEN'],
      ProductPrice: json['ProductPrice'],
      ImageFile: json['ImageFile'],
      ColorCode: json['ColorCode'],
      Rating: json['Rating'],
    );
  }
}