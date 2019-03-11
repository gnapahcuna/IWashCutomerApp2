class Brochure {
  final String url;
  Brochure({this.url});

  factory Brochure.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Brochure(
      url: json['ImageFile'],
    );
  }
}