class Profile {
  final int CustomerID;
  final String FirstName;
  final String LastName;
  final String NickName;
  final String TelephoneNo;
  final String Email;
  final String Password;

  Profile({this.CustomerID, this.FirstName, this.LastName,this.NickName, this.TelephoneNo,this.Email,this.Password});

  factory Profile.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Profile(
      CustomerID: json['CustomerID'],
      FirstName: json['FirstName'],
      LastName: json['LastName'],
      NickName: json['NickName'],
      TelephoneNo: json['TelephoneNo'],
      Email: json['Email'],
      Password: json['Password'],
    );
  }
}