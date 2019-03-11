class Category {
  final int CategoryID;
  final String CategoryNameTH;
  final String CategoryNameEN;
  final String ColorCode;

  Category({this.CategoryID, this.CategoryNameTH, this.CategoryNameEN, this.ColorCode});

  factory Category.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Category(
      CategoryID: json['CategoryID'],
      CategoryNameTH: json['CategoryNameTH'],
      CategoryNameEN: json['CategoryNameEN'],
      ColorCode: json['ColorCode'],
    );
  }
}