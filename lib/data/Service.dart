class Service {
  final int ServiceType;
  final String ServiceNameTH;
  final String ServiceNameEN;
  final String ImageFile;

  Service({this.ServiceType, this.ServiceNameTH, this.ServiceNameEN, this.ImageFile});

  factory Service.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Service(
      ServiceType: json['ServiceType'],
      ServiceNameTH: json['ServiceNameTH'],
      ServiceNameEN: json['ServiceNameEN'],
      ImageFile: json['ImageFile'],
    );
  }
}