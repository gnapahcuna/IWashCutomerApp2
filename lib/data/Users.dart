class Users {
  final int CustomerID,BranchID,BranchGroupID;
  final String FirstName;
  final String LastName;
  final String TelephoneNo;
  final String BranchCode;
  final String BranchNameTH;
  final String BranchNameEN;
  final String TelephoneNoBranch;
  final String Latitude;
  final String Longitude;
  final String Address;
  final String CityName;
  final String BranchContactName;

  Users({this.CustomerID,this.BranchID, this.FirstName, this.LastName, this.TelephoneNo, this.BranchCode,this.BranchNameTH,
    this.BranchNameEN,this.TelephoneNoBranch,this.BranchGroupID,this.Latitude,this.Longitude,this.Address,this.CityName,this.BranchContactName});

  factory Users.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Users(
      CustomerID: json['CustomerID'],
      FirstName: json['FirstName'],
      LastName: json['LastName'],
      TelephoneNo: json['PhoneCust'],

      BranchID: json['BranchID'],
      BranchGroupID: json['BranchGroupID'],
      BranchCode: json['BranchCode'],
      BranchNameTH: json['BranchNameTH'],
      BranchNameEN: json['BranchNameEN'],
      TelephoneNoBranch: json['PhoneBranch'],

      Latitude: json['Latitude'],
      Longitude: json['Longitude'],
      Address: json['Address'],
      CityName: json['CityName'],
      BranchContactName: json['BranchContactName'],
    );
  }
}