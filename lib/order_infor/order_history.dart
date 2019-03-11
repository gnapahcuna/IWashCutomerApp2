import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:cleanmate_customer_app/order_infor/order_traking_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/data/OrderHistory.dart' as _history;
class History extends StatefulWidget {
  int CustomerID;
  History({
    Key key,
    @required this.CustomerID,
  }) : super(key: key);
  @override
  _HistoryState createState() => new _HistoryState();
}
class _HistoryState extends State<History> {
  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  //int CustomerID=0, BranchID=0, BranchGroupID=0;

  @override
  void initState() {
    super.initState();
    //_getUserAcct();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*_getUserAcct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      CustomerID = (prefs.getInt("CustomerID") ?? 0);
      BranchID = (prefs.getInt("BranchID") ?? 0);
      BranchGroupID = (prefs.getInt("BranchGroupID") ?? 0);
    });
  }*/

  Widget generateCart(OrderNo,OrderDate,AppointmentDate,BranchCode,BranchName,IsPayment,CreateDate,
      IsPackage,DeliveryStatus,IsDriverVerify,DriverVerifyDate,IsCheckerVerify,CheckerVerifyDate,
      IsBranchEmpVerify,BranchEmpVerifyDate,IsReturnCustomer,ReturnCustomerDate) {
    var size = MediaQuery
        .of(context)
        .size;

    String Status="";
    String LastDate="";
    String LastTime="";
    List splits;
    if(IsPackage==0&&DeliveryStatus==0&&IsDriverVerify==0&&IsCheckerVerify==0&&IsBranchEmpVerify==0&&IsReturnCustomer==0){
      Status="สร้างออเดอร์";
      splits=CreateDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==0&&IsDriverVerify==0&&IsCheckerVerify==0&&IsBranchEmpVerify==0&&IsReturnCustomer==0){
      Status="ร้านทำออเดอร์เข้าระบบ";
      splits=CreateDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==0&&IsDriverVerify==1&&IsCheckerVerify==0&&IsBranchEmpVerify==0&&IsReturnCustomer==0){
      Status="คนขับรถนำส่งโรงงาน";
      splits=DriverVerifyDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==0&&IsDriverVerify==1&&IsCheckerVerify==1&&IsBranchEmpVerify==0&&IsReturnCustomer==0){
      Status="โรงงานรับออเดอร์";
      splits=CheckerVerifyDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==1&&IsDriverVerify==0&&IsCheckerVerify==1&&IsBranchEmpVerify==0&&IsReturnCustomer==0){
      Status="โรงงานเตรียมผ้าส่ง";
      splits=CheckerVerifyDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==1&&IsDriverVerify==1&&IsCheckerVerify==1&&IsBranchEmpVerify==0&&IsReturnCustomer==0){
      Status="คนขับรถนำส่งร้าน";
      splits=DriverVerifyDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==1&&IsDriverVerify==1&&IsCheckerVerify==1&&IsBranchEmpVerify==1&&IsReturnCustomer==0){
      Status="ร้านรับผ้าคืนจากโรงงาน";
      splits=BranchEmpVerifyDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }else if(IsPackage==1&&DeliveryStatus==1&&IsDriverVerify==1&&IsCheckerVerify==1&&IsBranchEmpVerify==1&&IsReturnCustomer==1){
      Status="ลูกค้ารับผ้าคืน";
      splits=ReturnCustomerDate.toString().split(" ");
      LastDate=splits[0];
      LastTime=splits[1];
    }

    return Padding(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: GestureDetector(
        onTap: () {
          //
          Navigator.of(context)
              .push(
              new MaterialPageRoute(builder: (context) => TrackingDetail(OrderNo: OrderNo,Status: Status,
                Branchname: BranchName+"("+BranchCode+")",OrderDate: OrderDate,AppointmentDate: AppointmentDate,IsPatment: IsPayment,LastDate: LastDate,IsPage: "History",)));
        }, child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12.0
              )
            ]
        ),
        height: size.height / 5,
        width: (size.width * 80) / 100,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text('หมายเลขออเดอร์ : ',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: cl_text_pro_en,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',),),
                        ),
                        Text('#'+OrderNo.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: cl_text_pro_th,
                            fontFamily: 'Poppins',),),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'วันที่ทำรายการ : '+CreateDate, style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.0,
                                color: cl_text_pro_en),),
                          ),
                          /*Row(
                            children: <Widget>[
                              //Icon(Icons.check_box),
                              Text(
                                "${Status}", style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16.0,
                                  color: cl_text_pro_th),),
                            ],
                          )*/
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'วันที่ทำรายการเสร็จสิ้น : '+ReturnCustomerDate, style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.0,
                                color: cl_text_pro_en),),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: Padding(padding: EdgeInsets.all(0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.store, color: cl_text_pro_en,),
                                    Text('สาขา'+BranchName+'('+BranchCode+')', style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14.0,
                                        color: cl_text_pro_en),),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),),
    );
  }
  Future<Null> _refresh() {
    return fetchTracking(widget.CustomerID.toString()).then((tracking) {
      setState(() {
        print(tracking[0].OrderNo);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final makeBody = FutureBuilder<List<_history.OrderHistory>>(
        future: fetchTracking(widget.CustomerID.toString()),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return new MaterialApp(
              debugShowCheckedModeBanner: false,
              home: new Scaffold(
                //backgroundColor: cl_back,
                body: Center(
                  child: new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),
                ),
              ),
            );
          // Shows the real data with the data retrieved.
          List<_history.OrderHistory> history = snapshot.data;
          //print('size : '+history.length.toString());
          return history.length>0?Container(
            child: ListView.builder(
              itemCount: history.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    //
                  },
                  child: generateCart(history[index].OrderNo,history[index].OrderDate,history[index].AppointmentDate,history[index].BranchCode,history[index].BranchNameTH, history[index].IsPayment,
                      history[0].CreatedDate,history[index].IsPackage,history[index].DeliveryStatus,history[index].IsDriverVerify,history[index].DriverVerifyDate,
                      history[index].IsCheckerVerify,history[index].CheckerVerifyDate, history[index].IsBranchEmpVerify,
                      history[index].BranchEmpVerifyDate,history[index].IsReturnCustomer,history[index].ReturnCustomerDate),
                );
              },
            ),
          ):
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Container(
              child: Center(
                child:  Text(
                  'ไม่มีรายการ',
                  style: new TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: cl_text_pro_th
                  ),
                ),
              ),
            ),
          );
        }
    );

    final makeBottom = new Container(
      //margin: EdgeInsets.only(bottom: 18.0),
        height: 65.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Colors.grey[300], width: 1.0)
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text("*แสดงเฉพาะประวัติการทำรายการย้อนหลัง 3 เดือน",
                style: TextStyle(fontSize: 14.0,
                    color: Colors.deepOrange,
                    fontFamily: 'Poppins'),
              ),
            ),

          ],
        )
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: cl_text_pro_th),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: new Text(
          'ประวัติการทำรายการของคุณ', style: new TextStyle(color: cl_text_pro_th),),
      ),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: makeBody),
      bottomNavigationBar: makeBottom,
    );
  }
}
Future<List<_history.OrderHistory>> fetchTracking(CustomerID) async {
  try {
    final paramDic = {
      "CustomerID": CustomerID.toString(),
    };
    //print('cust : '+CustomerID.toString());
    http.Response response =
    await http.post(
        Server().IPAddress + '/data/get/OrderHistory.php', body: paramDic);
    print(response.body.toString());
    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new _history.OrderHistory.fromJson(m))
          .toList();
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  } catch (exception) {
    print(exception.toString());
  }
}