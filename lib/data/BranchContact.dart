class BranchContact {
  final int BranchID;
  final int BranchGroupID;
  final String BranchGroupName;
  final String BranchCode;
  final String BranchNameTH;
  final String BranchNameEN;
  final String Latitude;
  final String Longitude;
  final String Address;
  final String CityName;
  final String TelephoneNo;
  final String Contact;
  final double Distance;

  BranchContact({this.BranchID,this.BranchGroupID,this.BranchGroupName, this.BranchCode, this.BranchNameTH, this.BranchNameEN,
    this.Latitude,this.Longitude, this.Address,this.CityName,this.TelephoneNo,this.Contact,this.Distance});

  factory BranchContact.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return BranchContact(
      BranchID: json['BranchID'],
      BranchGroupID: json['BranchGroupID'],
      BranchGroupName: json['BranchGroupName'],
      BranchCode: json['BranchCode'],
      BranchNameTH: json['BranchNameTH'],
      BranchNameEN: json['BranchNameEN'],
      Latitude: json['Latitude'],
      Longitude: json['Longitude'],
      Address: json['Address'],
      CityName: json['CityName'],
      TelephoneNo: json['TelephoneNo'],
      Contact: json['BranchContactName'],
      Distance: json['distance'],
    );
  }
}