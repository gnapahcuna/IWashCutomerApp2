class Order {
  final int OrderNo;
  final String BranchCode;
  final String BranchNameTH;
  final String BranchNameEN;
  final String OrderDate;
  final String AppointmentDate;
  final String CustomerName;
  final String PhoneBranch;
  final String PhoneCustomer;
  final int Count;
  final String Amount;

  Order({this.OrderNo,this.BranchCode, this.BranchNameTH, this.BranchNameEN,
    this.OrderDate,this.AppointmentDate, this.CustomerName,this.PhoneBranch,this.PhoneCustomer,this.Count,this.Amount});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      OrderNo: json['OrderNo'],
      BranchCode: json['BranchCode'],
      BranchNameTH: json['BranchNameTH'],
      BranchNameEN: json['BranchNameEN'],
      OrderDate: json['OrderDate'],
      AppointmentDate: json['AppointmentDate'],
      CustomerName: json['CustomerName'],
      PhoneCustomer: json['TelephoneNoCust'],
      PhoneBranch: json['TelephoneNoBranch'],
      Count: json['Counts'],
      Amount: json['Amount'],
    );
  }
}