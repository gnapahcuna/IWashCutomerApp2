import 'dart:convert';

class OrderTracking {
  final int OrderNo;
  final String OrderDate;
  final String BranchCode;
  final String BranchNameTH;
  final String BranchNameEN;
  final String AppointmentDate;
  final int IsPayment;

  final String CreatedDate;
  final int IsPackage;
  final int DeliveryStatus;
  final int IsDriverVerify;
  final String DriverVerifyDate;
  final int IsCheckerVerify;
  final String CheckerVerifyDate;
  final int IsBranchEmpVerify;
  final String BranchEmpVerifyDate;
  final int IsReturnCustomer;
  final String ReturnCustomerDate;
  //final String Status;


  OrderTracking({this.OrderNo,this.OrderDate,this.AppointmentDate, this.BranchCode, this.BranchNameTH, this.BranchNameEN,this.IsPayment,
  this.CreatedDate,this.IsPackage,this.DeliveryStatus,this.IsDriverVerify,this.DriverVerifyDate,this.IsCheckerVerify,this.CheckerVerifyDate,
    this.IsBranchEmpVerify,this.BranchEmpVerifyDate,this.IsReturnCustomer,this.ReturnCustomerDate});

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    //print(json['ImageFile'].toString().substring(3,json['ImageFile'].toString().length));
    return OrderTracking(
      OrderNo: json['OrderNo'],
      OrderDate: json['OrderDate'],
      AppointmentDate: json['AppointmentDate'],
      BranchCode: json['BranchCode'],
      BranchNameTH: json['BranchNameTH'],
      BranchNameEN: json['BranchNameEN'],
      IsPayment: json['IsPayment'],
      IsPackage: json['IsPackage'],
      CreatedDate: json['CreatedDate'],
      DeliveryStatus: json['DeliveryStatus'],
      IsDriverVerify: json['IsDriverVerify'],
      DriverVerifyDate: json['DriverVerifyDate'],
      IsCheckerVerify: json['IsCheckerVerify'],
      CheckerVerifyDate: json['CheckerVerifyDate'],
      IsBranchEmpVerify: json['IsBranchEmpVerify'],
      BranchEmpVerifyDate: json['BranchEmpVerifyDate'],
      IsReturnCustomer: json['IsReturnCustomer'],
      ReturnCustomerDate: json['ReturnCustomerDate'],
    );
  }
}