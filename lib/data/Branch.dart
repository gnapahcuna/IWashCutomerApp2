class Branch {
  final int BranchID;
  final int BranchGroupID;
  final String BranchCode;
  final String BranchNameTH;
  final String BranchNameEN;
  final String ImageUrl;
  final double Distance;

  Branch({this.BranchID,this.BranchGroupID, this.BranchCode, this.BranchNameTH, this.BranchNameEN,this.Distance,this.ImageUrl});

  factory Branch.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return Branch(
      BranchID: json['BranchID'],
      BranchGroupID: json['BranchGroupID'],
      BranchCode: json['BranchCode'],
      BranchNameTH: json['BranchNameTH'],
      BranchNameEN: json['BranchNameEN'],
      Distance: json['distance'],
      ImageUrl: json['images'],
    );
  }
}